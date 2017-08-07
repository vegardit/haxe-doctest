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

using StringTools;
using hx.doctest.internal.DocTestUtils;

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
