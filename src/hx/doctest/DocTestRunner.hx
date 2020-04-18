/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest;

import haxe.PosInfos;
import haxe.Timer;
import hx.doctest.internal.Either2;
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
    *
    * @return number of failing tests
    */
   function run(expectedMinNumberOfTests = 0, logSummary:Bool = true):Int {
      if (results == null)
         results = new DefaultDocTestResults();

      final startTime = Timer.stamp();
      final thisClass = Type.getClass(this);
      final thisClassName = Type.getClassName(thisClass);

      /*
       * look for functions starting with "test" and invoke them
       */
      Logger.log(INFO, 'Looking for test cases in [${thisClassName}]...');
      final funcNames = new Array<String>();
      for (funcName in Type.getInstanceFields(thisClass)) {
         if (funcName.startsWith("test"))
            funcNames.push(funcName);
      }
      funcNames.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);
      for (funcName in funcNames) {
         final func:Dynamic = Reflect.field(this, funcName);
         if (Reflect.isFunction(func)) {
            Logger.log(INFO, "**********************************************************");
            Logger.log(INFO, 'Invoking [${thisClassName}#$funcName()]...');
            Logger.log(INFO, "**********************************************************");
            Reflect.callMethod(this, func, []);
         }
      }

      final timeSpent:Float = Math.round(1000 * (Timer.stamp() - startTime)) / 1000;
      final testsOK = results.getSuccessCount();
      final testsFailed = results.getFailureCount();
      if (testsFailed == 0) {
         if (expectedMinNumberOfTests > 0 && testsOK < expectedMinNumberOfTests) {
            Logger.log(ERROR, "**********************************************************");
            Logger.log(ERROR, '$expectedMinNumberOfTests tests expected but only $testsOK found!');
            Logger.log(ERROR, "**********************************************************");
            return 1;
         } else if (testsOK == 0) {
            Logger.log(WARN, "**********************************************************");
            Logger.log(WARN, 'No test assertions were found!');
            Logger.log(WARN, "**********************************************************");
         } else {
            if (logSummary) {
               Logger.log(INFO, "**********************************************************");
               Logger.log(INFO, 'All $testsOK test(s) were SUCCESSFUL within $timeSpent seconds.');
               Logger.log(INFO, "**********************************************************");
            }
         }
         return 0;
      }

      if (logSummary) {
         Logger.log(ERROR, "**********************************************************");
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
      final exitCode = run(expectedMinNumberOfTests) == 0 ? 0 : 1;
      exit(exitCode);
   }


   /**
    * for use within manually created test method
    */
   function assertSame(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
      results.add(leftResult == rightResult, 'assertSame($leftResult, $rightResult)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertEquals(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
      results.add(DocTestUtils.deepEquals(leftResult, rightResult), 'assertEquals($leftResult, $rightResult)', pos);
   }


   /**
    * for use within manually created test method
    */
    function assertFalse(result:Bool, ?pos:PosInfos):Void {
      results.add(!result, 'assertFalse($result)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertMax(result:Int, max:Int, ?pos:PosInfos):Void {
      results.add(result <= max, 'assertMax($result, $max)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertMin(result:Int, min:Int, ?pos:PosInfos):Void {
      results.add(result >= min, 'assertMin($result, $min)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertInRange(result:Int, min:Int, max:Int, ?pos:PosInfos):Void {
      results.add(result >= min && result <= max, 'assertInRange($result, $min, $max)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertNotSame(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
      results.add(leftResult != rightResult, 'assertNotSame($leftResult, $rightResult)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertNotEquals(leftResult:Dynamic, rightResult:Dynamic, ?pos:PosInfos):Void {
      results.add(!DocTestUtils.deepEquals(leftResult, rightResult), 'assertNotEquals($leftResult, $rightResult)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertTrue(result:Bool, ?pos:PosInfos):Void {
      results.add(result, 'assertTrue($result)', pos);
   }


   /**
    * for use within manually created test method
    */
   function fail(?msg:String, ?pos:PosInfos):Void {
      if (msg == null) msg = "This code location should not never be reached.";
      results.add(false, msg, pos);
   }
}


interface DocTestResults {
   function add(success:Bool, msg:String, pos:Either2<SourceLocation,haxe.PosInfos>):Void;
   function getSuccessCount():Int;
   function getFailureCount():Int;
   function logFailures():Void;
}


class DefaultDocTestResults implements DocTestResults {

   var _testsPassed = 0;
   final _testsFailed = new Array<LogEvent>();


   inline
   public function new() {
   }


   public function add(success:Bool, msg:String, pos:Either2<SourceLocation,haxe.PosInfos>) {
      if (success) {
         var event = new LogEvent(OK, msg, pos);
         event.log(false);
         _testsPassed++;
      } else {
         var event = new LogEvent(ERROR, msg, pos);
         event.log(false);
         _testsFailed.push(event);
      }
   }


   public function getSuccessCount():Int
      return _testsPassed;


   public function getFailureCount():Int
      return _testsFailed.length;


   public function logFailures():Void {
      for (event in _testsFailed)
         event.log(true);
   }


   public function toString():String
      return 'DocTestResults[successCount=${getSuccessCount()}, failureCount=${getFailureCount()}]';
}
