/*
 * Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package hx.doctest;

import haxe.PosInfos;
import haxe.Timer;

using StringTools;
using hx.doctest.internal.DocTestUtils;
using hx.doctest.internal.Logger;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:abstract
class DocTestRunner {

    var testsOK = 0;
    var testsFailed:Array<LogEvent> = [];
    
    public function new() {
    }
    
    /**
     * Runs the accumulated doc tests.
     * @return number of failing tests
     */
    function run(expectedMinNumberOfTests = 0):Int {
        var startTime = Timer.stamp();
        var thisClass = Type.getClass(this);
        var thisClassName = Type.getClassName(thisClass);
        // look for functions starting with "test" and invoke them
        Logger.log(INFO, 'Looking for test cases in [${thisClassName}]...');
        for (funcName in Type.getInstanceFields(thisClass)) {
            if (funcName.startsWith("test")) {
                var func:Dynamic = Reflect.field(this, funcName);
                if (Reflect.isFunction(func)) {
                    Logger.log(INFO, 'Invoking [${thisClassName}#$funcName()]...');
                    Reflect.callMethod(this, func, []);
                }
            }
        }
        var timeSpent:Float = Math.round(1000 * (Timer.stamp() - startTime)) / 1000;
        if (testsFailed.length == 0) {
            if (expectedMinNumberOfTests > 0 && testsOK + testsFailed.length < expectedMinNumberOfTests) {
                Logger.log(ERROR, '**********************************************************');
                Logger.log(ERROR, '$expectedMinNumberOfTests tests expected but only ${testsOK + testsFailed.length} found!');
                Logger.log(ERROR, '**********************************************************');
                return 1;
            } else if (testsOK == 0) {
                Logger.log(WARN, '**********************************************************');
                Logger.log(WARN, 'No test assertions were found!');
                Logger.log(WARN, '**********************************************************');                
            } else {
                Logger.log(INFO, '**********************************************************');
                Logger.log(INFO, 'All $testsOK test(s) were SUCCESSFUL within $timeSpent seconds');
                Logger.log(INFO, '**********************************************************');
            }
            return 0;
		}
        
        Logger.log(ERROR, '${testsFailed.length} of $testsOK test(s) FAILED:');
        for (event in testsFailed) {
            event.log(true);
        }
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
            untyped phantom.exit(exitCode);
        #end
    }
    
    /**
     * for use within manually created test method
     */
    function assertTrue(result:Bool, ?pos:PosInfos):Void {
        if (result) {
            haxe.Log.trace('[OK] assertTrue(true)', pos);
            testsOK++;
        } else {
            testsFailed.push(Logger.log(ERROR, 'assertTrue($result)', null, pos));
        }
    }
    
    /**
     * for use within manually created test method
     */
    function assertFalse(result:Bool, ?pos:PosInfos):Void {
        if (!result) {
            haxe.Log.trace('[OK] assertFalse(false)', pos);
            testsOK++;
        } else {
            testsFailed.push(Logger.log(ERROR, 'assertFalse($result)', null, pos));
        }
    }
    
    /**
     * for use within manually created test method
     */
    function assertEquals(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
        if (leftResult.equals(rightResult)) {
            haxe.Log.trace('[OK] assertEquals($leftResult, $rightResult)', pos);
            testsOK++;
        } else {
            testsFailed.push(Logger.log(ERROR, 'assertEquals($leftResult, $rightResult)', null, pos));
        }
    }
    
    /**
     * for use within manually created test method
     */
    function assertNotEquals(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
        if (!leftResult.equals(rightResult)) {
            haxe.Log.trace('[OK] assertNotEquals($leftResult, $rightResult)', pos);
            testsOK++;
        } else {
            testsFailed.push(Logger.log(ERROR, 'assertNotEquals($leftResult, $rightResult)', null, pos));
        }
    }

    /**
     * for use within manually created test method
     */
    function fail(?msg:String, ?pos:PosInfos):Void {
        if (msg == null) msg = "This code location should not never be reached.";
        testsFailed.push(Logger.log(ERROR, msg, null, pos));
    }
}
