/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;
import hx.doctest.internal.DocTestAssertion;
import hx.doctest.internal.Either2;

@:noDoc @:dox(hide)
class TestrunnerDocTestAdapter extends DocTestAdapter {

   inline //
   public function new() {
   }


   override //
   public function getFrameworkName():String {
      return "hx.doctest";
   }


   override //
   public function generateTestFail(assertion:DocTestAssertion, errorMsg:Either2<String, ExprOf<String>>):Expr {
      final errorMsgExpr:ExprOf<String> = switch (errorMsg.value) {
         case a(str): macro {$v{str}};
         case b(expr): expr;
      }
      return macro {
         results.add(false, $v{'${assertion.expression} --> '} + $errorMsgExpr, cast $v{assertion.pos});
      };
   }


   override //
   public function generateTestSuccess(assertion:DocTestAssertion):Expr {
      return macro {
         results.add(true, $v{assertion.expression}, cast $v{assertion.pos});
      };
   }


   override //
   public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
      assertions.unshift(macro {
         final pos = { fileName: $v{Context.getLocalModule()}, lineNumber:1, className: $v{Context.getLocalClass().get().name}, methodName:"" };
         hx.doctest.internal.Logger.log(INFO, "**********************************************************", pos);
         hx.doctest.internal.Logger.log(INFO, $v{'$descr...'}, pos);
         hx.doctest.internal.Logger.log(INFO, "**********************************************************", pos);
      });

      return super.generateTestMethod(methodName, descr, assertions);
   }
}
