/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.example;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class ExampleEntity {

    /**
     * <pre><code>
     * >>> new ExampleEntity(null).name    == null
     * >>> new ExampleEntity("").name      == ""
     * >>> new ExampleEntity(" ").name     == " "
     * >>> new ExampleEntity(" foo ").name == " foo "
     * </code></pre>
     */
    public var name(default, null):String;
    
    public function new(name:String) {
        this.name = name;
    }

    /**
     * Checks if the name property is valid.
     * <br/>
     * <b>Examples:</b>
     * <pre><code>
     * >>> new ExampleEntity(null).isValidName()    == false
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
     * >>> new ExampleEntity(null).toString()    == 'ExampleEntity[name=null]'
     * >>> new ExampleEntity("").toString()      == 'ExampleEntity[name=]'
     * >>> new ExampleEntity(" ").toString()     == 'ExampleEntity[name= ]'
     * >>> new ExampleEntity(" foo ").toString() == 'ExampleEntity[name= foo ]'
     * </code></pre>
     */
    public function toString() {
        return 'ExampleEntity[name=$name]';
    }
}
