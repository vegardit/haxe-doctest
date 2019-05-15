/*
 * Copyright (c) 2016-2019 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest;

import haxe.PosInfos;
import haxe.Timer;
import hx.doctest.internal.Logger;
import hx.doctest.internal.DocTestUtils;

using StringTools;


/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:abstract
class DocTestRunner {

    var results:DocTestResults;

    static function exit(exitCode:Int):Void {
        #if travix
            travix.Logger.exit(exitCode);
        #else
            #if sys
                Sys.exit(exitCode);
            #elseif js
                var isPhantomJSDirectExecution = untyped __js__("(typeof phantom !== 'undefined')");
                if(isPhantomJSDirectExecution) {
                    untyped __js__("phantom.exit(exitCode)");
                } else {
                    var isPhantomJSWebPage = untyped __js__("!!(typeof window != 'undefined' && window.callPhantom && window._phantom)");
                    if (isPhantomJSWebPage) {
                        untyped __js__("window.callPhantom({cmd:'doctest:exit', 'exitCode':exitCode})");
                    } else {
                        // nodejs
                        untyped __js__("process.exit(exitCode)");
                    }
                }
            #elseif flash
                flash.system.System.exit(exitCode);
            #end
        #end
    }

    public function new() {
    }

    /**
     * Runs the accumulated doc tests.
     * @return number of failing tests
     */
    function run(expectedMinNumberOfTests = 0, logResult:Bool = true):Int {
        if (results == null)
            results = new DefaultDocTestResults();

        var startTime = Timer.stamp();
        var thisClass = Type.getClass(this);
        var thisClassName = Type.getClassName(thisClass);

        /*
         * look for functions starting with "test" and invoke them
         */
        Logger.log(INFO, 'Looking for test cases in [${thisClassName}]...');
        var funcNames = new Array<String>();
        for (funcName in Type.getInstanceFields(thisClass)) {
            if (funcName.startsWith("test")) {
                funcNames.push(funcName);
            }
        }
        funcNames.sort(function(a, b) return a < b ? -1 : a > b ? 1 : 0);
        for (funcName in funcNames) {
            var func:Dynamic = Reflect.field(this, funcName);
            if (Reflect.isFunction(func)) {
                Logger.log(INFO, '**********************************************************');
                Logger.log(INFO, 'Invoking [${thisClassName}#$funcName()]...');
                Logger.log(INFO, '**********************************************************');
                Reflect.callMethod(this, func, []);
            }
        }

        var timeSpent:Float = Math.round(1000 * (Timer.stamp() - startTime)) / 1000;
        var testsOK = results.getSuccessCount();
        var testsFailed = results.getFailureCount();
        if (testsFailed == 0) {
            if (expectedMinNumberOfTests > 0 && testsOK < expectedMinNumberOfTests) {
                Logger.log(ERROR, '**********************************************************');
                Logger.log(ERROR, '$expectedMinNumberOfTests tests expected but only $testsOK found!');
                Logger.log(ERROR, '**********************************************************');
                return 1;
            } else if (testsOK == 0) {
                Logger.log(WARN, '**********************************************************');
                Logger.log(WARN, 'No test assertions were found!');
                Logger.log(WARN, '**********************************************************');
            } else {
                if (logResult) {
                    Logger.log(INFO, '**********************************************************');
                    Logger.log(INFO, 'All $testsOK test(s) were SUCCESSFUL within $timeSpent seconds.');
                    Logger.log(INFO, '**********************************************************');
                }
            }
            return 0;
        }

        if (logResult) {
            Logger.log(ERROR, '**********************************************************');
            Logger.log(ERROR, '$testsFailed of ${testsOK + testsFailed} test(s) FAILED:');
            results.logFailures();
        }
        return testsFailed;
    }


    /**
     * Runs the accumulated doc tests and exits the process with exit code 0 in case all
     * tests were passed or 1 in case test failures occured.
     */
    function runAndExit(expectedMinNumberOfTests = 0):Void {
        var exitCode = run(expectedMinNumberOfTests) == 0 ? 0 : 1;
        exit(exitCode);
    }

    /**
     * for use within manually created test method
     */
    function assertSame(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
        results.add(leftResult == rightResult, 'assertSame($leftResult, $rightResult)', null, pos);
    }

    /**
     * for use within manually created test method
     */
    function assertEquals(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
        results.add(DocTestUtils.deepEquals(leftResult, rightResult), 'assertEquals($leftResult, $rightResult)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function assertFalse(result:Bool, ?pos:PosInfos):Void {
        results.add(!result, 'assertFalse($result)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function assertMax(result:Int, min:Int, max:Int, ?pos:PosInfos):Void {
        results.add(result <= max, 'assertMax($result, $max)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function assertMin(result:Int, min:Int, ?pos:PosInfos):Void {
        results.add(result >= min, 'assertMin($result, $min)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function assertInRange(result:Int, min:Int, max:Int, ?pos:PosInfos):Void {
        results.add(result >= min && result <= max, 'assertInRange($result, $min, $max)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function assertNotSame(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
        results.add(leftResult != rightResult, 'assertNotSame($leftResult, $rightResult)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function assertNotEquals(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
        results.add(!DocTestUtils.deepEquals(leftResult, rightResult), 'assertNotEquals($leftResult, $rightResult)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function assertTrue(result:Bool, ?pos:PosInfos):Void {
        results.add(result, 'assertTrue($result)', null, pos);
    }


    /**
     * for use within manually created test method
     */
    function fail(?msg:String, ?pos:PosInfos):Void {
        if (msg == null) msg = "This code location should not never be reached.";
        results.add(false, msg, null, pos);
    }
}


interface DocTestResults {

    public function add(success:Bool, msg:String, loc:SourceLocation, pos:haxe.PosInfos):Void;

    public function getSuccessCount():Int;
    public function getFailureCount():Int;
    public function logFailures():Void;
}


class DefaultDocTestResults implements DocTestResults {

    var _testsOK = 0;
    var _testsFailed = new Array<LogEvent>();

    inline
    public function new() {
    }

    public function add(success:Bool, msg:String, loc:SourceLocation, pos:haxe.PosInfos) {
        if(success) {
            Logger.log(OK, msg, null, pos);
            _testsOK++;
        } else {
            _testsFailed.push(Logger.log(ERROR, msg, loc, pos));
        }
    }

    public function getSuccessCount():Int {
        return _testsOK;
    }

    public function getFailureCount():Int {
        return _testsFailed.length;
    }

    public function logFailures():Void {
        for (event in _testsFailed) {
            event.log(true);
        }
    }
}
