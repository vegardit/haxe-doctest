/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class TestrunnerDocTestAdapter extends DocTestAdapter {

    inline
    public function new() {
    }

    override
    public function getFrameworkName():String {
        return "hx.doctest";
    }

    override
    public function generateTestFail(src:SourceFile, errorMsg:String):Expr {
        return macro {
            results.add(false, '${src.currentDocTestAssertion.assertion} --> $errorMsg', $v{src.currentDocTestAssertion.getSourceLocation()}, null);
        };
    }

    override
    public function generateTestSuccess(src:SourceFile):Expr {
        return macro {
            results.add(true, '${src.currentDocTestAssertion.assertion}', null, $v{src.currentDocTestAssertion.getPosInfos(false)});
        };
    }

    override
    public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
        assertions.unshift(macro {
            var pos = { fileName: $v{Context.getLocalModule()}, lineNumber:1, className: $v{Context.getLocalClass().get().name}, methodName:"" };
            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
            hx.doctest.internal.Logger.log(INFO, '${descr}...', pos);
            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
        });

        return super.generateTestMethod(methodName, descr, assertions);
    }
}
