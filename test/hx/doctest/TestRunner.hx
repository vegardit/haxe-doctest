/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
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

        #if !(flash || js)
        /*
         * MUnit seems broken on some platforms:
         *
         * 1) fails on Flash with: hx/doctest/tests/MUnitTest.hx:9: characters 7-31 : Type not found : massive.munit.TestRunner
         *
         * 2) fails on JS with:
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
         */
        MUnitTest.main();

        /*
         * nodejs fails with:
         *    tink_testrunner/0,6,2/src/tink/testrunner/Reporter.hx:174: characters 3-14 : Accessing this field requires a system platform (php,php7,neko,cpp,etc.)
         *
         * flash fails with:
         *    Not supported yet.
         */
        TinkTestrunnerUnitTest.main();
        #end

        DocTestTest.main();
    }

}
