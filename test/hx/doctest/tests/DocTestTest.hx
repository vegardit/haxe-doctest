/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
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
        runner.runAndExit(23 /* number of expected test cases */);
    }

    function new() {
        super();
    }

    /**
     * Manually added test method to do some additional non-doctest based testing
     */
    function testManual() {
        assertEquals("a", "a");
        try {
            /*
             * assigning null not on first assignment to make code work in Lua, otherwise
             * the block will be transpiled into `nil:toLowerCase()` which doesn't compile in Lua
             */
            var s = "";
            s = null;
            s = s.toLowerCase(); // throws NPE ... except on PHP and C++
            #if (!php && !cpp)
            fail(); // should never be reached
            #end
        } catch (e:Dynamic) {
            // expected
        }
    }
}
