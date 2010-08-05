package skyboy.CollisionDetection {
	/**
	 * PixelPerfect by skyboy. April 10th 2010.
	 * Visit http://github.com/skyboy for documentation, updates
	 * and more free code.
	 *
	 *
	 * Copyright (c) 2010, skyboy
	 *    All rights reserved.
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
	 *  	http://github.com/skyboy; http://skybov.deviantart.com
	 *
	 * ^ Redistributions of source code must retain the above copyright notice,
	 * this list of conditions and the following disclaimer in all copies or
	 * substantial portions of the Software.
	 *
	 * ^ Redistributions of modified source code must be marked as such, with
	 * the modifications marked and ducumented and the modifer's name clearly
	 * listed as having modified the source code.
	 *
	 * ^ Redistributions of source code may not add to, subtract from, or in
	 * any other way modify the above copyright notice, this list of conditions,
	 * or the following disclaimer for any reason.
	 *
	 * ^ Redistributions in binary form must reproduce the above copyright
	 * notice, this list of conditions and the following disclaimer in the
	 * documentation and/or other materials provided with the distribution.
	 *
	 * THE SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
	 * IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
	 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
	 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
	 * OR COPYRIGHT HOLDERS OR CONTRIBUTORS  BE LIABLE FOR ANY CLAIM, DIRECT,
	 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	 * OR OTHER LIABILITY,(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
	 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	 * WHETHER AN ACTION OF IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	 * NEGLIGENCE OR OTHERWISE) ARISING FROM, OUT OF, IN CONNECTION OR
	 * IN ANY OTHER WAY OUT OF THE USE OF OR OTHER DEALINGS WITH THIS
	 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
		/**
		 * @param	root: object to use as the root for testing
		 * @param	tol: alpha tolerance used for testing
		 */
		public function PixelPerfect(root:DisplayObject = null, tol:int = 255) {
			_root = root;
			transformA = new ColorTransform(1, 0, 0, 1, 255, 0, 0, tol);
			transformB = new ColorTransform(0, 1, 0, 1, 0, 255, 0, tol);
		}
		protected static var root:DisplayObjectContainer, cTransformA:ColorTransform = new ColorTransform(1, 0, 0, 1, 255, 0, 0, 255), cTransformB:ColorTransform = new ColorTransform(0, 1, 0, 1, 0, 255, 0, 255), _lastRect:Rectangle = null;
		protected var _root:DisplayObjectContainer, transformA:ColorTransform = new ColorTransform(1, 0, 0, 1, 255, 0, 0, 255), transformB:ColorTransform = new ColorTransform(0, 1, 0, 1, 0, 255, 0, 255), lastRect:Rectangle = null;
		/**
		 * [read-only] rect: last Rectangle from a hitTest
		 */
		public static function get rect():Rectangle {
			return _lastRect;
		}
		public function get rect():Rectangle {
			return lastRect;
		}
		/**
		 * @param	_root: object to use as the root for testing
		 * @return	DisplayObjectContainer: _root
		 */
		public static function registerRoot(_root:DisplayObjectContainer):DisplayObjectContainer {
			return root = _root;
		}
		public function registerRoot(root:DisplayObjectContainer):DisplayObjectContainer {
			return _root = root;
		}
		/**
		 * @param	tol: alpha tolerance used for testing
		 * @return	null
		 */
		public static function setAlphaTolerance(tol:int = 255):void {
			cTransformA = new ColorTransform(1, 0, 0, 1, 255, 0, 0, tol);
			cTransformB = new ColorTransform(0, 1, 0, 1, 0, 255, 0, tol);
		}
		public function setAlphaTolerance(tol:int = 255):void {
			transformA = new ColorTransform(1, 0, 0, 1, 255, 0, 0, tol);
			transformB = new ColorTransform(0, 1, 0, 1, 0, 255, 0, tol);
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
					_lastRect = b.getColorBoundsRect(0xffffffff, 0xffffff00, true);
					b.dispose();
					if (_lastRect.width) {
						return true;
					}
				}
			}
			return false;
		}
		public function test(objA:DisplayObject, objB:DisplayObject):Boolean {
			if (objA.parent && objB.parent) {
				var oAB:Rectangle = objA.getBounds(_root), oBB:Rectangle = objB.getBounds(_root);
				if (((oAB.right < oBB.left) || (oBB.right < oAB.left)) || ((oAB.bottom < oBB.top) || (oBB.bottom < oAB.top))) {
					return false;
				}
				var boundRect:Rectangle = oAB.intersection(oBB), w:int = boundRect.width, h:int = boundRect.height;
				if (w && h) {
					var b:BitmapData = new BitmapData(w, h, true, 0), t:Number = -boundRect.top, l:Number = -boundRect.left;
					var aM:Matrix = objA.transform.matrix.clone(), bM:Matrix = objB.transform.matrix.clone();
					aM.translate(l, t), bM.translate(l, t);
					b.lock();
					b.draw(objA, aM, transformA);
					b.draw(objB, bM, transformB, "add");
					lastRect = b.getColorBoundsRect(0xffffffff, 0xffffff00, true);
					b.dispose();
					if (lastRect.width) {
						return true;
					}
				}
			}
			return false;
		}
		/**
		 * @param	objA: first object to test
		 * @param	objB: second object to test
		 * @return	Rectangle: the bounding rectangle of the collision or null
		 */
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
					_lastRect = b.getColorBoundsRect(0xffffffff, 0xffffff00, true);
					b.dispose();
					if (_lastRect.width) {
						return _lastRect;
					}
				}
			}
			return null;
		}
		public function hitRect(objA:DisplayObject, objB:DisplayObject):Rectangle {
			if (objA.parent && objB.parent) {
				var oAB:Rectangle = objA.getBounds(_root), oBB:Rectangle = objB.getBounds(_root);
				if (((oAB.right < oBB.left) || (oBB.right < oAB.left)) || ((oAB.bottom < oBB.top) || (oBB.bottom < oAB.top))) {
					return null;
				}
				var boundRect:Rectangle = oAB.intersection(oBB), w:int = boundRect.width, h:int = boundRect.height;
				if (w && h) {
					var b:BitmapData = new BitmapData(w, h, true, 0), t:Number = -boundRect.top, l:Number = -boundRect.left;
					var aM:Matrix = objA.transform.matrix.clone(), bM:Matrix = objB.transform.matrix.clone();
					aM.translate(l, t), bM.translate(l, t);
					b.lock();
					b.draw(objA, aM, transformA);
					b.draw(objB, bM, transformB, "add");
					lastRect = b.getColorBoundsRect(0xffffffff, 0xffffff00, true);
					b.dispose();
					if (lastRect.width) {
						return lastRect;
					}
				}
			}
			return null;
		}
	}
}
