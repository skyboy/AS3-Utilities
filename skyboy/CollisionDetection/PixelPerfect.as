package skyboy.CollisionDetection {
	/**
	 * PixelPerfect by skyboy. April 10th 2010.
	 * Visit http://github.com/skyboy for documentation, updates
	 * and more free code.
	 *
	 *
	 * Copyright (c) 2010 skyboy.
	 *
	 * Permission is hereby granted, free of charge, to any person
	 * obtaining a copy of this software and associated documentation
	 * files (the "Software"), to deal in the Software without
	 * restriction, including without limitation the rights to use,
	 * copy, modify, merge, publish, distribute, sublicense, and/or sell
	 * copies of the Software, and to permit persons to whom the
	 * Software is furnished to do so, subject to the following
	 * conditions:
	 *
	 * ^ Attribution will be given to:
	 *  	skyboy, http://www.kongregate.com/accounts/skyboy;
	 *  	http://github.com/skyboy
	 * ^ The above copyright notice and this permission notice shall be
	 * included in all copies or substantial portions of the Software.
	 *
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	 * OTHER DEALINGS IN THE SOFTWARE.
	 */
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * @author skyboy
	 */
	final public class PixelPerfect {
		protected static var root:DisplayObjectContainer, cTransformA:ColorTransform = new ColorTransform(1, 0, 0, 1, 255, 0, 0, 255), cTransformB:ColorTransform = new ColorTransform(0, 1, 0, 1, 0, 255, 0, 255), _lastRect:Rectangle = null;
		/**
		 * [read-only] rect: last Rectangle from a hitTest
		 */
		public function get rect():Rectangle {
			return _lastRect;
		}
		/**
		 * @param	_root: object to use as the root for testing
		 * @return	null
		 */
		public static function registerRoot(_root:DisplayObjectContainer):void {
			root = _root;
		}
		/**
		 * @param	tol: tolerance used for testing
		 * @return	null
		 */
		public static function setAlphaTolerance(tol:int = 255):void {
			cTransformA = new ColorTransform(1, 0, 0, 1, 255, 0, 0, tol);
			cTransformB = new ColorTransform(0, 1, 0, 1, 0, 255, 0, tol);
		}
		/**
		 * @param	objA: first object to test
		 * @param	objB: second object to test
		 * @return	Boolean: true if objA and objB are colliding
		 */
		public static function test(objA:DisplayObject, objB:DisplayObject):Boolean {
			if (objA.parent && objB.parent) {
				var oAB:Rectangle = objA.getBounds(root), oBB:Rectangle = objB.getBounds(root);
				if (((oAB.right < oBB.left) || (oBB.right < oAB.left)) || ((oAB.bottom < oBB.top) || (oBB.bottom < oAB.top))) {
					return false;
				}
				var boundRect:Rectangle = oAB.intersection(oBB), w:int = boundRect.width, h:int = boundRect.height;
				if (w && h) {
					var b:BitmapData = new BitmapData(w, h, true, 0), t:Number = -boundRect.top, l:Number = -boundRect.left;
					var aM:Matrix = objA.transform.matrix.clone(), bM:Matrix = objB.transform.matrix.clone();
					aM.translate(l, t), bM.translate(l, t);
					b.lock();
					b.draw(objA, aM, cTransformA);
					b.draw(objB, bM, cTransformB, "add");
					if ((_lastRect = b.getColorBoundsRect(0xffffffff, 0xffffff00, true)).width) {
						return true;
					}
				}
			}
			return false;
		}
		public static function hitRect(objA:DisplayObject, objB:DisplayObject):Rectangle {
			if (objA.parent && objB.parent) {
				var oAB:Rectangle = objA.getBounds(root), oBB:Rectangle = objB.getBounds(root);
				if (((oAB.right < oBB.left) || (oBB.right < oAB.left)) || ((oAB.bottom < oBB.top) || (oBB.bottom < oAB.top))) {
					return null;
				}
				var boundRect:Rectangle = oAB.intersection(oBB), w:int = boundRect.width, h:int = boundRect.height;
				if (w && h) {
					var b:BitmapData = new BitmapData(w, h, true, 0), t:Number = -boundRect.top, l:Number = -boundRect.left;
					var aM:Matrix = objA.transform.matrix.clone(), bM:Matrix = objB.transform.matrix.clone();
					aM.translate(l, t), bM.translate(l, t);
					b.lock();
					b.draw(objA, aM, cTransformA);
					b.draw(objB, bM, cTransformB, "add");
					var rect:Rectangle = _lastRect = b.getColorBoundsRect(0xffffffff, 0xffffff00, true);
					if (rect.width) {
						return rect;
					}
				}
			}
			return null;
		}
	}
}
