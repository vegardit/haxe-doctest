/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;
import hx.doctest.internal.Either2;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:nullSafety
@:noDoc @:dox(hide)
class UTestDocTestAdapter extends DocTestAdapter {


   inline
   public function new() {
   }


   override
   public function getFrameworkName():String {
      return "utest";
   }


   override
   public function generateTestFail(assertion:DocTestAssertion, errorMsg:Either2<String, ExprOf<String>>):Expr {
      final errorMsgExpr:ExprOf<String> = switch(errorMsg.value) {
        case a(str): macro { $v{str} };
        case b(expr): expr;
      }
      return macro {
         utest.Assert.fail($v{'${assertion.expression} --> '} + $errorMsgExpr, cast $v{assertion.pos});
      };
   }


   override
   public function generateTestSuccess(assertion:DocTestAssertion):Expr {
      return macro {
         utest.Assert.pass($v{'${assertion.pos.fileName}:${assertion.pos.lineNumber} [OK] ${assertion.expression}'}, cast $v{assertion.pos});
      };
   }


   override
   public function onFinish(contextFields:Array<Field>) {
      final cls = Context.getLocalClass().get();
      cls.meta.remove(":utestProcessed");
      for (f in contextFields) {
         if (f.name == "__initializeUtest__") {
            contextFields.remove(f);
            break;
         }
      }
   }
}
