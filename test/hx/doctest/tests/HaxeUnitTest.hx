/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.tests;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import hx.doctest.DocTestGenerator;

/**
 * Performs doc-testing with Haxe Unit.
 * 
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:build(hx.doctest.DocTestGenerator.generateDocTests("test"))
class HaxeUnitTest extends TestCase {

    public static function main() {
        var runner = new TestRunner();
        runner.add(new HaxeUnitTest());
        runner.run();
    }
    
    function new() {
        super();
    }
    
}
