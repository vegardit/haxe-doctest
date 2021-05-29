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
@:abstract
class DocTestAdapter {

   public function getFrameworkName():String
      throw "Not implemented";


   public function generateTestFail(assertion:DocTestAssertion, errorMsg:Either2<String, ExprOf<String>>):Expr
      throw "Not implemented";


   public function generateTestSuccess(assertion:DocTestAssertion):Expr
      throw "Not implemented";


   public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
      final contextPos = Context.currentPos();
      final meta = [{name: ":keep", pos: contextPos}];
      return {
         name: methodName,
         doc: descr,
         meta: meta,
         access: [APublic],
         kind: FFun({
            ret: null,
            args: [],
            expr: {expr: EBlock(assertions), pos: contextPos}
         }),
         pos: contextPos
      };
   }


   public function onFinish(contextFields:Array<Field>):Void {
   }
}
