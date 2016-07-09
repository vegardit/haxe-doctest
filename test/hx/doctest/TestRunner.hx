/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
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
package hx.doctest;

import hx.doctest.tests.*;

/**
 * Main entry point to test doctest.
 * 
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class TestRunner {
  public function new() { }
  
	public static function main() {
        
        HaxeUnitTest.main();
        
        #if !(php || flash || js)
        /*
         * MUnit seems broken on some platforms:
         * 
         * 1) fails on PHP with:   munit/2,1,2/massive/munit/TestRunner.hx:384: characters 16-27 : Class<massive.munit.util.Timer> has no field delay
         * 
         * 2) fails on Flash with: hx/doctest/tests/MUnitTest.hx:9: characters 7-31 : Type not found : massive.munit.TestRunner
         * 
         * 3) fails on JS with:
         *   ReferenceError: Can't find variable: addToQueue
         *     undefined:1 in eval code
         *     :0 in eval
         *     phantomjs://code/TestRunner.js:2902 in queue
         *     phantomjs://code/TestRunner.js:2868 in createTestClass
         *     phantomjs://code/TestRunner.js:2954 in initializeTestClass
         *     phantomjs://code/TestRunner.js:2594 in setCurrentTestClass
         *     phantomjs://code/TestRunner.js:2367 in executeTestCases
         *     phantomjs://code/TestRunner.js:2334 in execute
         *     phantomjs://code/TestRunner.js:2320 in run
         *     phantomjs://code/TestRunner.js:1194 in main
         */
        MUnitTest.main();
        #end
        
        DocTestTest.main();
    }

}
