package skyboy.CollisionDetection {
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
