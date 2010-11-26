package skyboy.collections {
	import flash.utils.getQualifiedClassName;
	/**
	 * DenseMap by skyboy. October 26th 2010.
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

	/**
	 * ...
	 * @author skyboy
	 */
	public final class DenseMap {
		private static const string:Function = (Class as Object).toString;
		private const nulls:Vector.<uint> = new Vector.<uint>();
		public const vals:Vector.<*> = new Vector.<*>();
		public var prev:Vector.<uint> = new Vector.<uint>(), next:Vector.<uint> = new Vector.<uint>();
		public var starti:uint, endi:uint, midi:uint, curi:uint, curIx:uint;
		public var mLen:uint, _length:uint, hLen:uint, qLen:uint, q3Len:uint;
		private var hArray:Array, dirty:Boolean;
		public function get length():uint {
			return _length;
		}
		public function set length(len:uint):void {
			if (len == _length) {
				flush();
				return;
			}
			var i:uint, a:uint;
			if (len > _length) {
				if (len > mLen) {
					if (_length == mLen) {
						i = (next.length = prev.length = vals.length = len);
						a = _length;
						next[endi] = a;
						while (++a < i) {
							next[prev[a] = a - 1] = a;
						}
						prev[starti] = endi = a - 1;
						_length = i
						return;
					}
					flush();
					// TODO: add length extension when dLength is greater than total length and effective length is not total length (quickfix: push?)
					i = len - _length;
					while (--i) push(null);
				}
				flush();
				// TODO: add length extension for when dLength is greater than effective length and less than total length (quickfix: push?)
				i = len - _length;
				while (--i) push(null);
			} else {
				if (len == 0) {
					i = nulls.length = mLen;
					while (i--) {
						vals[nulls[i] = i] = null;
					}
					curi = curIx = q3Len = qLen = hLen = starti = midi = endi = _length = prev[0] = next[0] = 0;
					dirty = false;
					return;
				}
				// TODO: add length decremation for non-zero values (quickfix: pop?)
				i = _length - len;
				while (--i) pop();
			}
			if ((a = hLen - (hLen = _length >> 1))) if (a > 0) {
				i = prev[midi];
				while (--a) i = prev[i];
				midi = i;
			} else {
				i = next[midi];
				while (++a) i = next[i];
				midi = i;
			}
			q3Len = (qLen = hLen >> 1) * 3;
		}
		public function DenseMap(...values):void {
			var a:uint = values.length, b:*;
			if (a) {
				if (a == 1) {
					if ((b = values[0]) is Number) {
						q3Len = (qLen = (midi = hLen = (nulls.length = mLen = prev.length = next.length = vals.length = _length = a = b) >> 1) >> 1) * 3;
						prev[nulls.length = 0] = endi = --a;
						while (a--) prev[next[a] = a + 1] = a;
					} else if (b is Array) {
						var c:Array = b;
						q3Len = (qLen = (midi = hLen = (nulls.length = mLen = prev.length = next.length = vals.length = _length = a = c.length) >> 1) >> 1) * 3;
						prev[nulls.length = 0] = endi = --a;
						vals[a] = c[a];
						while (a--) vals[prev[next[a] = a + 1] = a] = c[a];
					} else {
						q3Len = (qLen = (midi = hLen = (mLen = prev.length = next.length = vals.length = _length = 1) >> 1) >> 1) * 3;
						vals[next[prev[endi = starti = 0] = 0] = 0] = b;
					}
				} else {
					q3Len = (qLen = (midi = hLen = (mLen = prev.length = next.length = vals.length = _length = a) >> 1) >> 1) * 3;
					prev[0] = endi = --a;
					vals[a] = values[a];
					while (a--) vals[prev[next[a] = a + 1] = a] = values[a];
				}
			}
			hArray = new Array(15);
		}
		public function push(...values):uint {
			var a:uint = values.length, i:uint, c:uint;
			//trace('push\n', next, '\n', prev, '\n', starti, endi);
			if (a == 1) {
				if (nulls.length) {
					c = nulls.pop();
					vals[endi = prev[next[c] = starti] = next[prev[c] = endi] = c] = values[0];
					if (hLen - (hLen = ++_length >> 1)) {
						midi = next[midi];
						q3Len = (qLen = hLen >> 1) * 3;
					}
					return _length;
				}
				dirty = false;
				++mLen;
				c = (next.length = (prev.length = (vals.length = ++_length))) - 1;
				next[endi = next[prev[c] = endi] = c] = starti;
				vals[prev[starti] = c] = values[0];
				if (hLen - (hLen = ++_length >> 1)) {
					midi = next[midi];
					q3Len = (qLen = hLen >> 1) * 3;
				}
				return c;
			} else if (a) {
				if (nulls.length) {
					var n:uint = nulls.length;
					_length += a;
					while (i != a && n--) {
						c = nulls.pop();
						vals[endi = prev[next[c] = starti] = next[prev[c] = endi] = c] = values[i++];
					}
					if (i != a) {
						prev[starti] = next.length = prev.length = vals.length = _length;
						c = _length - (a - i);
						mLen += a - i;
						vals[next[prev[c] = endi] = c] = values[i];
						while (++i < a) {
							vals[++c] = values[i];
							next[prev[c] = c - 1] = c;
						}
						next[endi = c] = starti;
					}
					if ((a = hLen - (hLen = _length >> 1))) {
						i = midi;
						while (a++) i = next[i];
						midi = i;
						q3Len = (qLen = hLen >> 1) * 3;
					}
					return _length;
				}
				c = _length;
				next.length = prev.length = vals.length = _length += a;
				mLen += a;
				vals[next[prev[c] = endi] = c] = values[0];
				while (++i < a) {
					vals[++c] = values[i];
					next[prev[c] = c - 1] = c;
				}
				next[endi = c] = starti;
				if ((a = hLen - (hLen = _length >> 1))) {
					i = midi;
					while (a++) i = next[i];
					midi = i;
					q3Len = (qLen = hLen >> 1) * 3;
				}
			}
			return _length;
		}
		public function pop():* {
			var i:uint = endi;
			next[prev[starti] = endi = prev[i]] = starti;
			nulls.push(i);
			dirty = true;
			if (hLen - (hLen = --_length >> 1)) {
				midi = prev[midi];
				q3Len = (qLen = hLen >> 1) * 3;
			}
			return vals[i];
		}
		public function unshift(...values):uint {
			var a:uint = values.length, i:uint, c:uint;
			//trace('unshift\n', next, '\n', prev, '\n', starti, endi);
			if (a == 1) {
				if (nulls.length) {
					c = nulls.pop();
					vals[starti = prev[next[c] = starti] = next[prev[c] = endi] = c] = values[0];
					if (hLen - (hLen = ++_length >> 1)) {
						midi = next[midi];
					}
					q3Len = (qLen = hLen >> 1) * 3;
					return _length;
				}
				dirty = false;
				++mLen;
				c = (next.length = (prev.length = (vals.length = ++_length))) - 1;
				vals[starti = prev[next[c] = starti] = next[prev[c] = endi] = c] = values[0];
				if (hLen - (hLen = ++c >> 1)) {
					midi = next[midi];
				}
				q3Len = (qLen = hLen >> 1) * 3;
				return c;
			} else if (a) {
				temp: {
					// break temp;
					while (a--) unshift(values[a]);
					return _length;
				}// TODO: refactor second half of unshift to work correctly
				if (nulls.length) {
					var n:uint = nulls.length, s:uint = starti, t:uint;
					_length += a;
					c = nulls.pop();
					vals[starti = prev[next[c] = s] = next[endi] = c] = values[i++];
					while (--n && a != i) {
						t = c;
						prev[c = next[t] = nulls.pop()] = t;
						vals[c] = values[i++];
					}
					if (i != a) {
						next.length = prev.length = vals.length = _length;
						mLen += a - i;
						n = c;
						prev[next[n] = c = _length - (a - i)] = n;
						vals[c] = values[i++];
						while (i != a) {
							n = c;
							next[n] = prev[++c] = n;
							vals[c] = values[i++];
						}
					}
					next[prev[s] = c] = s;
					if ((i = hLen - (hLen = _length >> 1))) {
						a = midi;
						while (i++) a = next[a];
						midi = a;
					}
					q3Len = (qLen = hLen >> 1) * 3;
					return _length;
				}
				c = _length;
				next.length = prev.length = vals.length = _length += a;
				mLen += a;
				while (i != a) {
					vals[starti = prev[next[c] = starti] = next[prev[c] = endi] = c] = values[i++];
					++c;
				}
				if ((i = hLen - (hLen = _length >> 1))) {
					a = midi;
					while (i++) a = next[a];
					midi = a;
				}
				q3Len = (qLen = hLen >> 1) * 3;
			}
			return _length;
		}
		public function shift():* {
			var i:uint = starti;
			next[prev[starti = next[i]] = endi] = starti;
			nulls.push(i);
			dirty = true;
			if (hLen - (hLen = --_length >> 1)) {
				midi = prev[midi];
				q3Len = (qLen = hLen >> 1) * 3;
			}
			return vals[i];
		}
		public function reverse():DenseMap {
			var temp:Vector.<uint> = next;
			next = prev;
			prev = temp;
			return this;
		}
		public function join(sep:String = ","):String {
			var ret:String = "", i:uint = starti;
			var e:uint = endi;
			var next:Vector.<uint> = this.next, vals:Vector.<*> = this.vals;
			if (i != e) do {
				ret += vals[i] + sep;
				i = next[i];
			} while (i != e);
			return ret + vals[e];
		}
		/**
		 * joinR
		 * Returns a string representation of the DenseMap joined by sep in reverse order.
		 * @param	String: sep	The separator to use between objects in the DenseMap.
		 * @return	StringA string representation of the DenseMap in reverse order joined by sep.
		 */
		public function joinR(sep:String = ","):String {
			var ret:String = "", i:uint = endi;
			var e:uint = starti;
			if (i != e) do {
				ret += vals[i] + sep;
				i = prev[i];
			} while (i != e);
			return ret + vals[e];
		}
		public function toString():String {
			var ret:String = "";
			var e:uint = endi, i:uint = starti;
			if (i != e) do {
				ret += vals[i] + ",";
				i = next[i];
			} while (i != e);
			return ret + vals[e];
		}
		/**
		 * toStringR
		 * Retrusn a string representation of the DenseMap in reverse order.
		 * @return	String: A string representation of the DenseMap in reverse order.
		 */
		public function toStringR():String {
			var ret:String = "";
			var e:uint = starti, i:uint = endi;
			if (i != e) do {
				ret += vals[i] + ",";
				i = prev[i];
			} while (i != e);
			return ret + vals[e];
		}
		//*
		final private function quickSort(input:Vector.<*>, left:int = 0, right:int = int.MAX_VALUE):void {
			var i:int = left < 0 ? left = 0 : left, t:*;
			var j:int = right >= input.length ? right = input.length - 1 : right;
			var pivotPoint:* = input[int((right + left) * .5 + 0.5)];
			do {
				while (left <= right) {
					if (input[right] > pivotPoint) do {
						--right
					} while (t > pivotPoint);
					if (input[left] < pivotPoint) do {
						++left
					} while (input[left] < pivotPoint);
					if (left <= right) {
						t = input[left];
						input[left] = input[right];
						input[right] = t;
						++left, --right;
					}
				}
				if (i < right) {
					quickSort(input, i, right);
				}
				if (j <= left) return;
				i = left;
				right = j;
				pivotPoint = input[int((right + left) * .5 + 0.5)];
			} while (true);
		}
		final private function quickSortLeg(input:Vector.<*>, left:int = 0, right:int = int.MAX_VALUE):void {
			var i:int = left < 0 ? left = 0 : left, t:*;
			var j:int = right >= input.length ? right = input.length - 1 : right;
			var pivotPoint:String = String(input[int((right + left) * .5 + 0.5)]);
			do {
				while (left <= right) {
					if (String(input[left]) < pivotPoint) do { ++left; } while (String(input[left]) < pivotPoint);
					if (String(input[right]) > pivotPoint) do { --right; } while (String(input[right]) > pivotPoint);
					if (left <= right) {
						t = input[left];
						input[left++] = input[right];
						input[right--] = t;
					}
				}
				if (i < right) {
					quickSortLeg(input, i, right);
				}
				if (j <= left) return;
				i = left;
				right = j;
				pivotPoint = String(input[int((right + left) * .5 + 0.5)]);
			} while (true);
		}
		final private function quickSortC(input:Vector.<*>, callback:Function, left:int = 0, right:int = int.MAX_VALUE):void {
			var i:int = left < 0 ? left = 0 : left, t:*;
			var j:int = right >= input.length ? right = input.length - 1 : right;
			var pivotPoint:* = input[int((right + left) * .5 + 0.5)];
			do {
				while (left <= right) {
					while (callback(input[left], pivotPoint) < 0) {
						++left;
						if (left == right) break;
					}
					while (callback(input[right], pivotPoint) > 0) {
						--right;
						if (left == right) break;
					}
					if (left <= right) {
						t = input[left];
						input[left++] = input[right];
						input[right--] = t;
					}
				}
				if (i < right) {
					quickSortC(input, callback, i, right);
				}
				if (j <= left) return;
				i = left;
				right = j;
				pivotPoint = input[int((right + left) * .5 + 0.5)];
			} while (true);
		}
		public function sort(callback:* = null, options:uint = 0):DenseMap {
			var n:uint = _length;
			if (n < 2) return this;
			if (dirty) flush();
			if (callback is Function) {
				quickSortC(vals, callback);
			} else if (callback is int) {
				if (callback & Array.NUMERIC) quickSort(vals); else quickSortLeg(vals);
			} else {
				// TODO: merge quickSort and sort, make quickSort iterative
				if (options & Array.NUMERIC) quickSort(vals); else quickSortLeg(vals);
			}
			next[endi = prev[starti = 0] = --n] = 0;
			while (--n) prev[next[n] = n + 1] = n;
			return this;
		}
		final private function quickSortOn(input:Vector.<*>, name:String, left:int = 0, right:int = int.MAX_VALUE):void {
			var i:int = left < 0 ? left = 0 : left;
			var j:int = right >= input.length ? right = input.length - 1 : right;
			var T:int = (left + right) * .5 + 0.5, o:Boolean;
			while (input[T] == null) {
				if (++T > right) break;
			}
			if (input[T] == null) {
				T = (left + right) * .5 + 0.5;
				do {
					if (--T < left) return;
				} while (input[T] == null)
			}
			var t:* = input[T], pivotPoint:* = name in t ? t[name] : t;
			while (left < right) {
				while ((t = input[T = right]) && (name in t ? t[name] : t) > pivotPoint) {
					next[prev[T] = --right] = T;
				}
				while ((t = input[T = left]) && (name in t ? t[name] : t) < pivotPoint) {
					prev[next[T] = ++left] = T;
				}
				if (left < right) {
					input[left++] = input[right];
					input[right--] = t;
					o = true;
				}
			}
			if (o) {
				if (left == right) ++left, --right;
				if (i > right) {
					quickSortOn(input, name, i, right);
				}
				if (left < j) {
					quickSortOn(input, name, left, j);
				}
			}
		}
		public function sortOn(name:String):DenseMap {
			var n:uint = _length;
			if (n < 2) return this;
			if (dirty) flush();
			// TODO: merge quickSortOn and sortOn, make quickSortOn iterative
			quickSortOn(vals, name);
			next[endi = prev[starti = 0] = n - 1] = 0;
			return this;
		}
		/**
		 * elementAt
		 * Sets or gets an element from the DenseMap.
		 * @param	uint: i	The index of the element.
		 * @param	*: value	The value to set at index, or null/undefined/empty to return the value at that index.
		 * @return	*: The value at the specified index.
		 */
		public function elementAt(i:uint, value:* = null):* {
			if (i == curIx) if (value == null) return vals[curi]; else return vals[curi] = value; // element caching to speed up processing
			var a:uint, next:Vector.<uint> = this.next, prev:Vector.<uint> = this.prev;
			if (i >= _length) if (value == null) return null;
			else {
				// TODO: when index is out of range, and value is not null, expand DenseMap and set element
				return value;
			}
			if ((a = curIx - (curIx = i)) > -17 && a < 17) {
				if (a > 17) {
					if (a == 4294967295) { // -1
						a = next[curi];
					} else if (a == 4294967294) { // -2
						a = next[next[curi]];
					} else if (a == 4294967293) { // -3
						a = next[next[next[curi]]];
					} else if (a == 4294967292) { // -4
						a = next[next[next[next[curi]]]];
					} else if (a == 4294967291) { // -5
						a = next[next[next[next[next[curi]]]]];
					} else if (a == 4294967290) { // -6
						a = next[next[next[next[next[next[curi]]]]]];
					} else if (a == 4294967289) { // -7
						a = next[next[next[next[next[next[next[curi]]]]]]];
					} else if (a == 4294967288) { // -8
						a = next[next[next[next[next[next[next[next[curi]]]]]]]];
					} else if (a == 4294967287) { // -9
						a = next[next[next[next[next[next[next[next[next[curi]]]]]]]]];
					} else if (a == 4294967286) { // -10
						a = next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]];
					} else if (a == 4294967285) { // -11
						a = next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]];
					} else if (a == 4294967284) { // -12
						a = next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]];
					} else if (a == 4294967283) { // -13
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]];
					} else if (a == 4294967282) { // -14
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]]];
					} else if (a == 4294967281) { // -15
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]]]];
					} else if (a == 4294967280) { // -16
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]]]]];
					}
				} else {
					if (a == 1) {
						a = prev[curi];
					} else if (a == 2) {
						a = prev[prev[curi]];
					} else if (a == 3) {
						a = prev[prev[prev[curi]]];
					} else if (a == 4) {
						a = prev[prev[prev[prev[curi]]]];
					} else if (a == 5) {
						a = prev[prev[prev[prev[prev[curi]]]]];
					} else if (a == 6) {
						a = prev[prev[prev[prev[prev[prev[curi]]]]]];
					} else if (a == 7) {
						a = prev[prev[prev[prev[prev[prev[prev[curi]]]]]]];
					} else if (a == 8) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]];
					} else if (a == 9) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]];
					} else if (a == 10) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]];
					} else if (a == 11) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]];
					} else if (a == 12) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]];
					} else if (a == 13) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]];
					} else if (a == 14) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]]];
					} else if (a == 15) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]]]];
					} else if (a == 16) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]]]]];
					}
				}
			} else if (hLen > i) {
				if (i < qLen) {
					a = starti;
					while (i--) {
						if (i == 0) {
							a = next[a];
							break;
						} else if (i == 1) {
							a = next[next[a]];
							break;
						} else if (i == 2) {
							a = next[next[next[a]]];
							break;
						} else if (i == 3) {
							a = next[next[next[next[a]]]];
							break;
						} else if (i == 4) {
							a = next[next[next[next[next[a]]]]];
							break;
						} else if (i == 5) {
							a = next[next[next[next[next[next[a]]]]]];
							break;
						} else if (i == 6) {
							a = next[next[next[next[next[next[next[a]]]]]]];
							break;
						} else if (i == 7) {
							a = next[next[next[next[next[next[next[next[a]]]]]]]];
							break;
						} else if (i == 8) {
							a = next[next[next[next[next[next[next[next[next[a]]]]]]]]];
							break;
						} else if (i == 9) {
							a = next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]];
							break;
						} else if (i == 10) {
							a = next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]];
							break;
						} else if (i == 15) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]];
							break;
							//i -= 14;
						} else {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
						}
					}
				} else {
					i = hLen - i;
					a = midi;
					while (i--) {
						if (i == 0) {
							a = prev[a];
							break;
						} else if (i == 1) {
							a = prev[prev[a]];
							break;
						} else if (i == 2) {
							a = prev[prev[prev[a]]];
							break;
						} else if (i == 3) {
							a = prev[prev[prev[prev[a]]]];
							break;
						} else if (i == 4) {
							a = prev[prev[prev[prev[prev[a]]]]];
							break;
						} else if (i == 5) {
							a = prev[prev[prev[prev[prev[prev[a]]]]]];
							break;
						} else if (i == 6) {
							a = prev[prev[prev[prev[prev[prev[prev[a]]]]]]];
							break;
						} else if (i == 7) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]];
							break;
						} else if (i == 8) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]];
							break;
						} else if (i == 9) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]];
							break;
						} else if (i == 10) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]];
							break;
						} else {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
							//i -= 14;
						}
					}
				}
			} else {
				if (i > q3Len) {
					i = _length - i;
					a = endi;
					while (--i) {
						if (i == 1) {
							a = prev[a];
							break;
						} else if (i == 2) {
							a = prev[prev[a]];
							break;
						} else if (i == 3) {
							a = prev[prev[prev[a]]];
							break;
						} else if (i == 4) {
							a = prev[prev[prev[prev[a]]]];
							break;
						} else if (i == 5) {
							a = prev[prev[prev[prev[prev[a]]]]];
							break;
						} else if (i == 6) {
							a = prev[prev[prev[prev[prev[prev[a]]]]]];
							break;
						} else if (i == 7) {
							a = prev[prev[prev[prev[prev[prev[prev[a]]]]]]];
							break;
						} else if (i == 8) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]];
							break;
						} else if (i == 9) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]];
							break;
						} else if (i == 10) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]];
							break;
						} else if (i == 15) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]];
							break;
						} else {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
						}
					}
				} else {
					i = (qLen - (q3Len - i)) - (hLen & 1);
					a = midi;
					while (i--) {
						if (i == 0) {
							a = next[a];
							break;
						} else if (i == 1) {
							a = next[next[a]];
							break;
						} else if (i == 2) {
							a = next[next[next[a]]];
							break;
						} else if (i == 3) {
							a = next[next[next[next[a]]]];
							break;
						} else if (i == 4) {
							a = next[next[next[next[next[a]]]]];
							break;
						} else if (i == 5) {
							a = next[next[next[next[next[next[a]]]]]];
							break;
						} else if (i == 6) {
							a = next[next[next[next[next[next[next[a]]]]]]];
							break;
						} else if (i == 7) {
							a = next[next[next[next[next[next[next[next[a]]]]]]]];
							break;
						} else if (i == 8) {
							a = next[next[next[next[next[next[next[next[next[a]]]]]]]]];
							break;
						} else if (i == 9) {
							a = next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]];
							break;
						} else if (i == 10) {
							a = next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]];
							break;
						} else if (i == 15) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]];
							break;
							//i -= 14;
						} else {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
						}
					}
				}
			}
			if (value == null) {
				return vals[curi = a];
			}
			return vals[curi = a] = value;
		}
		private function indexAt(i:uint):uint {
			if (i == curIx) return curi; // element caching to speed up processing
			var a:uint, next:Vector.<uint> = this.next, prev:Vector.<uint> = this.prev;
			if ((a = curIx - (curIx = i)) > -17 && a < 17) {
				if (a > 17) {
					if (a == 4294967295) { // -1
						a = next[curi];
					} else if (a == 4294967294) { // -2
						a = next[next[curi]];
					} else if (a == 4294967293) { // -3
						a = next[next[next[curi]]];
					} else if (a == 4294967292) { // -4
						a = next[next[next[next[curi]]]];
					} else if (a == 4294967291) { // -5
						a = next[next[next[next[next[curi]]]]];
					} else if (a == 4294967290) { // -6
						a = next[next[next[next[next[next[curi]]]]]];
					} else if (a == 4294967289) { // -7
						a = next[next[next[next[next[next[next[curi]]]]]]];
					} else if (a == 4294967288) { // -8
						a = next[next[next[next[next[next[next[next[curi]]]]]]]];
					} else if (a == 4294967287) { // -9
						a = next[next[next[next[next[next[next[next[next[curi]]]]]]]]];
					} else if (a == 4294967286) { // -10
						a = next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]];
					} else if (a == 4294967285) { // -11
						a = next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]];
					} else if (a == 4294967284) { // -12
						a = next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]];
					} else if (a == 4294967283) { // -13
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]];
					} else if (a == 4294967282) { // -14
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]]];
					} else if (a == 4294967281) { // -15
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]]]];
					} else if (a == 4294967280) { // -16
						a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[curi]]]]]]]]]]]]]]]];
					}
				} else {
					if (a == 1) {
						a = prev[curi];
					} else if (a == 2) {
						a = prev[prev[curi]];
					} else if (a == 3) {
						a = prev[prev[prev[curi]]];
					} else if (a == 4) {
						a = prev[prev[prev[prev[curi]]]];
					} else if (a == 5) {
						a = prev[prev[prev[prev[prev[curi]]]]];
					} else if (a == 6) {
						a = prev[prev[prev[prev[prev[prev[curi]]]]]];
					} else if (a == 7) {
						a = prev[prev[prev[prev[prev[prev[prev[curi]]]]]]];
					} else if (a == 8) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]];
					} else if (a == 9) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]];
					} else if (a == 10) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]];
					} else if (a == 11) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]];
					} else if (a == 12) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]];
					} else if (a == 13) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]];
					} else if (a == 14) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]]];
					} else if (a == 15) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]]]];
					} else if (a == 16) {
						a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[curi]]]]]]]]]]]]]]]];
					}
				}
			} else if (hLen > i) {
				if (i < qLen) {
					a = starti;
					while (i--) {
						if (i == 0) {
							a = next[a];
							break;
						} else if (i == 1) {
							a = next[next[a]];
							break;
						} else if (i == 2) {
							a = next[next[next[a]]];
							break;
						} else if (i == 3) {
							a = next[next[next[next[a]]]];
							break;
						} else if (i == 4) {
							a = next[next[next[next[next[a]]]]];
							break;
						} else if (i == 5) {
							a = next[next[next[next[next[next[a]]]]]];
							break;
						} else if (i == 6) {
							a = next[next[next[next[next[next[next[a]]]]]]];
							break;
						} else if (i == 7) {
							a = next[next[next[next[next[next[next[next[a]]]]]]]];
							break;
						} else if (i == 8) {
							a = next[next[next[next[next[next[next[next[next[a]]]]]]]]];
							break;
						} else if (i == 9) {
							a = next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]];
							break;
						} else if (i == 10) {
							a = next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]];
							break;
						} else if (i == 15) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]];
							break;
							//i -= 14;
						} else {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
						}
					}
				} else {
					i = hLen - i;
					a = midi;
					while (i--) {
						if (i == 0) {
							a = prev[a];
							break;
						} else if (i == 1) {
							a = prev[prev[a]];
							break;
						} else if (i == 2) {
							a = prev[prev[prev[a]]];
							break;
						} else if (i == 3) {
							a = prev[prev[prev[prev[a]]]];
							break;
						} else if (i == 4) {
							a = prev[prev[prev[prev[prev[a]]]]];
							break;
						} else if (i == 5) {
							a = prev[prev[prev[prev[prev[prev[a]]]]]];
							break;
						} else if (i == 6) {
							a = prev[prev[prev[prev[prev[prev[prev[a]]]]]]];
							break;
						} else if (i == 7) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]];
							break;
						} else if (i == 8) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]];
							break;
						} else if (i == 9) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]];
							break;
						} else if (i == 10) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]];
							break;
						} else {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
							//i -= 14;
						}
					}
				}
			} else {
				if (i > q3Len) {
					i = _length - i;
					a = endi;
					while (--i) {
						if (i == 1) {
							a = prev[a];
							break;
						} else if (i == 2) {
							a = prev[prev[a]];
							break;
						} else if (i == 3) {
							a = prev[prev[prev[a]]];
							break;
						} else if (i == 4) {
							a = prev[prev[prev[prev[a]]]];
							break;
						} else if (i == 5) {
							a = prev[prev[prev[prev[prev[a]]]]];
							break;
						} else if (i == 6) {
							a = prev[prev[prev[prev[prev[prev[a]]]]]];
							break;
						} else if (i == 7) {
							a = prev[prev[prev[prev[prev[prev[prev[a]]]]]]];
							break;
						} else if (i == 8) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]];
							break;
						} else if (i == 9) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]];
							break;
						} else if (i == 10) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]];
							break;
						} else if (i == 15) {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]];
							break;
						} else {
							a = prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[prev[a]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
						}
					}
				} else {
					i = (qLen - (q3Len - i)) - (hLen & 1);
					a = midi;
					while (i--) {
						if (i == 0) {
							a = next[a];
							break;
						} else if (i == 1) {
							a = next[next[a]];
							break;
						} else if (i == 2) {
							a = next[next[next[a]]];
							break;
						} else if (i == 3) {
							a = next[next[next[next[a]]]];
							break;
						} else if (i == 4) {
							a = next[next[next[next[next[a]]]]];
							break;
						} else if (i == 5) {
							a = next[next[next[next[next[next[a]]]]]];
							break;
						} else if (i == 6) {
							a = next[next[next[next[next[next[next[a]]]]]]];
							break;
						} else if (i == 7) {
							a = next[next[next[next[next[next[next[next[a]]]]]]]];
							break;
						} else if (i == 8) {
							a = next[next[next[next[next[next[next[next[next[a]]]]]]]]];
							break;
						} else if (i == 9) {
							a = next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]];
							break;
						} else if (i == 10) {
							a = next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]];
							break;
						} else if (i == 11) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]];
							break;
						} else if (i == 12) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]];
							break;
						} else if (i == 13) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]];
							break;
						} else if (i == 14) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]];
							break;
						} else if (i == 15) {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]];
							break;
							//i -= 14;
						} else {
							a = next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[next[a]]]]]]]]]]]]]]]]];
							--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;--i;
						}
					}
				}
			}
			return curi = a;
		}
		public function concat(...values):DenseMap {
			for each (var e:* in values) {
				push(e);
			}
			return this;
		}
		/**
		 * concatArray
		 * Concats the contents of the array(s) passed to the function to the end of the DenseMap.
		 * @param	Array: ...values	The Array(s) to concat.
		 * @return	DenseMap: Returns the DenseMap you called the method on.
		 */
		public function concatArray(...values):DenseMap {
			var d:DenseMap, b:uint, c:Array, l:uint;
			for each(var a:* in values) {
				if (a is DenseMap) {
					if ((l = (c = a.toArray(hArray)).length)) do {
						push(c[b++]);
					} while(b < l);
				} else if (a is Array || getQualifiedClassName(data).indexOf("AS3.vec:") === 0) {
					if ((l = (c = a as Array).length)) do {
						push(c[b++]);
					} while (b < l);
				} else throw new TypeError(string.call(a) + " is not an Array type.");
			}
			return this;
		}
		private function concatPushHelper(value:*, c:uint = 0, DM:DenseMap = null):void {
			if (nulls.length) {
				c = nulls.pop();
				vals[endi = prev[next[c] = starti] = next[prev[c] = endi] = c] = value;
				if (hLen - (hLen = ++_length >> 1)) {
					midi = next[midi];
					q3Len = (qLen = hLen >> 1) * 3;
				}
				return;
			}
			++mLen;
			c = (next.length = (prev.length = (vals.length = ++_length))) - 1;
			next[endi = next[prev[c] = endi] = c] = starti;
			vals[prev[starti] = c] = value;
			if (hLen - (hLen = ++_length >> 1)) {
				midi = next[midi];
				q3Len = (qLen = hLen >> 1) * 3;
			}
		}
		public function every(callback:Function, thisObject:Object = null):Boolean {
			var a:uint = endi, e:uint = prev[a], i:uint;
			if (thisObject != null) {
				if (callback.call(thisObject, vals[a = next[a]], i++, this)) {
					while (a != e) if (!callback.call(thisObject, vals[a = next[a]], i++, this)) return false;
					if (callback.call(thisObject, vals[a], i, this)) return true;
				}
			} else {
				if (callback(vals[a = next[a]], i++, this)) {
					while (a != e) if (!callback(vals[a = next[a]], i++, this)) return false;
					if (callback(vals[a], i, this)) return true;
				}
			}
			return false;
		}
		public function some(callback:Function, thisObject:Object = null):Boolean {
			var a:uint = endi, e:uint = a, i:uint;
			if (thisObject != null) {
				if (callback.call(thisObject, vals[a = next[a]], i++, this)) return true;
				while (a != e) if (callback.call(thisObject, vals[a = next[a]], i++, this)) return true;
			} else {
				if (callback(vals[a = next[a]], i++, this)) return true;
				while (a != e) if (callback(vals[a = next[a]], i++, this)) return true;
			}
			return false;
		}
		public function filter(callback:Function, thisObject:Object = null):DenseMap {
			var a:uint = starti, e:uint = endi, i:uint, ret:Array = hArray, ri:uint, t:*;
			var next:Vector.<uint> = this.next, vals:Vector.<*> = this.vals;
			ret.length = 0;
			ret.length = _length;
			if (thisObject != null) {
				if (callback.call(thisObject, t = vals[a], i++, this)) ret[ri++] = t;
				while (a != e) if (callback.call(thisObject, t = vals[a = next[a]], i++, this)) ret[ri++] = t;
			} else {
				if (callback(t = vals[a], i, this)) ret[ri++] = t;
				while (a != e) if (callback(t = vals[a = next[a]], i++, this)) ret[ri++] = t;
			}
			ret.length = ri;
			return new DenseMap(ret);
		}
		public function map(callback:Function, thisObject:Object = null):DenseMap {
			var a:uint = starti, e:uint = endi, i:uint, ret:Array = hArray;
			var next:Vector.<uint> = this.next, vals:Vector.<*> = this.vals;
			ret.length = 0;
			ret.length = _length;
			if (thisObject != null) {
				ret[i] = callback.call(thisObject, vals[a = next[a]], i++, this);
				while (a != e) ret[i] = callback.call(thisObject, vals[a = next[a]], i++, this);
			} else {
				ret[i] = callback(vals[a = next[a]], i++, this);
				while (a != e) ret[i] = callback(vals[a = next[a]], i++, this);
			}
			return new DenseMap(ret);
		}
		public function forEach(callback:Function, thisObject:Object = null):void {
			var a:uint = endi, e:uint = a, i:uint;
			if (thisObject != null) {
				callback.call(thisObject, vals[a = next[a]], i++, this);
				while (a != e) callback.call(thisObject, vals[a = next[a]], i++, this);
			} else {
				callback(vals[a = next[a]], i++, this);
				while (a != e) callback(vals[a = next[a]], i++, this);
			}
		}
		public function indexOf(obj:*, i:uint = 0):Number {
			if (i >= _length) return -1;
			var a:uint = i ? indexAt(i) : starti, I:uint = endi;
			while (a != I) {
				if (vals[a] === obj) return i; else ++i,a = next[a];
			}
			if (vals[a] === obj) return i;
			return -1;
		}
		public function lastIndexOf(obj:*, i:uint = uint.MAX_VALUE):Number {
			if (i == 0) return vals[starti] === obj ? 0 : -1;
			var a:uint = i < _length ? indexAt(i) : endi, I:uint = starti;
			while (a != I) {
				if (vals[a] === obj) return i; else --i, a = prev[a];
			}
			if (vals[a] === obj) return i;
			return -1;
		}
		/**
		 * toArray
		 * Returns an array containing the values of the DenseMap
		 * @param	Array: arr: An Arrray to fill instead of creating a new one (null)
		 * @return	Array: An Array containing the values of the DenseMap
		 */
		public function toArray(arr:Array = null):Array {
			var i:uint = _length, a:uint = starti;
			if (arr) {
				if (i) {
					arr.length = 0;
					arr.length = i;
					while (i) arr[--i] = vals[a = prev[a]];
					return arr;
				}
				return arr;
			} else {
				if (i) {
					arr = new Array(i);
					while (i) arr[--i] = vals[a = prev[a]];
					return arr;
				}
				return new Array;
			}
		}
		public function slice(start:uint = 0, end:uint = uint.MAX_VALUE):DenseMap {
			if (end > _length) if (start) end = _length; else return new DenseMap(toArray(hArray));
			if (end <= start || start >= _length) return new DenseMap;
			var ret:Array = hArray, a:uint = prev[start == (ret.length = 0) ? starti : indexAt(start)];
			end -= start;
			start = 0;
			do {
				ret[start++] = vals[a = next[a]];
			} while (start != end);
			return new DenseMap(ret);
		}
		/**
		 * snip
		 * Snips out the values between start and end like splice, but discards the values
		 * @param	start
		 * @param	end
		 */
		public function snip(start:uint, end:uint):void {
			if (end > _length) end = _length;
			if (end <= start || start >= _length) return;
			var b:uint = end - start, i:uint = b, l:uint = start = prev[start == 0 ? starti : indexAt(start)], p:Boolean;
			while (i--) {
				nulls.push(l = next[l]);
				if (!p) if(l == midi) p = true;
			}
			prev[next[start] = next[l]] = start;
			if (p) midi = next[l];
			if ((end = hLen - (hLen = (_length -= b) >> 1))) {
				start = prev[midi];
				while (--end) start = prev[start];
				midi = start;
				q3Len = (qLen = hLen >> 1) * 3;
			}
			// TODO: check/fix snip and midi adjustment
		}
		public function inject(start:uint, ...values):DenseMap {
			if (start >= _length) { if (start == _length) return concatArray(values); return this; };
			var i:uint, end:uint = next[start = indexAt(start)], l:uint = values.length, count:uint;
			while (count < l && nulls.length) {
				vals[start = next[prev[i = nulls.pop()] = start] = i] = values[count++];
			}
			if (count < l) {
				vals.length = next.length = prev.length += l - count;
				while (count < l) {
					vals[start = next[prev[i = mLen++] = start] = i] = values[count++];
				}
			}
			_length += l;
			prev[end] = start;
			// TODO: finish inject
			return this;
		}
		public function splice(start:uint, count:uint, ...values):DenseMap {
			// TODO: create splice function
			return;
			if (start >= _length) { if (start == _length) concatArray(values); return null; };
			var i:uint, end:uint, l:uint = values.length;
			if (count) {
				start = indexAt(start);
				var ret:Array = hArray;
				ret.length = 0;
				var r:Number = l - (ret.length = count);
				if (r <= 0) {
					
				} else {
					
				}
				//dirty = true;
			} else if (l) {
				end = next[start = indexAt(start)];
				while (count < l && nulls.length) {
					vals[start = next[prev[i = nulls.pop()] = start] = i] = values[count++];
				}
				if (count < l) {
					vals.length = next.length = prev.length += l - count;
					while (count < l) {
						vals[start = next[prev[i = mLen++] = start] = i] = values[count++];
					}
				}
				prev[end] = start;
			}
			hLen = _length >> 1;
			return null;
		}
		/**
		 * flush
		 * Flushes object references from the empty portion of the DenseMap so the objects may be garbage collected.
		 */
		public function flush():void {
			if (dirty) {
				if (nulls.length) for each (var a:uint in nulls) {
					vals[a] = null;
				}
				dirty = false;
			}
		}
	}
}









