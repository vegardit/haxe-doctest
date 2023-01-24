/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

import hx.doctest.internal.Either2;

@:noDoc @:dox(hide)
class TinkTestrunnerDocTestAdapter extends DocTestAdapter {

   final testMethods:Array<String> = [];

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
   public function generateTestFail(assertion:DocTestAssertion, errorMsg:Either2<String, ExprOf<String>>):Expr {
      final errorMsgExpr:ExprOf<String> = switch(errorMsg.value) {
        case a(str): macro { $v{str} };
        case b(expr): expr;
      }
      return macro {
         cases.push(new hx.doctest.internal.adapters.TinkTestrunnerDocTestAdapter.SingeAssertionCase(
            null,
            new tink.testrunner.Assertion(false, $v{'${assertion.expression} --> '} + $errorMsgExpr, cast $v{assertion.pos})
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
             switch (classMember.kind) {
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


   public function new(pos:Null<haxe.PosInfos>, assertion:tink.testrunner.Assertion) {
      super(pos);
      this.assertion = assertion;
   }


   override
   function execute():tink.testrunner.Assertions
      return assertion;
}
