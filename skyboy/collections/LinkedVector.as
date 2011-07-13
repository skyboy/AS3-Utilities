package skyboy.collections {
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
		private const CASEINSENSITIVE:int = 0x01;
		private const DESCENDING:int =      0x02;
		private const STRINGSORT:int = 	    0x04;
		private const NUMERIC:int =         0x10;
		public var head:LinkedVectorNode;
		public var tail:LinkedVectorNode;
		private var _length:uint;
		private static var emptyNode:LinkedVectorNode = new LinkedVectorNode;
		private var emptyNode:LinkedVectorNode = LinkedVector.emptyNode;
		public function get length():uint {
			return _length;
		}
			
		public function set length(value:uint):void {
			if (value == _length) return;
			if (value > 0) {
				if (_length < value) (tail = nodeAt(value)).next = null;
				else if (value - _length == 1) tail = tail.next = new LinkedVectorNode(null, null, tail);
				else for (var i:int = _length; i < value; ++i) {
					head = head.prev = new LinkedVectorNode(null, head);
				}
			} else tail = head = null;
			_length = value;
		}

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

		/**
		 *   Equivalent to the Array [] operator
		 *   @param index Index of the element to get
		 *   @return The element at the given index
		 */
		public function elementAt(index:int):* {
			if (index < 0) {
				throw new TypeError("Error #2007");
			} else if (index >= _length) {
				return null;
			}
			return nodeAt(index).data;
		}

		private var lastNodeAt:LinkedVectorNode, lastNodeAtI:uint;
		public function nodeAt(index:int):LinkedVectorNode {
			if (index >= _length) {
				return null;
			} else {
				var cur:LinkedVectorNode, hLength:uint = _length >> 1;
				if (hLength > index) {
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
		}

		public function concat(...args):LinkedVector {
			var newNode:LinkedVectorNode, cur:LinkedVectorNode;
			var ret:LinkedVector = new LinkedVector();
			if (_length) {
				// Add everything from this list
				newNode = ret.tail = (cur = tail).clone();
				while ((cur = cur.prev)) { newNode = newNode.prev = cur.clone(newNode); }
				ret.head = newNode;
			}
			newNode = ret.tail;

			// Add everything from args
			var list:LinkedVector;
			for each (var arg:* in args) {
				// Lists get flattened
				if (arg is LinkedVector) {
					list = arg;
					for (cur = list.head; cur; cur = cur.next) {
						newNode.next = (newNode = new LinkedVectorNode(cur.data, null, newNode));
					}
				} else { // No flattening for any other type, even Array
					newNode.next = (newNode = new LinkedVectorNode(arg, null, newNode));
				}
			}
			ret.tail = newNode;
			return ret;
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
			var cur:LinkedVectorNode = head, index:int, n:LinkedVectorNode = emptyNode;
			if (thisObject == null) {
				for (; cur; cur = cur.next) if (callback(cur.data, index++, this)) n = n.next = new LinkedVectorNode(cur.data, null, n);
			} else for (; cur; cur = cur.next) if (callback.call(thisObject, cur.data, index++, this)) n = n.next = new LinkedVectorNode(cur.data, null, n);
			emptyNode.next = (ret.head = emptyNode.next).prev = null;
			ret.tail = null;
			
			return ret;
		}

		public function forEach(callback:Function, thisObject:* = null):void {
			var cur:LinkedVectorNode = head, index:int;
			if (thisObject != null ) for (; cur; cur = cur.next) callback.call(thisObject, cur.data, index++, this);
			else for (; cur; cur = cur.next) callback(cur.data, index++, this);
		}

		public function indexOf(searchElement:*, fromIndex:int = 0):int {
			var cur:LinkedVectorNode, index:int;
			if (fromIndex < _length) {
				cur = nodeAt(fromIndex);
				index = _length - fromIndex;
			} else {
				cur = head;
				index = _length;
			}
			while (cur) {
				if (cur.data === searchElement) return index;
				--index;
				cur = cur.next;
			}
			return -1;
		}

		public function join(sep:String = ","):String {
			if (!head) {
				return "";
			}

			var ret:String = "";
			for (var curNode:LinkedVectorNode = head; curNode.next; curNode = curNode.next) {
				ret += curNode.data + sep;
			}
			return ret + curNode.data;
		}

		public function lastIndexOf(searchElement:*, fromIndex:uint = 0x7FFFFFFF):int {
			var cur:LinkedVectorNode, index:int;
			if (fromIndex < _length) {
				cur = nodeAt(index = fromIndex);
			} else {
				cur = tail;
				index = _length;
			}
			while (cur) {
				if (cur.data === searchElement) return index;
				--index;
				cur = cur.prev;
			}
			return -1;
		}

		public function map(callback:Function, thisObject:* = null):LinkedVector {
			var ret:LinkedVector = new LinkedVector();
			var index:int = 0, cur:LinkedVectorNode = this.head;
			var n:LinkedVectorNode = emptyNode;
			if (thisObject != null ) {
				for (; cur; cur = cur.next) n = n.next = new LinkedVectorNode(callback.call(thisObject, cur.data, index++, this), null, n);
			} else for (; cur; cur = cur.next) n = n.next = new LinkedVectorNode(callback(cur.data, index++, this), null, n);
			emptyNode.next = (ret.head = emptyNode.next).prev = null;
			ret.tail = null;
			return ret;
		}

		public function pop():* {
			if (!tail) return null;
			var ret:* = tail.data;
			return ((tail = tail.prev), --_length, ret);
		}

		public function push(...args):uint {
			var a:int = args.length;
			if (a) {
				if (a == 1) {
					if (_length == 0) {
						head = tail = new LinkedVectorNode(args[0]);
						return _length = 1;
					}
					tail = tail.next = new LinkedVectorNode(args[0], null, tail);
					return ++_length;
				} else if (_length == 0) {
					head = tail = new LinkedVectorNode(args[--a]);
					if (a == 0) return ++_length;
				}
				_length += a;
				var newNode:LinkedVectorNode = tail.next = new LinkedVectorNode(args[--a], null, tail);
				while (a) { newNode = newNode.next = new LinkedVectorNode(args[--a], null, newNode); }
				tail = newNode;
				return _length;
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
			if (!head) return null;
			var ret:* = head.data;
			return ((head = head.next), --_length, ret);
		}

		public function unshift(...args):uint {
			var a:int = args.length;
			if (a) {
				if (a == 1) {
					if (_length == 0) {
						head = tail = new LinkedVectorNode(args[0]);
						return _length = 1;
					}
					head = head.prev = new LinkedVectorNode(args[0], head);
					return ++_length;
				} else if (_length == 0) {
					head = tail = new LinkedVectorNode(args[--a]);
					if (a == 0) return ++_length;
				}
				_length += a
				var newNode:LinkedVectorNode = head.prev = new LinkedVectorNode(args[--a], head);
				while (a) {
					newNode = newNode.prev = new LinkedVectorNode(args[--a], newNode);
				}
				head = newNode;
				return _length;
			}
			return _length;
		}

		public function slice(startIndex:int = 0, endIndex:int = 2147483647):LinkedVector {
			var ret:LinkedVector = new LinkedVector();
			if (int(startIndex >= _length) | int(endIndex <= startIndex)) {
				return ret;
			} else if (endIndex > _length) {
				endIndex = _length;
			}
			var cur:LinkedVectorNode = startIndex == 0 ? head : nodeAt(startIndex);
			var newNode:LinkedVectorNode = new LinkedVectorNode(cur.data);
			endIndex -= startIndex;
			ret.head = newNode;
			while (--endIndex) {
				cur = cur.next;
				newNode.next = new LinkedVectorNode(cur.data, null, newNode);
				newNode = newNode.next;
			}
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
		public function sort(cmp:Function, options:int = 0):void {
			var p:LinkedVectorNode;
			var q:LinkedVectorNode;
			var e:LinkedVectorNode;
			var tail:LinkedVectorNode;
			var insize:int = 2;
			var nmerges:int;
			var psize:int;
			var qsize:int;
			var list:LinkedVectorNode = this.head;
			if (!list) return;

			if (options & NUMERIC) for (p = list; p; p = p.next) p.data2 = Number(p.data);
			else if (options & CASEINSENSITIVE) for (p = list; p; p = p.next) p.data2 = String(p.data).toUpperCase();
			else if (options & STRINGSORT) for (p = list; p; p = p.next) p.data2 = String(p.data);
			else for (p = list; p; p = p.next) p.data2 = p.data;

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

					qsize = insize * int(Boolean(q)); // if q is null, qsize is 0.

					while (psize | qsize) {
						/* decide whether next element of merge comes from p or q */
						if (!qsize) {
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
		
						/* add the next element to the merged list */
						if (tail) {
							tail.next = e;
						} else {
							list = e;
						}
						/* Maintain reverse pointers in a doubly linked list. */
						e.prev = tail;
						tail = e;
					}

					/* now p has stepped `insize' places along, and q has too */
					p = q;
				}
				tail.next = null;

				insize *= 2;
			} while (nmerges <= 1);
			this.head = list;
			this.tail = tail;
		}

		public function sortOn(fieldName:Object, options:int = 0):void {
			var p:LinkedVectorNode;
			var q:LinkedVectorNode;
			var e:LinkedVectorNode;
			var tail:LinkedVectorNode;
			var insize:int = 2;
			var nmerges:int;
			var psize:int;
			var qsize:int;
			var list:LinkedVectorNode = this.head;
			if (!list) return;

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

					qsize = insize * int(Boolean(q)); // if q is null, qsize is 0.

					while (psize | qsize) {
						/* decide whether next element of merge comes from p or q */
						if (!qsize) {
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
		
						/* add the next element to the merged list */
						if (tail) {
							tail.next = e;
						} else {
							list = e;
						}
						/* Maintain reverse pointers in a doubly linked list. */
						e.prev = tail;
						tail = e;
					}

					/* now p has stepped `insize' places along, and q has too */
					p = q;
				}
				tail.next = null;

				insize *= 2;
			} while (nmerges <= 1);
			this.head = list;
			this.tail = tail;
		}

		public function splice(startIndex:int, deleteCount:int, ...values):LinkedVector {
			var ret:LinkedVector = new LinkedVector(), cur:LinkedVectorNode, tempNode:LinkedVectorNode;
			if (startIndex > _length) return ret;
			else if (deleteCount > 0) {
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
						tempNode = nodeAt(endIndex + 1);
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
						tail.next = tempNode;
						tail = cur;
					}
				}
			}
			return ret;
		}

		public function toString():String {
			if (!this.head) {
				return "";
			}

			var ret:String = "";
			for (var curNode:LinkedVectorNode = head; curNode.next; curNode = curNode.next) {
				ret += curNode.data + ",";
			}
			return ret + curNode.data;
		}

		public function toLocaleString():String {
			if (!this.head) {
				return "";
			}

			var ret:String = "", a:*;
			for (var curNode:LinkedVectorNode = this.head; curNode; curNode = curNode.next) {
				ret += ((a = curNode.data) ? a.toLocaleString() : String(a)) + ",";
			}
			return ret.substr(0, ret.length-1);
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

		public static function fromArray(arr:Array):LinkedVector {
			var i:int = arr.length, newNode:LinkedVectorNode = new LinkedVectorNode(arr[i - 1]);
			var ret:LinkedVector = new LinkedVector();
			ret.tail = newNode;
			while (i--) {
				newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode);
			}
			ret.head = new LinkedVectorNode(arr[0], newNode);
			return ret;
		}
	}
}
