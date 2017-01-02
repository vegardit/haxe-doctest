/*
 * Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
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
