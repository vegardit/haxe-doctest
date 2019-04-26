/*
 * Copyright (c) 2016-2019 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;
import hx.doctest.internal.DocTestAssertion;

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
    public function generateTestFail(assertion:DocTestAssertion, errorMsg:String):Expr {
        return macro {
            massive.munit.Assert.fail('${assertion.expression} --> $errorMsg', $v{assertion.getPosInfos()});
        };
    }

    override
    public function generateTestSuccess(assertion:DocTestAssertion):Expr {
        return macro {
            mconsole.Console.info('\n${assertion.file.fileName}:${assertion.lineNumber} [OK] ' + $v{assertion.expression});
        };
    }

    override
    public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
        var field = super.generateTestMethod(methodName, descr, assertions);
        field.meta.push({name: "Test", pos: Context.currentPos()});
        return field;
    }
}
