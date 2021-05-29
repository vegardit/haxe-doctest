/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.tests;

import hx.doctest.DocTestGenerator;
import tink.testrunner.Batch;
import tink.testrunner.Runner;
import tink.testrunner.Suite;

/**
 * Performs doc-testing with Tink Testrunner.
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:build(hx.doctest.DocTestGenerator.generateDocTests({srcFolder:"test"}))
class TinkTestrunnerUnitTest extends Suite.BasicSuite {

   public static function main() {
      Runner.run(Batch.ofSuite(new TinkTestrunnerUnitTest()));
   }

   function new() {
      #if js @:nullSafety(Off) #end // TODO https://github.com/HaxeFoundation/haxe/issues/10275
      super({name: Type.getClassName(Type.getClass(this))}, []);
   }
}
