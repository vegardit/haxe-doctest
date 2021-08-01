/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest;

import haxe.PosInfos;
import haxe.Timer;

import hx.doctest.internal.DocTestUtils;
import hx.doctest.internal.Logger;

using StringTools;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:abstract
class DocTestRunner {

   static function exit(exitCode:Int):Void {
      #if travix
         travix.Logger.exit(exitCode);
      #else
         #if sys
            Sys.exit(exitCode);
         #elseif js
            var isPhantomJSDirectExecution = js.Syntax.code("(typeof phantom !== 'undefined')");
            if (isPhantomJSDirectExecution)
               js.Syntax.code("phantom.exit(exitCode)");
            else {
               var isPhantomJSWebPage = js.Syntax.code("!!(typeof window != 'undefined' && window.callPhantom && window._phantom)");
               if (isPhantomJSWebPage)
                  js.Syntax.code("window.callPhantom({cmd:'doctest:exit', 'exitCode':exitCode})");
               else
                  js.Syntax.code("process.exit(exitCode)"); // nodejs
            }
         #elseif flash
            flash.system.System.exit(exitCode);
         #end
      #end
   }


   var results:DocTestResults;


   public function new() {
      results = new DefaultDocTestResults(this);
   }


   /**
    * Runs the accumulated doc tests.
    *
    * @return number of failing tests
    */
   function run(expectedMinNumberOfTests = 0, logTestExecutions = true, logTestSummary = true):Int {
      final startTime = Timer.stamp();
      #if js @:nullSafety(Off) #end // TODO https://github.com/HaxeFoundation/haxe/issues/10275
      final thisClass = Type.getClass(this);
      final thisClassName = Type.getClassName(thisClass);

      final prevMaxLevel = Logger.maxLevel;
      if(!logTestExecutions)
         Logger.maxLevel = Level.OFF;

      /*
       * look for functions starting with "test" and invoke them
       */
      Logger.log(DEBUG, 'Looking for test cases in [${thisClassName}]...');
      final funcNames = [ for (funcName in Type.getInstanceFields(thisClass)) if (funcName.startsWith("test")) funcName ];
      funcNames.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);
      for (funcName in funcNames) {
         final func:Null<Dynamic> = Reflect.field(this, funcName);
         if (func != null && Reflect.isFunction(func)) {
            Logger.log(DEBUG, "**********************************************************");
            Logger.log(DEBUG, 'Invoking [${thisClassName}#$funcName()]...');
            Logger.log(DEBUG, "**********************************************************");
            Reflect.callMethod(this, func, []);
         }
      }

      Logger.maxLevel = prevMaxLevel;

      final timeSpent:Float = Math.round(1000 * (Timer.stamp() - startTime)) / 1000;
      final testsPassed = results.testsPassed;
      final testsFailed = results.testsFailed;

      if (testsFailed == 0) {
         if (testsPassed < expectedMinNumberOfTests) {
            Logger.log(ERROR, "**********************************************************");
            Logger.log(ERROR, '$expectedMinNumberOfTests tests expected but only $testsPassed found!', DocTestUtils.currentPos());
            Logger.log(ERROR, "**********************************************************");
            return 1;
         }

         if (testsPassed == 0) {
            Logger.log(WARN, "**********************************************************");
            Logger.log(WARN, 'No test assertions were found!');
            Logger.log(WARN, "**********************************************************");
         } else if (logTestSummary) {
            Logger.log(INFO, "**********************************************************");
            Logger.log(INFO, 'All $testsPassed test(s) PASSED within $timeSpent seconds.');
            Logger.log(INFO, "**********************************************************");
         }
         return 0;
      }

      if (logTestSummary) {
         Logger.log(ERROR, "**********************************************************");
         Logger.log(ERROR, '$testsFailed of ${testsPassed + testsFailed} test(s) FAILED:');
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
   @:nullSafety(Off) // TODO https://github.com/HaxeFoundation/haxe/issues/10272
   function assertEquals(leftResult:Null<Dynamic>, rightResult:Null<Dynamic>, ?pos:PosInfos):Void
      results.add(DocTestUtils.deepEquals(leftResult, rightResult), 'assertEquals($leftResult, $rightResult)', pos);


   /**
    * for use within manually created test method
    */
   function assertFalse(result:Bool, ?pos:PosInfos):Void {
      if(pos == null) throw '[pos] must not be null';
      results.add(!result, 'assertFalse($result)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertInRange(result:Int, min:Int, max:Int, ?pos:PosInfos):Void {
      if(pos == null) throw '[pos] must not be null';

      results.add(result >= min && result <= max, 'assertInRange($result, $min, $max)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertMax(result:Int, max:Int, ?pos:PosInfos):Void {
      if(pos == null) throw '[pos] must not be null';
      results.add(result <= max, 'assertMax($result, $max)', pos);
   }


   /**
    * for use within manually created test method
    */
   function assertMin(result:Int, min:Int, ?pos:PosInfos):Void {
      if(pos == null) throw '[pos] must not be null';
      results.add(result >= min, 'assertMin($result, $min)', pos);
   }


   /**
    * for use within manually created test method
    */
   @:nullSafety(Off) // TODO https://github.com/HaxeFoundation/haxe/issues/10272
   function assertNotSame(leftResult:Null<Dynamic>, rightResult:Null<Dynamic>, ?pos:PosInfos):Void
      results.add(leftResult != rightResult, 'assertNotSame($leftResult, $rightResult)', pos);


   /**
    * for use within manually created test method
    */
   @:nullSafety(Off) // TODO https://github.com/HaxeFoundation/haxe/issues/10272
   function assertNotEquals(leftResult:Null<Dynamic>, rightResult:Null<Dynamic>, ?pos:PosInfos):Void
      results.add(!DocTestUtils.deepEquals(leftResult, rightResult), 'assertNotEquals($leftResult, $rightResult)', pos);


   /**
    * for use within manually created test method
    */
   @:nullSafety(Off) // TODO https://github.com/HaxeFoundation/haxe/issues/10272
   function assertSame(leftResult:Null<Dynamic>, rightResult:Null<Dynamic>, ?pos:PosInfos):Void
      results.add(leftResult == rightResult, 'assertSame($leftResult, $rightResult)', pos);


   /**
    * for use within manually created test method
    */
   function assertTrue(result:Bool, ?pos:PosInfos):Void {
      if(pos == null) throw '[pos] must not be null';
      results.add(result, 'assertTrue($result)', pos);
   }


   /**
    * for use within manually created test method
    */
   function fail(msg:String = "This code location should not never be reached.", ?pos:PosInfos):Void {
      if(pos == null) throw '[pos] must not be null';
      results.add(false, msg, pos);
   }


   @:allow(hx.doctest.DocTestResults)
   function onDocTestResult(result:DocTestResult) {
      var pos:PosInfosExt = {
         fileName: DocTestUtils.getFileName(result.pos.fileName), // only display file name
         lineNumber: result.pos.lineNumber,
         className: result.pos.className,
         methodName: result.pos.methodName,
         customParams: result.pos.customParams,
         charStart: null, // don't display character range
         charEnd: null // don't display character range
      }
      Logger.log(result.testPassed ? OK : ERROR, result.msg, pos);
   }
}


interface DocTestResults {

   var tests(default, null):Array<DocTestResult>;
   var testsPassed(default, null):Int;
   var testsFailed(default, null):Int;

   function add(success:Bool, msg:String, pos:haxe.PosInfos):Void;

   /**
    * @deprecated use `DocTestResults#testsFailed`
    */
   @:deprecated
   function getFailureCount():Int;

   /**
    * @deprecated use `DocTestResults#testsPassed`
    */
   @:deprecated
   function getSuccessCount():Int;

   /**
    * Logs all test failures using `haxe.Log.trace()`, except for test failures on **sys**
    * targets where `Sys.stderr()` is used.
    */
   function logFailures():Void;
}


class DocTestResult {
   public final date = Date.now();
   public final testPassed:Bool;
   public final msg:String;
   public final pos:PosInfosExt;


   public function new(testPassed:Bool, msg:String, pos:haxe.PosInfos) {
      this.testPassed = testPassed;
      this.msg = msg;
      this.pos = cast pos;
   }


   public function toString():String {
      return
         '${pos.fileName}:${pos.lineNumber}: ' +
         (pos.charStart == null ? "" : 'characters ${pos.charStart}-${pos.charEnd}: ') +
         '[${testPassed ? "OK" : "ERROR"}] $msg';
   }
}


class DefaultDocTestResults implements DocTestResults {

   public var testsPassed(default, null) = 0;
   public var testsFailed(default, null) = 0;
   public var tests(default, null):Array<DocTestResult> = [];

   final runner:DocTestRunner;


   public function new(runner:DocTestRunner)
      this.runner = runner;


   public function add(success:Bool, msg:String, pos:haxe.PosInfos):Void {
      final result = new DocTestResult(success, msg, pos);
      if (success)
         testsPassed++;
      else
         testsFailed++;
      tests.push(result);
      runner.onDocTestResult(result);
   }


   @:deprecated
   public function getFailureCount():Int return testsFailed;


   @:deprecated
   public function getSuccessCount():Int return testsFailed;


   public function logFailures():Void
      for (result in tests)
         if (!result.testPassed)
            Logger.log(ERROR, result.msg, result.pos);


   public function toString():String
      return 'DocTestResults[successCount=${testsPassed}, failureCount=${testsFailed}]';
}
