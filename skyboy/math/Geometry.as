package skyboy.math {
	/**
	 * Geometry by skyboy. August 11th 2010.
	 * Visit http://github.com/skyboy for documentation, updates
	 * and more free code.
	 *
	 *
	 * Copyright (c) 2010, skyboy
	 *    All rights reserved.
	 *
	 * Permission is hereby granted, free of charge, to any person
	 * obtaining a copy of this software and associated documentation
	 * files (the "Software"), to deal in the Software with
	 * restriction, with limitation the rights to use, copy, modify,
	 * merge, publish, distribute, sublicense copies of the Software,
	 * and to permit persons to whom the Software is furnished to do so,
	 * subject to the following conditions and limitations:
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
	import flash.geom.Point;

	final public class Geometry {
		public function Geometry() {
			throw new Error("skyboy.math.Geometry does not contain any instance methods.");
		}
		private static function isNaNf(x:Number):Boolean {
			return x != x;
		}
		public static function lineIntersection(start1:Point, end1:Point, start2:Point, end2:Point):Point {
			var x1:Number = start1.x, y1:Number = start1.y;
			var x3:Number = start2.x, y3:Number = start2.y;
			var m1:Number = ((y1 - end1.y) / (x1 - end1.x)), m2:Number = ((y3 - end2.y) / (x3 - end2.x));
			if (m1 == m2) return null;
			if (m1 != m1) {
				if (m2 != m2) return null;
				return new Point(x1, x1 * m2 + (y3 - (m2 * x3)));
			} else if (m2 != m2) {
				return new Point(x3, x3 * m1 + (y1 - (m1 * x1)));
			}
			var b1:Number = y1 - (m1 * x1);
			var ix:Number = (0 - (b1 - (y3 - (m2 * x3)))) / (m1 - m2);
			return new Point(ix, ix * m1 + b1);
		}
		public static function lineIntersection2(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Point {
			var m1:Number = ((y1 - y2) / (x1 - x2)), m2:Number = ((y3 - y4) / (x3 - x4));
			if (m1 == m2) return null;
			if (x1 == x2) {
				if (x3 == x4) return null;
				return new Point(x1, x1 * m2 + (y3 - (m2 * x3)));
			} else if (x3 == x4) {
				return new Point(x3, x3 * m1 + (y1 - (m1 * x1)));
			}
			var b1:Number = y1 - (m1 * x1);
			var ix:Number = (0 - (b1 - (y3 - (m2 * x3)))) / (m1 - m2);
			return new Point(ix, ix * m1 + b1);
		}
		public static function convertToRadians(deg:Number):Number {
			return deg * 00.017453292519943295769236907684886127134428718885417254560971914401710091146034494436822415696345094822123044925073790592483854692;
		}
		public static function convertToDegrees(rad:Number):Number {
			return rad * 57.295779513082320876798154814105170332405472466564321549160243861202847148321552632440968995851110944186223381632864893281448264601;
		}
		public static function min2(x:Number, y:Number):Number {
			if (x != x) {
				if (y != y) return 0;
				return y;
			} else if (y != y) {
				return x;
			}
			return x < y ? x : y;
		}
		public static function min3(x:Number, y:Number, z:Number):Number {
			if (x != x) {
				if (y != y) {
					if (z != z) return 0;
					return z;
				}
				return y < z ? y : x;
			} else if (y != y) {
				if (z != z) return x;
				return z < x ? z : x;
			} else if (z != z) {
				return x < y ? x : y;
			}
			if (z < x) {
				return y < z ? y : z;
			} else {
				return x < y ? x : y;
			}
		}
		public static function max2(x:Number, y:Number):Number {
			if (x != x) {
				if (y != y) return 0;
				return y;
			} else if (y != y) {
				return x;
			}
			return x > y ? x : y;
		}
		public static function max3(x:Number, y:Number, z:Number):Number {
			if (x != x) {
				if (y != y) {
					if (z != z) return 0;
					return z;
				}
				return y > z ? y : x;
			} else if (y != y) {
				if (z != z) return x;
				return z > x ? z : x;
			} else if (z != z) {
				return x > y ? x : y;
			}
			if (z > x) {
				return y > z ? y : z;
			} else {
				return x > y ? x : y;
			}
		}
	}
}
