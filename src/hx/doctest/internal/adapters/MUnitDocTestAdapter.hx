/*
 * Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:dox(hide)
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
