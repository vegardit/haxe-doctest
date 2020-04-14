/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.tests;

/**
 * Performs doc-testing with UTest.
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:build(hx.doctest.DocTestGenerator.generateDocTests({srcFolder:"test"}))
@:build(utest.utils.TestBuilder.build())
class UTestTest extends utest.Test {

    public static function main() {
        var runner = new utest.Runner();
        runner.addCase(new UTestTest());
        new PrintReportNoExit(runner);
        runner.run();
    }

    @:keep
    public function new() {
       super();
    }
}

class PrintReportNoExit extends utest.ui.text.PrintReport {

    public function new(runner:utest.Runner) {
        super(runner);
    }

    override
    function complete(result:utest.ui.common.PackageResult) {
        this.result = result;
        if (handler != null) handler(this);
    }
}
