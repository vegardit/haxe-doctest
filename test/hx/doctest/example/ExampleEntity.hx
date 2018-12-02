/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.example;

/**
 * <pre><code>
 * >>> (switch(1){default:var e = new ExampleEntity("foo"); e.name="bar"; e; }).name   == "bar"
 * >>> (function(){var e = new ExampleEntity("dog"); e.name="cat"; return e; })().name == "cat"
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
     * >>> new ExampleEntity(null)  throws ~/must not be null/
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
