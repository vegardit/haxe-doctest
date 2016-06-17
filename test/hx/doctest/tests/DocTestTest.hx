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
        runner.runAndExit(20 /* number of expected test cases */);
    }
    
    function new() {
        super();
    }
    
    /**
     * Manually added test method to do some additional non-doctest based testing
     */
    @:keep
    function testManual() {
        assertEquals("a", "a");
        try {
            var s:String = null;
            s.toLowerCase(); // throws NPE ... except on PHP
            #if !php
            fail(); // should never be reached
            #end
        } catch (e:Dynamic) {
            // expected
        }
    }
}
