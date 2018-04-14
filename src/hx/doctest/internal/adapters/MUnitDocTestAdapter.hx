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
class MUnitDocTestAdapter extends DocTestAdapter {

    inline
    public function new() {
    }

    override
    public function getFrameworkName():String {
        return "massive.munit";
    }

    override
    public function generateTestFail(src:SourceFile, errorMsg:String):Expr {
        return macro {
            massive.munit.Assert.fail('${src.currentDocTestAssertion.assertion} --> $errorMsg', $v{src.currentDocTestAssertion.getPosInfos()});
        };
    }

    override
    public function generateTestSuccess(src:SourceFile):Expr {
        return macro {
            mconsole.Console.info('\n${src.fileName}:${src.currentLineNumber} [OK] ' + $v{src.currentDocTestAssertion.assertion});
        };
    }

    override
    public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
        var field = super.generateTestMethod(methodName, descr, assertions);
        field.meta.push({name: "Test", pos: Context.currentPos()});
        return field;
    }
}
