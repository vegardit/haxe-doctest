/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;
using hx.doctest.internal.DocTestUtils;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class HaxeUnitDocTestAdapter extends DocTestAdapter {

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
