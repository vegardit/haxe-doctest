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
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class ExampleTools {
    
    /**
     * Returns a new array with size <b>times</b> filled with <b>item</b>.
     * <br/>
     * <b>Examples:</b>
     * <pre><code>
     * >>> ExampleTools.toArray("foo", 2)   == [ "foo", "foo" ]
     * >>> ExampleTools.toArray("foo", 1)   == [ "foo" ]
     * >>> ExampleTools.toArray("foo", 0)   == []
     * >>> ExampleTools.toArray(null, 0)    == []
     * >>> ExampleTools.toArray("", 0)      == []
     * </code></pre>
     */
    public static function toArray<T>(item:T, times:Int):Array<T> {
        var arr = [];
        for (i in 0...times) {
            arr.push(item);
        }
        return arr;
    }
    
    /**
     * <pre><code>
     * >>> ExampleTools.toPos(null, null) == { x:null, y:null }
     * >>> ExampleTools.toPos(1, 2)       == { x:1, y:2 }
     * >>> ExampleTools.toPos(1, 2)       == { y:2, x:1 }
     * </code></pre>
     */
    public static function toPos(x: Null<Int>, y: Null<Int>): { x:Null<Int>, y:Null<Int> } {
        return {
            x: x,
            y: y
        }
    }
}
