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
		public var head:LinkedVectorNode;
		public var tail:LinkedVectorNode;
		private var _length:uint;
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
			var i:int;
			var len:int = values.length;

			// Equivalent to Array(len)
			if (len == 1) {
				if ((i = int(values[0])) > 0) {
					_length = i;
					head = tail = new LinkedVectorNode();
					while (--i) {
						head = head.prev = new LinkedVectorNode(null, head);
					}
				}
			} else if (len > 1) { // Equivalent to Array(value0, value1, ..., valueN)
				head = tail = new LinkedVectorNode(values[i = (_length = len) - 1]);
				while (i--) {
					head = head.prev = new LinkedVectorNode(values[i], head);
				}
			}
			this.head = head;
		}

		/**
		 *   Equivalent to the Array [] operator
		 *   @param index Index of the element to get
		 *   @return The element at the given index
		 */
		public function elementAt(index:int):Object {
			if (index < 0) {
				throw new TypeError("Error #2007");
			} else if (index >= _length) {
				return null;
			}
			return nodeAt(index).data;
		}

		private var lastNodeAt:LinkedVectorNode, lastNodeAtI:uint;
		public function nodeAt(index:uint):LinkedVectorNode {
			if (index >= _length) {
				return null;
			} /*else if (lastNodeAtI == index, false) {
				return lastNodeAt;
			}*/ else {
				var cur:LinkedVectorNode, hLength:uint = _length >> 1;
				/*lastNodeAtI = index;*/
				// Element is in the first half, start at beginning
				if (hLength > index) {
					if (index == 0) return head;
					cur = head.next;
					while (--index > 0) { cur = cur.next; }
					return /*lastNodeAt =*/ cur;
				} else { // Element is in the second half, start at the end
					index = _length - index;
					if (index-- == 1) return tail;
					cur = tail.prev;
					while (--index > 0) { cur = cur.prev; }
					return /*lastNodeAt =*/ cur;
				}
			}
		}

		public function concat(...args):LinkedVector {
			var newNode:LinkedVectorNode, cur:LinkedVectorNode;
			var ret:LinkedVector = new LinkedVector();
			if (_length) {
				// Add everything from this list
				newNode = ret.tail = (cur = tail).clone();
				while ((cur = cur.prev)) {newNode = newNode.prev = new LinkedVectorNode(cur.data, newNode);}
				ret.head = newNode;
			}

			// Add everything from args
			var list:LinkedVector;
			for each (var arg:* in args) {
				// Lists get flattened
				if (arg is LinkedVector) {
					list = arg;
					for (cur = list.head; cur; cur = cur.next) {
						newNode = new LinkedVectorNode(cur.data);
						newNode.prev = ret.tail;
						if (ret.tail) {
							ret.tail.next = newNode;
						} else {
							ret.head = newNode;
						}
						ret.tail = newNode;
					}
				} else if (arg is Object) { // No flattening for any other type, even Array
					newNode = new LinkedVectorNode(arg);
					newNode.prev = ret.tail;
					if (ret.tail) {
						ret.tail.next = newNode;
					} else {
						ret.head = newNode;
					}
					ret.tail = newNode;
				}
			}
			return ret;
		}

		public function every(callback:Function, thisObject:* = null):Boolean {
			var cur:LinkedVectorNode = head, index:int;
			if (thisObject != null) for (; cur; cur = cur.next) if (!callback.call(thisObject, cur.data, index++, this)) return false;
			else for (; cur; cur = cur.next) if (!callback(cur.data, index++, this)) return false;
			return true;
		}

		public function filter(callback:Function, thisObject:*=null):LinkedVector {
			var ret:LinkedVector = new LinkedVector();
			var index:int = 0;
			var newNode:LinkedVectorNode;
			for (var cur:LinkedVectorNode = this.head; cur; cur = cur.next) {
				if (callback.call(thisObject, cur.data, index, this)) {
					newNode = new LinkedVectorNode(cur.data);
					newNode.prev = ret.tail;
					if (ret.tail) {
						ret.tail.next = newNode;
					} else {
						ret.head = newNode;
					}
					ret.tail = newNode;
				}
				index++;
			}
			return ret;
		}

		public function forEach(callback:Function, thisObject:* = null):void {
			var cur:LinkedVectorNode = head, index:int;
			if (thisObject != null ) for (; cur; cur = cur.next) callback.call(thisObject, cur.data, index++, this);
			else for (; cur; cur = cur.next) callback(cur.data, index++, this);
		}

		public function indexOf(searchElement:Object, fromIndex:int = 0):int {
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
				if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.next).data === searchElement) return index;
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
			for (var curNode:LinkedVectorNode = head; curNode; curNode = curNode.next) {
				ret += curNode.data + sep;
			}
			return ret.substr(0, ret.length-sep.length);
		}

		public function lastIndexOf(searchElement:Object, fromIndex:uint = 0x7FFFFFFF):int {
			var cur:LinkedVectorNode, index:int;
			if (fromIndex < _length) {
				cur = nodeAt(index = fromIndex);
			} else {
				cur = tail;
				index = _length;
			}
			while (cur) {
				if (cur.data === searchElement) return index;
				if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				else if (index-- > 0) if((cur = cur.prev).data === searchElement) return index;
				--index;
				cur = cur.prev;
			}
			return -1;
		}

		public function map(callback:Function, thisObject:* = null):LinkedVector {
			var ret:LinkedVector = new LinkedVector();
			var index:int = 0;
			var newNode:LinkedVectorNode;
			for (var cur:LinkedVectorNode = this.head; cur; cur = cur.next) {
				newNode = new LinkedVectorNode(callback.call(thisObject, cur.data, index++, this));
				newNode.prev = ret.tail;
				if (ret.tail) {
					ret.tail.next = newNode;
				} else {
					ret.head = newNode;
				}
				ret.tail = newNode;
			}
			return ret;
		}

		public function pop():Object {
			if (!tail) return null;
			var ret:Object = tail.data;
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
			var temp:Object;
			if (_length & 1) {
				while (back != front) {
					(temp = front.data), (front.data = back.data), back.data = temp;
					if ((front = front.next) != (back = back.prev)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
					if ((front = front.next) != (back = back.prev)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
					if ((front = front.next) != (back = back.prev)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
					if ((front = front.next) != (back = back.prev)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
					(front = front.next), back = back.prev;
				}
				return this;
			}
			while (back.next != front) {
				(temp = front.data), (front.data = back.data), back.data = temp;
				if ((back = back.prev).next != (front = front.next)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
				if ((back = back.prev).next != (front = front.next)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
				if ((back = back.prev).next != (front = front.next)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
				if ((back = back.prev).next != (front = front.next)) (temp = front.data), (front.data = back.data), back.data = temp; else return this;
				(back = back.prev), front = front.next;
			}
			return this;
		}

		public function shift():Object {
			if (!head) return null;
			var ret:Object = head.data;
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
			if (startIndex >= _length || endIndex <= startIndex) {
				return ret;
			}/* else if (startIndex == 0 && endIndex >= _length) {
				return fromArray(toArray());
			}*/ else if (endIndex > _length) {
				endIndex = _length - startIndex;
			}
			var cur:LinkedVectorNode = startIndex == 0 ? head : nodeAt(startIndex);
			var newNode:LinkedVectorNode = ret.head = new LinkedVectorNode(cur.data);
			while (--endIndex) {
				newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode);
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
				if (--endIndex) newNode = newNode.next = new LinkedVectorNode((cur = cur.next).data, null, newNode); else break;
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

		public function sort(compareFn:Function = null, options:Object = null):LinkedVector {
		//public function sort(...args):LinkedVector {
			return fromArray(compareFn == null ? toArray().sort() : toArray().sort(compareFn, options));
		}

		public function sortOn(fieldName:Object, options:Object = null):LinkedVector {
			return fromArray(toArray().sortOn(fieldName, options));
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
			for (var curNode:LinkedVectorNode = head; curNode; curNode = curNode.next) {
				ret += curNode.data + ",";
			}
			return ret.substr(0, ret.length-1);
		}

		public function toLocaleString():String {
			if (!this.head) {
				return "";
			}

			var ret:String = "", a:Object;
			for (var curNode:LinkedVectorNode = this.head; curNode; curNode = curNode.next) {
				ret += ((a = curNode.data) ? a.toLocaleString() : String(a)) + ",";
			}
			return ret.substr(0, ret.length-1);
		}

		public function toVector(fixed:Boolean = false):Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>(_length, fixed);
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
				if ((cur = cur.next)) ret[i++] = cur.data; else break;
				if ((cur = cur.next)) ret[i++] = cur.data; else break;
				if ((cur = cur.next)) ret[i++] = cur.data; else break;
				if ((cur = cur.next)) ret[i++] = cur.data; else break;
				if ((cur = cur.next)) ret[i++] = cur.data; else break;
			}
			return ret;
		}

		public static function fromArray(arr:Array):LinkedVector {
			var i:int = arr.length, newNode:LinkedVectorNode = new LinkedVectorNode(arr[i - 1]);
			var ret:LinkedVector = new LinkedVector();
			ret.tail = newNode;
			while (0 < --i) {
				newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode);
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
			}
			ret.head = new LinkedVectorNode(arr[0], newNode);
			return ret;
		}
		private function fromArray(arr:Array):LinkedVector {
			var i:int = arr.length, newNode:LinkedVectorNode = new LinkedVectorNode(arr[i - 1]);
			var ret:LinkedVector = new LinkedVector();
			ret.tail = newNode;
			while (0 < --i) {
				newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode);
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
				if (0 < --i) newNode = newNode.prev = new LinkedVectorNode(arr[i], newNode); else break;
			}
			ret.head = new LinkedVectorNode(arr[0], newNode);
			return ret;
		}
	}
}
 /**
  *   A node in a linked list. Its purpose is to hold the data in the
  *   node as well as links to the previous and next nodes.
  *   @author Jackson Dunstan
  *   @author skyboy
  */
 internal class LinkedVectorNode {
	public var next:LinkedVectorNode;
	public var prev:LinkedVectorNode;
	public var data:Object;
	public function LinkedVectorNode(data:Object = null, next:LinkedVectorNode = null, prev:LinkedVectorNode = null) {
		this.data = data;
		this.next = next;
		this.prev = prev;
	}
	public function clone(next:LinkedVectorNode = null, prev:LinkedVectorNode = null):LinkedVectorNode {
		return new LinkedVectorNode(data, next, prev);
	}
}
