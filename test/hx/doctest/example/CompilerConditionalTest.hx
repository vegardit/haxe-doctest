/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.example;

/**
 * Test of compiler conditionals with failing test assertions that should never be evaluated
 */
class CompilerConditionalTest {

   #if dummy1
      /**
       * <pre><code>
       * >>> true == false
       * </code></pre>
       */
   #elseif dummy2
      /**
       * <pre><code>
       * >>> true == false
       * </code></pre>
       */
   #elseif !dummy3
      /**
       * <pre><code>
       * >>> true == true
       * </code></pre>
       */
      #if dummy4
         /**
          * <pre><code>
          * >>> true == false
          * </code></pre>
          */
      #else
         /**
          * <pre><code>
          * >>> true == true
          * </code></pre>
          */
      #end
   #else
      /**
       * <pre><code>
       * >>> true == false
       * </code></pre>
       */
   #end


   #if !(dummy5 || dummy6)
      /**
       * <pre><code>
       * >>> true == true
       * </code></pre>
       */
   #else
      /**
       * <pre><code>
       * >>> true == false
       * </code></pre>
       */
   #end
}