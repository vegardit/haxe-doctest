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
    
    /**
     * Runs the accumulated doc tests and exits the process with exit code 0 in case all 
     * tests were passed or 1 in case test failures occured.
     */
    function runAndExit():Void {
        if (run() == 0) {
            #if js
                untyped __js__("phantom.exit(0)");
            #elseif (flash)
                // do nothing
            #else
                Sys.exit(0);
            #end
        } else {
            #if js
                untyped __js__("phantom.exit(1)");
            #elseif (flash)
                // do nothing
            #else
                Sys.exit(1);
            #end
        }
    }
    
    /**
     * Runs the accumulated doc tests.
     * 
     * @return number of failing tests
     */
    function run():Int {
        var startTime = Timer.stamp();
        
        // look for functions starting with "test" and invoke them
        trace('[INFO] Looking for test cases...');
        for (f in Type.getInstanceFields(Type.getClass(this))) {
            if (f.startsWith("test")) {
                var func:Dynamic = Reflect.field(this, f);
                if (Reflect.isFunction(func)) {
                    Reflect.callMethod(this, func, []);
                }
            }
        }
        var timeSpent:Float = Math.round(1000 * (Timer.stamp() - startTime)) / 1000;
        if (testsFailed.length == 0) {
            if (testsOK == 0) {
                trace('[WARN] **********************************************************');
                trace('[WARN] No doctests were found!');
                trace('[WARN] **********************************************************');                
            } else {
                trace('[INFO] **********************************************************');
                trace('[INFO] All $testsOK test(s) were SUCCESSFUL within $timeSpent seconds');
                trace('[INFO] **********************************************************');
            }
		} else {
            var sb = new StringBuf();
            sb.add('\n[ERROR] ${testsFailed.length} of $testsOK test(s) FAILED:');
            var i = 0;
			for (msg in testsFailed) {
                i++;
                sb.add('\n');
                sb.add(msg);
			}
            #if !(flash || js)
                Sys.stderr().writeString(sb.toString());
            #else
                trace(sb);
            #end
		}
        return testsFailed.length;
	}
    
    function compareResults(doctestLine:String, pos:PosInfos, leftResult:Dynamic, rightResult:Dynamic):Void {
        if (leftResult.equals(rightResult)) {
            pos.fileName = DocTestUtils.substringAfterLast("/" + pos.fileName, "/");
            haxe.Log.trace('[OK] ' + doctestLine, pos);
            testsOK++;
        } else {
            haxe.Log.trace('[FAIL] $doctestLine\n     |--> [$leftResult] != [$rightResult]', pos);
            testsFailed.push('${pos.fileName}:${pos.lineNumber}: $doctestLine\n   |--> [$leftResult] != [$rightResult]');
        }
    }
    
    public function new() {
        
    }
}
