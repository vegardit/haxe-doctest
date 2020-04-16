/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Expr;
import hx.doctest.internal.DocTestAssertion;


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
   public function generateTestFail(assertion:DocTestAssertion, errorMsg:String):Expr {
      return macro {
         currentTest.done = true;
         currentTest.success = false;
         currentTest.error = '${assertion.expression} --> $errorMsg';
         currentTest.posInfos = $v{assertion.getPosInfos()};
         throw currentTest;
      };
   }


   override
   public function generateTestSuccess(assertion:DocTestAssertion):Expr {
      return macro {
         currentTest.done = true;
         print('\n${assertion.file.fileName}:${assertion.lineNumber} [OK] ' + $v{assertion.expression});
      };
   }
}
