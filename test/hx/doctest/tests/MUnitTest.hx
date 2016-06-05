/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.tests;

import massive.munit.TestRunner;
import massive.munit.TestSuite;
import massive.munit.client.RichPrintClient;

/**
 * Performs doc-testing with MUnit.
 * 
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:keep
class MUnitTest extends TestSuite {

    public static function main() {
        var client = new RichPrintClient();
        var runner = new TestRunner(client);
        runner.run([MUnitTest]);
    }
    
    public function new() {
        super();
        
        add(MUnitDocTests);
    }
}

@:build(hx.doctest.DocTestGenerator.generateDocTests("test"))
class MUnitDocTests {

    public function new() {
    }

}


