/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.tests;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import hx.doctest.DocTestGenerator;

/**
 * Performs doc-testing with Haxe Unit.
 */
@:build(hx.doctest.DocTestGenerator.generateDocTests({srcFolder:"test"}))
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
