/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

final class NullAnalysisHelper {

   public static function asNonNull<T>(val:Null<T>):T {
      @:nullSafety(Off)
      return val;
   }


   public static function lazyNonNull<T>():T {
      @:nullSafety(Off)
      return null;
   }


   private function new() {
   }
}
