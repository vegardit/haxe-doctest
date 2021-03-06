/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Expr;
import hx.doctest.internal.DocTestAssertion;
import hx.doctest.internal.Either2;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class HaxeUnitDocTestAdapter extends DocTestAdapter {


   inline
   public function new() {
   }


   override
   public function getFrameworkName():String {
      return "haxe.unit";
   }


   override
   public function generateTestFail(assertion:DocTestAssertion, errorMsg:Either2<String, ExprOf<String>>):Expr {
      final errorMsgExpr:ExprOf<String> = switch(errorMsg.value) {
        case a(str): macro { $v{str} };
        case b(expr): expr;
      }
      return macro {
         currentTest.done = true;
         currentTest.success = false;
         currentTest.error = $v{'${assertion.expression} --> '} + $errorMsgExpr;
         currentTest.posInfos = cast $v{assertion.pos};
         throw currentTest;
      };
   }


   override
   public function generateTestSuccess(assertion:DocTestAssertion):Expr {
      return macro {
         currentTest.done = true;
         print($v{'\n${assertion.pos.fileName}:${assertion.pos.lineNumber} [OK] ${assertion.expression}'});
      };
   }
}
