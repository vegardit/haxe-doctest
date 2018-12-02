/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
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
class TestrunnerDocTestAdapter extends DocTestAdapter {

    inline
    public function new() {
    }

    override
    public function getFrameworkName():String {
        return "hx.doctest";
    }

    override
    public function generateTestFail(assertion:DocTestAssertion, errorMsg:String):Expr {
        return macro {
            results.add(false, '${assertion.expression} --> $errorMsg', $v{assertion.getSourceLocation()}, null);
        };
    }

    override
    public function generateTestSuccess(assertion:DocTestAssertion):Expr {
        return macro {
            results.add(true, '${assertion.expression}', null, $v{assertion.getPosInfos(false)});
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
