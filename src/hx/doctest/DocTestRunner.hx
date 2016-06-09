/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest;

import haxe.PosInfos;
import haxe.Timer;

using StringTools;
using hx.doctest.internal.DocTestUtils;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:abstract
class DocTestRunner {

    var testsOK = 0;
    var testsFailed = [];
    
    public function new() {
    }
    
    /**
     * Runs the accumulated doc tests.
     * @return number of failing tests
     */
    function run(expectedMinNumberOfTests = 0):Int {
        var startTime = Timer.stamp();
        var thisClass = Type.getClass(this);
        // look for functions starting with "test" and invoke them
        trace('[INFO] Looking for test cases in [${Type.getClassName(thisClass)}]...');
        for (f in Type.getInstanceFields(thisClass)) {
            if (f.startsWith("test")) {
                var func:Dynamic = Reflect.field(this, f);
                if (Reflect.isFunction(func)) {
                    Reflect.callMethod(this, func, []);
                }
            }
        }
        var timeSpent:Float = Math.round(1000 * (Timer.stamp() - startTime)) / 1000;
        if (testsFailed.length == 0) {
            if (expectedMinNumberOfTests > 0 && testsOK + testsFailed.length < expectedMinNumberOfTests) {
                #if sys
                    Sys.stderr().writeString('[ERROR] **********************************************************\n');
                    Sys.stderr().writeString('[ERROR] $expectedMinNumberOfTests tests expected but only ${testsOK + testsFailed.length} found!\n');
                    Sys.stderr().writeString('[ERROR] **********************************************************\n');
                #else
                    trace('[ERROR] **********************************************************');
                    trace('[ERROR] $expectedMinNumberOfTests tests expected but only ${testsOK + testsFailed.length} executed.');
                    trace('[ERROR] **********************************************************');
                #end
                return 1;
            } else if (testsOK == 0) {
                trace('[WARN] **********************************************************');
                trace('[WARN] No tests were found!');
                trace('[WARN] **********************************************************');                
            } else {
                trace('[INFO] **********************************************************');
                trace('[INFO] All $testsOK test(s) were SUCCESSFUL within $timeSpent seconds');
                trace('[INFO] **********************************************************');
            }
            return 0;
		}
        
        var sb = new StringBuf();
        sb.add('\n[ERROR] ${testsFailed.length} of $testsOK test(s) FAILED:');
        var i = 0;
        for (msg in testsFailed) {
            i++;
            sb.add('\n');
            sb.add(msg);
        }
        #if sys
            Sys.stderr().writeString(sb.toString());
        #else
            trace(sb);
        #end
        return testsFailed.length;
	}
    
    /**
     * Runs the accumulated doc tests and exits the process with exit code 0 in case all 
     * tests were passed or 1 in case test failures occured.
     */
    function runAndExit(expectedMinNumberOfTests = 0):Void {
        var exitCode = run(expectedMinNumberOfTests) == 0 ? 0 : 1;
        
        #if sys
            Sys.exit(exitCode);
        #elseif js
            untyped __js__('phantom.exit($exitCode)');
        #end
    }
    
    /**
     * for use within manually created test method
     */
    function assertEquals(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
        if (leftResult.equals(rightResult)) {
            haxe.Log.trace('[OK] assertEquals($leftResult, $rightResult)', pos);
            testsOK++;
        } else {
            haxe.Log.trace('[FAIL] [$leftResult] != [$rightResult]', pos);
            testsFailed.push('${pos.fileName}:${pos.lineNumber}: [FAIL] [$leftResult] != [$rightResult]');
        }
    }

    /**
     * for use within manually created test method
     */
    function fail(?msg:String, ?pos:PosInfos):Void {
        if (msg == null) msg = "This code location should not never be reached.";
        haxe.Log.trace('[FAIL] $msg', pos);
        testsFailed.push('${pos.fileName}:${pos.lineNumber}: [FAIL] $msg');
    }
    
    function _compareResults(leftResult:Dynamic, rightResult:Dynamic, assertion:String, pos:PosInfos):Void {
        if (leftResult.equals(rightResult)) {
            pos.fileName = ("/" + pos.fileName).substringAfterLast("/");
            haxe.Log.trace('[OK] ' + assertion, pos);
            testsOK++;
        } else {
            haxe.Log.trace('[FAIL] $assertion\n     |--> [$leftResult] != [$rightResult]', pos);
            testsFailed.push('${pos.fileName}:${pos.lineNumber}: [FAIL] $assertion\n   |--> [$leftResult] != [$rightResult]');
        }
    }
}
