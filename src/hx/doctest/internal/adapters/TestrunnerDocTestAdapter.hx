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
class TestrunnerDocTestAdapter extends DocTestAdapter {

    public function new() {
        
    }

    override
    public function getFrameworkName():String {
        return "hx.doctest";
    }
    
    override
    public function generateTestFail(src:SourceFile, errorMsg:String):Expr {
        return macro {
            testsFailed.push(
                hx.doctest.internal.Logger.log(ERROR, 
                    '${src.currentDocTestAssertion.assertion} --> $errorMsg',
                    $v{src.currentDocTestAssertion.getSourceLocation()}
                )
            );
        };
    }
    
    override
    public function generateTestSuccess(src:SourceFile):Expr {
        return macro {
            haxe.Log.trace('[OK] ${src.currentDocTestAssertion.assertion}', $v{src.currentDocTestAssertion.getPosInfos(false)});
            testsOK++;
        };
    }

    override
    public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
        assertions.unshift(macro {
            var pos = { fileName:  $v{Context.getLocalModule()}, lineNumber: 1, className: $v{Context.getLocalClass().get().name}, methodName:"" };
            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
            hx.doctest.internal.Logger.log(INFO, '${descr}...', pos);
            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
        });

        return super.generateTestMethod(methodName, descr, assertions);
    }
}
