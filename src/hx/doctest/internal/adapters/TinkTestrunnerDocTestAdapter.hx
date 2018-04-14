/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;

#if macro

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class TinkTestrunnerDocTestAdapter extends DocTestAdapter {

    var testMethods:Array<String> = [];

    inline
    public function new() {
    }


    override
    public function getFrameworkName():String {
        return "tink.testrunner";
    }


    override
    public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
        testMethods.push(methodName);
        return super.generateTestMethod(methodName, descr, assertions);
    }

    override
    public function generateTestFail(src:SourceFile, errorMsg:String):Expr {
        return macro {
            cases.push(new hx.doctest.internal.adapters.TinkTestrunnerDocTestAdapter.SingeAssertionCase(
                null,
                new tink.testrunner.Assertion(
                    false,
                    '${src.currentDocTestAssertion.assertion} --> $errorMsg',
                    $v{src.currentDocTestAssertion.getPosInfos()}
                ))
            );
        };
    }

    override
    public function generateTestSuccess(src:SourceFile):Expr {
        return macro {
            cases.push(new hx.doctest.internal.adapters.TinkTestrunnerDocTestAdapter.SingeAssertionCase(
                null,
                new tink.testrunner.Assertion(
                    true,
                    $v{src.currentDocTestAssertion.assertion},
                    $v{src.currentDocTestAssertion.getPosInfos()}
                ))
            );
        };
    }

    override
    public function onFinish(contextFields:Array<Field>) {

        var exprs:Array<Expr> = [];
        for (testMethod in testMethods) {
            exprs.push(@:mergeBlock macro {
                $i{testMethod}();
            });
        }

        for (classMember in contextFields) {
            if (classMember.name == "new") {
                switch(classMember.kind) {
                    case FFun(func):
                        exprs.unshift(func.expr);
                        func.expr = {expr: EBlock(exprs), pos:Context.currentPos()};
                        return;
                    default:
                }
            }
        }
    }
}
#end


@:noDoc @:dox(hide)
class SingeAssertionCase extends tink.testrunner.Case.BasicCase {
    private var assertion:tink.testrunner.Assertion;

    public function new(pos:haxe.PosInfos, assertion:tink.testrunner.Assertion) {
        super(pos);
        this.assertion = assertion;
    }
    override
    function execute():tink.testrunner.Assertions
        return assertion;
}

