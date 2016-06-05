/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.tests;

import hx.doctest.DocTestRunner;

/**
 * Performs doc-testing with DocTestRunner.
 * 
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:build(hx.doctest.DocTestGenerator.generateDocTests("test"))
class DocTestTest extends DocTestRunner {

    public static function main() {
        var runner = new DocTestTest();
        runner.runAndExit();
    }
    
    function new() {
        super();
    }
}
