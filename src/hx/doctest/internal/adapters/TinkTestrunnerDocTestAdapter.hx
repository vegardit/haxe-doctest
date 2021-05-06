/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:nullSafety
@:noDoc @:dox(hide)
class TinkTestrunnerDocTestAdapter extends DocTestAdapter {

   var testMethods:Array<String> = [];

   inline
   public function new() {
   }


   override
   public function getFrameworkName():String {
      return "tink.testrunner";
   }


   override
   public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
      testMethods.push(methodName);
      return super.generateTestMethod(methodName, descr, assertions);
   }


   override
   public function generateTestFail(assertion:DocTestAssertion, errorMsg:String):Expr {
      return macro {
         cases.push(new hx.doctest.internal.adapters.TinkTestrunnerDocTestAdapter.SingeAssertionCase(
            null,
            new tink.testrunner.Assertion(false, $v{'${assertion.expression} --> $errorMsg'}, cast $v{assertion.pos})
         ));
      };
   }


   override
   public function generateTestSuccess(assertion:DocTestAssertion):Expr {
      return macro {
         cases.push(new hx.doctest.internal.adapters.TinkTestrunnerDocTestAdapter.SingeAssertionCase(
            null,
            new tink.testrunner.Assertion(true, $v{assertion.expression}, cast $v{assertion.pos})
         ));
      };
   }


   override
   public function onFinish(contextFields:Array<Field>) {
      final exprs:Array<Expr> = [];
      for (testMethod in testMethods) {
         exprs.push(@:mergeBlock macro {
            $i{testMethod}();
         });
      }

      for (classMember in contextFields) {
         if (classMember.name == "new") {
             switch(classMember.kind) {
               case FFun(func):
                  exprs.unshift(func.expr);
                  func.expr = {expr: EBlock(exprs), pos:Context.currentPos()};
                  return;
               default:
            }
         }
      }
   }
}
#end


@:noDoc @:dox(hide)
class SingeAssertionCase extends tink.testrunner.Case.BasicCase {
   final assertion:tink.testrunner.Assertion;


   public function new(pos:haxe.PosInfos, assertion:tink.testrunner.Assertion) {
      super(pos);
      this.assertion = assertion;
   }


   override
   function execute():tink.testrunner.Assertions
      return assertion;
}
