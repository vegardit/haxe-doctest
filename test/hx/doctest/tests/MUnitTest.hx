/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.tests;

import massive.munit.TestRunner;
import massive.munit.TestSuite;
import massive.munit.client.RichPrintClient;

/**
 * Performs doc-testing with MUnit.
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

@:build(hx.doctest.DocTestGenerator.generateDocTests({srcFolder:"test"}))
class MUnitDocTests {

   public function new() {
   }
}
