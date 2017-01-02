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
package hx.doctest.example;

/**
 * <pre><code>
 * >>> (switch(1){default:var e:ExampleEntity = new ExampleEntity("foo"); e.name="bar"; e;}).name == "bar"
 * </code></pre>
 * 
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class ExampleEntity {

    /**
     * <pre><code>
     * >>> new ExampleEntity("").name      == ""
     * >>> new ExampleEntity(" ").name     == " "
     * >>> new ExampleEntity(" foo ").name == " foo "
     * </code></pre>
     */
    public var name:String;
    
    /**
     * <pre>code>
     * >>> new ExampleEntity(null)  throws "[name] must not be null"
     * >>> new ExampleEntity("foo") throws nothing
     * </code></pre>
     */
    public function new(name:String) {
        if (name == null)
            throw "[name] must not be null";
        this.name = name;
    }

    /**
     * Checks if the name property is valid.
     * <br/>
     * <b>Examples:</b>
     * <pre><code>
     * >>> new ExampleEntity("").isValidName()      == false
     * >>> new ExampleEntity(" ").isValidName()     == false
     * >>> new ExampleEntity(" foo ").isValidName() == true
     * </code></pre>
     */
    public function isValidName():Bool {
        return name != null && StringTools.trim(name).length > 0;
    }

    /**
     * Checks if the name property is valid.
     * <br/>
     * <b>Examples:</b>
     * <pre><code>
     * >>> new ExampleEntity("").toString()      == 'ExampleEntity[name=]'
     * >>> new ExampleEntity(" ").toString()     == 'ExampleEntity[name= ]'
     * >>> new ExampleEntity(" foo ").toString() == 'ExampleEntity[name= foo ]'
     * </code></pre>
     */
    public function toString() {
        return 'ExampleEntity[name=$name]';
    }
}
