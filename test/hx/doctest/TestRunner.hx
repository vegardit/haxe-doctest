/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest;

import hx.doctest.tests.*;

/**
 * Main entry point to test doctest.
 */
class TestRunner {

   public static function main() {

      #if flash
         var old = haxe.Log.trace;
         haxe.unit.TestRunner.print = function(v) old(v);
      #end

      trace("###################");
      trace("HaxeUnitTest");
      trace("###################");
      HaxeUnitTest.main();

      #if (!(eval || flash || js) && haxe_ver < 5) //
         /*
          * MUnit seems broken on some platforms:
          *
          * 1) fails on Eval with: Field index for print not found on prototype mconsole.FilePrinter
          *
          * 2) fails on Flash with: lib\mconsole/1,6,0/mconsole/Console.hx:469: characters 3-94 : flash.utils.Object cannot be called
          *
          * 3) fails on JS with:
          *    ReferenceError: Can't find variable: addToQueue
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
          * 4) fails on Haxe 5 with: "Type not found : haxe.StackItem"
          */
         trace("###################");
         trace("MUnitTest");
         trace("###################");
         MUnitTest.main();
      #end

      #if (!(flash || php) && haxe_ver < 4.3) //
         /*
          * 1) fails on Flash with:
          *    Not supported yet.
          *
          * 2) fails on PHP with:
          *    Fatal error: Uncaught Error: Call to undefined method Attribute::Off() in haxe-doctest/bin/php/lib/ANSI.php:110
          *    Stack trace:
          *    #0 haxe-doctest/bin/php/lib/ANSI.php(145): ANSI::__hx__init()
          *    #1 haxe-doctest/bin/php/index.php(10): include_once('/Users/runner/w...')
          *    #2 haxe-doctest/bin/php/lib/tink/testrunner/AnsiFormatter.php(45): {closure}('ANSI')
          *
          * 3) fails on Haxe 4.3 with:
          *    tink_core/2,0,2/src/tink/core/Promise.hx:297: characters 5-21 : Recursive implicit cast
          */
         trace("###################");
         trace("TinkTestrunnerUnitTest");
         trace("###################");
         TinkTestrunnerUnitTest.main();
      #end

      trace("###################");
      trace("UTestTest");
      trace("###################");
      UTestTest.main();

      trace("###################");
      trace("DocTestTest");
      trace("###################");
      DocTestTest.main();
   }
}
