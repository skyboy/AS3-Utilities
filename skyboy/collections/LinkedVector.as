package skyboy.collections {
	import flash.utils.ByteArray;
	/**
	 *   A linked list, which is a single-dimensional chain of objects called
	 *   nodes. This implementation is doubly-linked, so each node has a link
	 *   to the next and previous node. It's API is designed to mimic that of
	 *   the top-level Array class.
	 *   @author Jackson Dunstan
	 *   @author skyboy
	 */
	public class LinkedVector {
		public static const CASEINSENSITIVE:int = 0x01;
		public static const DESCENDING:int =      0x02;
		public static const STRINGSORT:int =      0x04;
		public static const NUMERIC:int =         0x10;
		
		public static function fromArray(arr:Array):LinkedVector {
			var i:int = arr.length;
			if (!i) return new LinkedVector();
			var newNode:LinkedVectorNode = new LinkedVectorNode(arr[--i]);
			var ret:LinkedVector = new LinkedVector();
			ret.tail = newNode;
			while (i--) {
				newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode);
			}
			ret.head = newNode;
			return ret;
		}
		
		private static const emptyNode:LinkedVectorNode = new LinkedVectorNode;
		
		private const CASEINSENSITIVE:int = 0x01;
		private const DESCENDING:int =      0x02;
		private const STRINGSORT:int = 	    0x04;
		private const NUMERIC:int =         0x10;
		private const emptyNode:LinkedVectorNode = LinkedVector.emptyNode;
		
		public var head:LinkedVectorNode;
		public var tail:LinkedVectorNode;
		public function get length():uint {
			return _length;
		}
		public function set length(value:uint):void {
			if (value == _length) return;
			var tail:LinkedVectorNode = this.tail;
			if (value > 0) {
				if (_length < value) (this.tail = nodeAt(value)).next = null;
				else {
					for (var i:uint = _length; i < value; ++i) tail = tail.next = new LinkedVectorNode(null, null, tail);
					this.tail = tail;
				}
			} else tail = head = null;
			_length = value;
		}

		private var _length:uint;
		private var bytes:ByteArray = new ByteArray();

		public function LinkedVector(...values) {
			var head:LinkedVectorNode;
			var i:int, len:int = values.length;

			if (len > 1) {
				if (len == 1) {
					if (values[0] is Number) {
						i = values[0];
						_length = i;
						if (i) {
							head = tail = new LinkedVectorNode();
							while (--i) {
								head = head.prev = new LinkedVectorNode(null, head);
							}
						}
					}
				} else {
					head = tail = new LinkedVectorNode(values[i = (_length = len) - 1]);
					while (i--) {
						head = head.prev = new LinkedVectorNode(values[i], head);
					}
				}
			}
			this.head = head;
		}

		public function concat(...args):LinkedVector {
			var newNode:LinkedVectorNode, cur:LinkedVectorNode;
			var ret:LinkedVector = new LinkedVector(), len:int = _length;
			if (len) {
				// Add everything from this list
				newNode = ret.tail = (cur = tail).clone();
				while ((cur = cur.prev)) newNode = newNode.prev = new LinkedVectorNode(cur.data, newNode);
				ret.head = newNode;
				newNode = ret.tail;
			} else newNode = ret.head = emptyNode;

			// Add everything from args
			var list:LinkedVector;
			for each (var arg:* in args) {
				// Lists get flattened
				if (arg is LinkedVector) {
					list = arg;
					for (cur = list.head; cur; cur = cur.next) {
						newNode = newNode.next = new LinkedVectorNode(cur.data, null, newNode);
						++len;
					}
				} else { // No flattening for any other type, even Array
					newNode = newNode.next = new LinkedVectorNode(arg, null, newNode);
					++len;
				}
			}
			if (ret.head == emptyNode) if (emptyNode.next) emptyNode.next = (ret.head = emptyNode.next).prev = null; else ret.head = null;
			ret.tail = newNode;
			ret._length = len;
			return ret;
		}

		public function countNodes():uint {
			var i:int, cur:LinkedVectorNode = head, p:LinkedVectorNode;
			if (cur) {
				do {
					p = cur;
					cur = cur.next;
					++i;
				} while (cur);
				tail = p;
			} else tail = null;
			return _length = i;
		}

		/**
		 *   Equivalent to the Array [] operator
		 *   @param index Index of the element to get
		 *   @return The element at the given index
		 */
		public function elementAt(index:int):* {
			if (uint(index) >= _length) return null;
			return nodeAt(index).data;
		}

		public function every(callback:Function, thisObject:* = null):Boolean {
			var cur:LinkedVectorNode = head, index:int;
			if (thisObject == null) {
				for (; cur; cur = cur.next) if (!callback(cur.data, index++, this)) return false;
			} else for (; cur; cur = cur.next) if (!callback.call(thisObject, cur.data, index++, this)) return false;
			return true;
		}

		public function filter(callback:Function, thisObject:* = null):LinkedVector {
			var ret:LinkedVector = new LinkedVector();
			var index:int, cur:LinkedVectorNode = head, n:LinkedVectorNode = emptyNode;
			if (cur) {
				if (thisObject == null) {
					for (; cur; cur = cur.next) if (callback(cur.data, index++, this)) n = n.next = new LinkedVectorNode(cur.data, null, n);
				} else for (; cur; cur = cur.next) if (callback.call(thisObject, cur.data, index++, this)) n = n.next = new LinkedVectorNode(cur.data, null, n);
				emptyNode.next = (ret.head = emptyNode.next).prev = null;
				ret.tail = n;
				ret._length = index;
			}
			return ret;
		}

		public function forEach(callback:Function, thisObject:* = null):void {
			var cur:LinkedVectorNode = head, index:int;
			if (thisObject != null ) for (; cur; cur = cur.next) callback.call(thisObject, cur.data, index++, this);
			else for (; cur; cur = cur.next) callback(cur.data, index++, this);
		}

		public function indexOf(searchElement:*, fromIndex:int = 0):Number {
			var cur:LinkedVectorNode;
			if (uint(fromIndex) < _length) {
				if (fromIndex) cur = nodeAt(fromIndex); else cur = head;
				while (cur) {
					if (cur.data === searchElement) return Number(uint(fromIndex)); // Number used in place of int to allow the full address space to be used for LinkedLists
												// on more modern computers that offer more than 4 GB of RAM. ulong would be preferred.
					++fromIndex;
					cur = cur.next;
				}
			}
			return NaN; // not in list, return NaN instead of -1 since it makes more sense now that Number is used instead of int
		}

		public function join(sep:String = ","):String {
			if (!head) return "";

			var ret:ByteArray = bytes;
			ret.position = 0;
			ret.length = _length * 25; // preallocate enough space for 25 characters per element plus separator
			for (var curNode:LinkedVectorNode = head; curNode.next; curNode = curNode.next) {
				ret.writeUTFBytes(String(curNode.data));
				ret.writeUTFBytes(sep); // this can be optimized with anoter bytearray and copybytes
			}
			ret.writeUTFBytes(String(curNode.data));
			var i:int = ret.position;
			ret.position = 0;
			return ret.readUTFBytes(i);
		}

		public function lastIndexOf(searchElement:*, fromIndex:int = 0xFFFFFFFF):Number {
			var cur:LinkedVectorNode;
			if (uint(fromIndex) < _length) {
				cur = nodeAt(fromIndex);
			} else {
				cur = tail;
				fromIndex = _length;
			}
			while (cur) {
				if (cur.data === searchElement) return Number(uint(fromIndex)); // Number used in place of int to allow the full address space to be used for LinkedLists
											// on more modern computers that offer more than 4 GB of RAM. ulong would be preferred.
				--fromIndex;
				cur = cur.prev;
			}
			return NaN; // not in list, return NaN instead of -1 since it makes more sense now that Number is used instead of int
		}

		public function map(callback:Function, thisObject:* = null):LinkedVector {
			var ret:LinkedVector = new LinkedVector();
			var index:int = 0, cur:LinkedVectorNode = this.head, n:LinkedVectorNode = emptyNode;
			if (cur) {
				if (thisObject != null ) {
					for (; cur; cur = cur.next) n = n.next = new LinkedVectorNode(callback.call(thisObject, cur.data, index++, this), null, n);
				} else for (; cur; cur = cur.next) n = n.next = new LinkedVectorNode(callback(cur.data, index++, this), null, n);
				emptyNode.next = (ret.head = emptyNode.next).prev = null;
				ret.tail = n;
				ret._length = index;
			}
			return ret;
		}

		public function nodeAt(index:int):LinkedVectorNode {
			if (index >= _length) return null;

			var cur:LinkedVectorNode, hLength:uint = _length >> 1;
			if (hLength > uint(index)) {
				if (!index) return head;
				cur = head;
				while (index--) cur = cur.next;
				return cur;
			} else { // Element is in the second half, start at the end
				index = (_length - index) - 1;
				if (!index) return tail;
				cur = tail;
				while (index--) cur = cur.prev;
				return cur;
			}
		}

		public function pop():* {
			var tail:LinkedVectorNode = this.tail;
			if (!tail) return null;
			var ret:* = tail.data;
			tail = tail.prev;
			if (tail) tail.next = null;
			this.tail = tail;
			--_length;
			return ret;
		}

		public function push(...args):uint {
			var a:int = args.length;
			if (a) {
				if (!_length) {
					head = tail = new LinkedVectorNode(args[--a]);
					if (!a) return ++_length;
					++_length;
				}
				_length += a;
				var newNode:LinkedVectorNode = tail.next = new LinkedVectorNode(args[--a], null, tail);
				while (a--) newNode = newNode.next = new LinkedVectorNode(args[a], null, newNode);
				tail = newNode;
			}
			return _length;
		}

		public function pushArray(args:Array):uint {
			var a:int = args.length;
			if (a) {
				if (!_length) {
					head = tail = new LinkedVectorNode(args[--a]);
					if (!a) return ++_length;
					++_length;
				}
				_length += a;
				var newNode:LinkedVectorNode = tail.next = new LinkedVectorNode(args[--a], null, tail);
				while (a--) newNode = newNode.next = new LinkedVectorNode(args[a], null, newNode);
				tail = newNode;
			}
			return _length;
		}

		public function reverse():LinkedVector {
			var front:LinkedVectorNode = head;
			var back:LinkedVectorNode = tail;
			var temp:*;
			if (_length & 1) {
				while (back != front) {
					(temp = front.data), (front.data = back.data), back.data = temp;
					(front = front.next), back = back.prev;
				}
				return this;
			}
			while (back.next != front) {
				(temp = front.data), (front.data = back.data), back.data = temp;
				(back = back.prev), front = front.next;
			}
			return this;
		}

		public function shift():* {
			var head:LinkedVectorNode = this.head;
			if (!head) return null;
			var ret:* = head.data;
			head = head.next;
			if (head) head.prev = null;
			this.head = head;
			--_length;
			return ret;
		}

		public function slice(startIndex:int = 0, endIndex:int = 0xFFFFFFFF):LinkedVector {
			var ret:LinkedVector = new LinkedVector();
			if (int(uint(startIndex) >= _length) | int(uint(endIndex) <= uint(startIndex))) {
				return ret;
			} else if (uint(endIndex) > _length) {
				endIndex = _length;
			}
			var cur:LinkedVectorNode = startIndex == 0 ? head : nodeAt(startIndex);
			var newNode:LinkedVectorNode = new LinkedVectorNode(cur.data);
			endIndex -= startIndex;
			startIndex = 1;
			ret.head = newNode;
			while (--endIndex) {
				cur = cur.next;
				newNode = newNode.next = new LinkedVectorNode(cur.data, null, newNode);
				++startIndex;
			}
			ret._length = startIndex;
			ret.tail = newNode;
			return ret;
		}

		public function some(callback:Function, thisObject:* = null):Boolean {
			var cur:LinkedVectorNode = head, index:int;
			if (thisObject == null) {
				for (; cur; cur = cur.next) if (callback(cur.data, index++, this)) return true;
			} else for (; cur; cur = cur.next) if (callback.call(thisObject, cur.data, index++, this)) return true;
			return false;
		}

		/**
		 * sort and sortOn are based on an AS3 adaptation and optimization of:
		 * http://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
		 */
		public function sort(cmp:Function = null, options:int = 0):void {
			var p:LinkedVectorNode;
			var q:LinkedVectorNode;
			var e:LinkedVectorNode;
			var tail:LinkedVectorNode;
			var insize:int = 1;
			var nmerges:int;
			var psize:int;
			var qsize:int;
			var list:LinkedVectorNode = this.head;
			if (!list) return;

			list.prev = this.tail.next = null; // ensure no circular references

			if (options & NUMERIC) for (p = list; p; p = p.next) p.data2 = Number(p.data);
			else if (options & CASEINSENSITIVE) for (p = list; p; p = p.next) p.data2 = String(p.data).toUpperCase();
			else if (options & STRINGSORT) for (p = list; p; p = p.next) p.data2 = String(p.data);
			else for (p = list; p; p = p.next) p.data2 = p.data;

			if (Boolean(cmp)) do {
				p = list;
				list = null;
				tail = null;

				nmerges = 0;  /* count number of merges we do in this pass */

				while (p) {
					nmerges++;  /* there exists a merge to be done */
					/* step `insize' places along from p */
					q = p;
					for (psize = 0; int(psize < insize) & int(Boolean(q)); ++psize) {
						q = q.next;
					}

					qsize = insize; // if q is null, qsize is 0.

					if (!(qsize * int(Boolean(q)))) {
						e = p;
						p = p.next;
						psize--;
					} else if (!psize) {
						e = q;
						q = q.next;
						qsize--;
					} else if (cmp(p.data2, q.data2) <= 0) {
						e = p;
						p = p.next;
						psize--;
					} else {
						e = q;
						q = q.next;
						qsize--;
					}
					if (tail) {
						tail.next = e;
					} else {
						list = e;
					}
					e.prev = tail;
					tail = e;
					while (psize | (qsize * int(Boolean(q)))) {
						if (!(qsize * int(Boolean(q)))) {
							e = p;
							p = p.next;
							psize--;
						} else if (!psize) {
							e = q;
							q = q.next;
							qsize--;
						} else if (cmp(p.data2, q.data2) <= 0) {
							e = p;
							p = p.next;
							psize--;
						} else {
							e = q;
							q = q.next;
							qsize--;
						}

						tail.next = e;
						e.prev = tail;
						tail = e;
					}

					/* now p has stepped `insize' places along, and q has too */
					p = q;
				}
				tail.next = null;

				insize *= 2;
			} while (nmerges > 1); else do {
				p = list;
				list = null;
				tail = null;

				nmerges = 0;  /* count number of merges we do in this pass */

				while (p) {
					nmerges++;  /* there exists a merge to be done */
					/* step `insize' places along from p */
					q = p;
					for (psize = 0; int(psize < insize) & int(Boolean(q)); ++psize) {
						q = q.next;
					}

					qsize = insize; // if q is null, qsize is 0.

					if (!(qsize * int(Boolean(q)))) {
						e = p;
						p = p.next;
						psize--;
					} else if (!psize) {
						e = q;
						q = q.next;
						qsize--;
					} else if (p.data2 <= q.data2) {
						e = p;
						p = p.next;
						psize--;
					} else {
						e = q;
						q = q.next;
						qsize--;
					}
					if (tail) {
						tail.next = e;
					} else {
						list = e;
					}
					e.prev = tail;
					tail = e;
					while (psize | (qsize * int(Boolean(q)))) {
						if (!(qsize * int(Boolean(q)))) {
							e = p;
							p = p.next;
							psize--;
						} else if (!psize) {
							e = q;
							q = q.next;
							qsize--;
						} else if (p.data2 <= q.data2) {
							e = p;
							p = p.next;
							psize--;
						} else {
							e = q;
							q = q.next;
							qsize--;
						}

						tail.next = e;
						e.prev = tail;
						tail = e;
					}

					/* now p has stepped `insize' places along, and q has too */
					p = q;
				}
				tail.next = null;

				insize *= 2;
			} while (nmerges > 1);
			this.head = list;
			this.tail = tail;
		}

		public function sortOn(fieldName:Object, options:int = 0):void {
			var p:LinkedVectorNode;
			var q:LinkedVectorNode;
			var e:LinkedVectorNode;
			var tail:LinkedVectorNode;
			var insize:int = 1;
			var nmerges:int;
			var psize:int;
			var qsize:int;
			var list:LinkedVectorNode = this.head;
			if (!list) return;

			list.prev = this.tail.next = null; // ensure no circular references from user code

			if (options & NUMERIC) for (p = list; p; p = p.next) p.data2 = Number(p.data[fieldName]);
			else if (options & CASEINSENSITIVE) for (p = list; p; p = p.next) p.data2 = String(p.data[fieldName]).toUpperCase();
			else for (p = list; p; p = p.next) p.data2 = String(p.data[fieldName]);

			do {
				p = list;
				list = null;
				tail = null;

				nmerges = 0;  /* count number of merges we do in this pass */

				while (p) {
					nmerges++;  /* there exists a merge to be done */
					/* step `insize' places along from p */
					q = p;
					for (psize = 0; int(psize < insize) & int(Boolean(q)); ++psize) {
						q = q.next;
					}

					qsize = insize;

					if (!(qsize * int(Boolean(q)))) {
						e = p;
						p = p.next;
						psize--;
					} else if (!psize) {
						e = q;
						q = q.next;
						qsize--;
					} else if (p.data2 <= q.data2) {
						e = p;
						p = p.next;
						psize--;
					} else {
						e = q;
						q = q.next;
						qsize--;
					}
					if (tail) {
						tail.next = e;
					} else {
						list = e;
					}
					e.prev = tail;
					tail = e;
					while (psize | (qsize * int(Boolean(q)))) {
						if (!(qsize * int(Boolean(q)))) {
							e = p;
							p = p.next;
							psize--;
						} else if (!psize) {
							e = q;
							q = q.next;
							qsize--;
						} else if (p.data2 <= q.data2) {
							e = p;
							p = p.next;
							psize--;
						} else {
							e = q;
							q = q.next;
							qsize--;
						}

						tail.next = e;
						e.prev = tail;
						tail = e;
					}

					p = q;
				}
				tail.next = null;

				insize *= 2;
			} while (nmerges > 1);
			this.head = list;
			this.tail = tail;
		}

		public function splice(startIndex:int, deleteCount:int, ...values):LinkedVector {
			var ret:LinkedVector = new LinkedVector(), cur:LinkedVectorNode, tempNode:LinkedVectorNode;
			if (int(startIndex >= _length) | int(!(values.length | deleteCount))) return ret;
			else if (deleteCount != 0) {
				var endIndex:int = startIndex + deleteCount;
				if (endIndex >= _length) {
					if (startIndex == 0) {
						ret.head = head;
						ret.tail = tail;
						head = tail = null;
						_length = 0;
						unshift.apply(this, values);
						return ret;
					} else {
						cur = nodeAt(_length = startIndex);
						ret.tail = tail;
						(ret.head = cur.next || tail).prev = null;
						(tail = cur).next = null;
						push.apply(this, values);
						return ret;
					}
				} else {
					_length += values.length - deleteCount;
					if (startIndex == 0) {
						ret.head = head;
						head = nodeAt(deleteCount);
						(ret.tail = head.prev).next = null;
						var temp:LinkedVector = fromArray(values);
						(temp.tail.next = head).prev = temp.tail;
						head = temp.head;
						return ret;
					} else {
						cur = nodeAt(startIndex);
						startIndex = endIndex - startIndex - 1;
						if (startIndex > _length - endIndex) tempNode = nodeAt(endIndex + 1);
						else for (tempNode = cur; startIndex--; ) tempNode = tempNode.next;
						(ret.head = cur.next).prev = cur.next = (ret.tail = tempNode.prev).next = tempNode.prev = null;
						var t:LinkedVectorNode = tail;
						tail = cur;
						push.apply(this, values);
						(tail.next = tempNode).prev = tail;
						tail = t;
						return ret;
					}
				}
			} else {
				if (startIndex == 0) {
					unshift.apply(this, values);
				} else {
					if (startIndex == _length -1) {
						push.apply(this, values);
					} else {
						cur = tail;
						tempNode = (tail = nodeAt(startIndex)).next;
						push.apply(this, values);
						(tail.next = tempNode).prev = tail;
						tail = cur;
					}
				}
			}
			return ret;
		}

		public function toLocaleString():String {
			if (!this.head) return "";

			var ret:String = "", a:*;
			for (var curNode:LinkedVectorNode = this.head; curNode; curNode = curNode.next) {
				ret += ((a = curNode.data) ? a.toLocaleString() : String(a)) + ",";
			}
			return ret.substr(0, ret.length-1);
		}

		public function toString():String {
			if (!head) return "";

			var ret:ByteArray = bytes;
			ret.position = 0;
			ret.length = _length * 25; // preallocate enough space for 25 characters per element plus separator
			for (var curNode:LinkedVectorNode = head; curNode.next; curNode = curNode.next) {
				ret.writeUTFBytes(String(curNode.data));
				ret[ret.position++] = 0x2C;
			}
			ret.writeUTFBytes(String(curNode.data));
			var i:int = ret.position;
			ret.position = 0;
			return ret.readUTFBytes(i);
		}

		public function toVector(fixed:Boolean = false):Vector.<*> {
			var ret:Vector.<*> = new Vector.<*>(_length, fixed);
			var i:int;
			for (var cur:LinkedVectorNode = head; cur; cur = cur.next) {
				ret[i++] = cur.data;
			}
			return ret;
		}

		public function toArray():Array {
			var ret:Array = new Array(_length);
			var i:int;
			for (var cur:LinkedVectorNode = head; cur; cur = cur.next) {
				ret[i++] = cur.data;
			}
			return ret;
		}

		public function unshift(...args):uint {
			var a:int = args.length;
			if (a) {
				if (!_length) {
					head = tail = new LinkedVectorNode(args[--a]);
					if (!a) return ++_length;
					++_length;
				}
				_length += a
				var newNode:LinkedVectorNode = head.prev = new LinkedVectorNode(args[--a], head);
				while (a--) newNode = newNode.prev = new LinkedVectorNode(args[a], newNode);
				head = newNode;
			}
			return _length;
		}

		public function unshiftArray(args:Array):uint {
			var a:int = args.length;
			if (a) {
				if (!_length) {
					head = tail = new LinkedVectorNode(args[--a]);
					if (!a) return ++_length;
					++_length;
				}
				_length += a
				var newNode:LinkedVectorNode = head.prev = new LinkedVectorNode(args[--a], head);
				while (a--) newNode = newNode.prev = new LinkedVectorNode(args[a], newNode);
				head = newNode;
			}
			return _length;
		}

	}
}
