/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, http://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Expr;


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
    public function generateTestFail(src:SourceFile, errorMsg:String):Expr {
        return macro {
            currentTest.done = true;
            currentTest.success = false;
            currentTest.error = '${src.currentDocTestAssertion.assertion} --> $errorMsg';
            currentTest.posInfos = $v{src.currentDocTestAssertion.getPosInfos()};
            throw currentTest;
        };
    }

    override
    public function generateTestSuccess(src:SourceFile):Expr {
        return macro {
            currentTest.done = true;
            print('\n${src.fileName}:${src.currentLineNumber} [OK] ' + $v{src.currentDocTestAssertion.assertion});
        };
    }
}
