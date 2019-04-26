/*
 * Copyright (c) 2016-2019 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.tests;

import utest.ITest;
import utest.Test;
import utest.Runner;
import utest.ui.Report;
import utest.UTest;

/**
 * Performs doc-testing with UTest.
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:build(hx.doctest.DocTestGenerator.generateDocTests("test"))
@:build(utest.utils.TestBuilder.build())
class UTestTest extends Test {

    public static function main() {
        utest.UTest.run([new UTestTest()]);
    }

    @:keep
    public function new() {
       super();
    }
}
