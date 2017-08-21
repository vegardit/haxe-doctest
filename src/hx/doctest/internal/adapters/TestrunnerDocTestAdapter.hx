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
