/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;
import hx.doctest.internal.DocTestAssertion;
import hx.doctest.internal.Either2;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class MUnitDocTestAdapter extends DocTestAdapter {


   inline
   public function new() {
   }


   override
   public function getFrameworkName():String {
      return "massive.munit";
   }


   override
   public function generateTestFail(assertion:DocTestAssertion, errorMsg:Either2<String, ExprOf<String>>):Expr {
      final errorMsgExpr:ExprOf<String> = switch(errorMsg.value) {
        case a(str): macro { $v{str} };
        case b(expr): expr;
      }
      return macro {
         massive.munit.Assert.fail($v{'${assertion.expression} --> '} + $errorMsgExpr, cast $v{assertion.pos});
      };
   }


   override
   public function generateTestSuccess(assertion:DocTestAssertion):Expr {
      return macro {
         mconsole.Console.info($v{'\n${assertion.pos.fileName}:${assertion.pos.lineNumber} [OK] ${assertion.expression}'});
      };
   }


   override
   public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
      final field = super.generateTestMethod(methodName, descr, assertions);
      field.meta.push({name: "Test", pos: Context.currentPos()});
      return field;
   }
}
