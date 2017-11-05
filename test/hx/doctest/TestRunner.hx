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

import hx.doctest.tests.*;

/**
 * Main entry point to test doctest.
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class TestRunner {

    public static function main() {

        #if flash
        var old = haxe.Log.trace;
        haxe.unit.TestRunner.print = function(v) old(v);
        #end
        HaxeUnitTest.main();

        #if !(php || flash || js || hl)
        /*
         * MUnit seems broken on some platforms:
         *
         * 1) fails on PHP with:   munit/2,1,2/massive/munit/TestRunner.hx:384: characters 16-27 : Class<massive.munit.util.Timer> has no field delay
         *
         * 2) fails on Flash with: hx/doctest/tests/MUnitTest.hx:9: characters 7-31 : Type not found : massive.munit.TestRunner
         *
         * 3) fails on JS with:
         *   ReferenceError: Can't find variable: addToQueue
         *     undefined:1 in eval code
         *     :0 in eval
         *     phantomjs://code/TestRunner.js:2902 in queue
         *     phantomjs://code/TestRunner.js:2868 in createTestClass
         *     phantomjs://code/TestRunner.js:2954 in initializeTestClass
         *     phantomjs://code/TestRunner.js:2594 in setCurrentTestClass
         *     phantomjs://code/TestRunner.js:2367 in executeTestCases
         *     phantomjs://code/TestRunner.js:2334 in execute
         *     phantomjs://code/TestRunner.js:2320 in run
         *     phantomjs://code/TestRunner.js:1194 in main
         *
         *  4) fails on HL with:
         *   Uncaught exception: Can't cast #hx.doctest.tests.MUnitDocTests to #massive.munit.TestClassHelper
         *   Called from @0x4A38D30
         *   Called from $Reflect.callMethod(C:\apps\dev\haxe\haxe-4.0.0-nightly\std/hl/_std/Reflect.hx:85)
         *   Called from massive.munit.TestRunner.execute(massive/munit/TestRunner.hx:243)
         *   Called from massive.munit.TestRunner.run(massive/munit/TestRunner.hx:229)
         *   Called from hx.doctest.tests.$MUnitTest.main(hx/doctest/tests/MUnitTest.hx:33)
         *   Called from hx.doctest.$TestRunner.main(hx/doctest/TestRunner.hx:57)
         *   Called from fun$883(?:1)
         */
        MUnitTest.main();
        #end

        TinkTestrunnerUnitTest.main();

        DocTestTest.main();
    }

}
