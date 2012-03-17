package skyboy.utils {
	/**
	 * fastSort by skyboy. February 26th 2011.
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
	/**
	 * fastSort(* obj, uint options [, uint length, uint startIndex] );
	 * fastSort(* obj, String name, uint options [, uint length, uint startIndex] );
	 * fastSort(* obj, Function sortFunc, uint options [, uint length, uint startIndex] );
	 * fastSort(* obj, Function sortFunc, String name, uint options [, uint length, uint startIndex] );
	 *
	 * @param	       *: input     	The object to be sorted. Any object that has numeric indicies. (required, non-null)
	 * @param	Function: sortFunc  	A function to be passed two objects being sorted that returns a negative number when a < b, positive when b > a and 0 when a == b. (optional)
	 * @param	  String: name      	The name of the property to be sorted on. (optional)
	 * @param	    uint: options   	Sorting options. 16 for numeric sort, 2 for descending sort, 1 for case insensitive sort, 4 to force String sort when sorting with a Function (the default). Options can be combined with |. (optional, default: 0)
	 * @param	    uint: length    	The length of the Object to be sorted. (optional if the object has a length property, required otherwise)
	 * @param	    uint: startIndex	The index to be sorting at. (optional, default: 0)
	 */
	public function fastSort(input:*, ...rest):void {
	//public function fastSort(input:*, rest0:* = 0, rest1:* = undefined, rest2:* = undefined, rest3:* = undefined):void {
		if (!input) throw new ArgumentError("Can not sort null");
		var funcO:Boolean = rest[0] is Function;
		var strI:uint = uint(funcO);
		var sortON:Boolean = rest[strI] is String;
		var optI:uint = strI + uint(sortON);
		var lenI:uint = 1 + optI;
		var startI:uint = 2 + optI;
		if (("length" in input) && (input.length is Number)) {// grab length from the input
			length = input.length;
			if (!(rest[startI] is Number)) rest[startI] = 0;
			if (rest[lenI] is Number) length = rest[lenI];
		} else {
			if (!(rest[lenI] is Number)) throw new Error("Length is unknown. Can not sort.");
			length = rest[lenI];
			if (!(rest[startI] is Number)) rest[startI] = 0;
		}
		if (!(rest[optI] is Number)) rest[optI] = 0;
		optI = rest[optI];
		optI &= ~(-int(Boolean(optI & FORCESTRING)) & NUMERIC);
		if (optI & NUMERIC) numVec.length = length + rest[startI];
		else sortVec.length = length + rest[startI];
		if (funcO) {
			if (sortON) sortByOn(input, rest[strI], optI, length, rest[startI], rest[0]);
			else sortBy(input, optI, length, rest[startI], rest[0]);
		} else if (sortON) {
			if (optI & NUMERIC) {
				sortOnNumber(input, rest[0], optI, length, rest[startI]);// all values (gain from Number Vector more significant than strong typing sorted-value)
			} else {
				if (input is Array) {
					sortOnArray(input, rest[0], optI, length, rest[startI]);
				} else if (input is Vector.<*>) {// numeric vectors not included (how would one sortOn a range of Numbers?)
					sortOn(input, rest[0], optI, length, rest[startI]);
				} else {
					sortOnObject(input, rest[0], optI, length, rest[startI]);
				}
			}
		} else {
			f = LookupTable[input.constructor];
			if (Boolean(f)) f(input, optI, length, rest[startI]);
			else sortObject(input, optI, length, rest[startI]);
		}
		sortVec.length = 0;// clear the vectors (O(1) operation)
		numVec.length = 0;
		return;
		var length:uint = 0, f:Function = null;// avoid compiler setting default values for these
	}
	
}
//{
import flash.utils.Dictionary;
internal const NUMERIC:uint 			= Array.NUMERIC;
internal const DESCENDING:uint 			= Array.DESCENDING;
internal const CASEINSENSITIVE:uint 	= Array.CASEINSENSITIVE;
internal const FORCESTRING:uint 		= Array.UNIQUESORT;
// internal const STABLESORT:uint 			= Array.RETURNINDEXEDARRAY;
internal const sortVec:Vector.<*> 		= new Vector.<*>(0xFFFF);
internal const numVec:Vector.<Number> 	= new Vector.<Number>(0xFFFF);
internal const LookupTable:Dictionary 	= new Dictionary;
LookupTable[Vector.<Number>] 			= sortNumber;
LookupTable[Vector.<int>] 				= sortInt;
LookupTable[Vector.<uint>] 				= sortUint;
LookupTable[Vector.<*>] 				= sortVector;
LookupTable[Array] 						= sortArray;
internal function quickSort(input:Vector.<*>, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left--] = input[left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSort(input, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOn(input:Vector.<*>, sInput:Vector.<*>, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					if (pivotPoint > input[left]) {
						pivotPoint = input[left];
						t = sInput[left];
						do {
							input[left] = input[left - 1];
							sInput[left] = sInput[--left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do {
				--right;
			} while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do {
				++left;
			} while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOn(input, sInput, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortArray(input:Array, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right, i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left--] = input[left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortArray(input, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnArray(input:Vector.<*>, sInput:Array, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					if (pivotPoint > input[left]) {
						pivotPoint = input[left];
						t = sInput[left];
						do {
							input[left] = input[left - 1];
							sInput[left] = sInput[--left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do {
				--right;
			} while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do {
				++left;
			} while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnArray(input, sInput, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortObject(input:Object, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left--] = input[left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortObject(input, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnObject(input:Vector.<*>, sInput:Object, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					if (pivotPoint > input[left]) {
						pivotPoint = input[left];
						t = sInput[left];
						do {
							input[left] = input[left - 1];
							sInput[left] = sInput[--left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do {
				--right;
			} while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do {
				++left;
			} while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnObject(input, sInput, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnNumber(input:Vector.<Number>, sInput:Object, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:Number = input[uint((right >>> 1) + (left >>> 1))];
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					e = input[left];
					if (pivotPoint > e) {
						pivotPoint = e;
						t = sInput[left];
						do {
							q = left--;
							e = input[left];
							input[q] = e;
							sInput[q] = sInput[left];
						} while (int(left > i) & int(pivotPoint < e));
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			f = input[right];
			while (f > pivotPoint) {
				--right;
				f = input[right];
			}
			e = input[left];
			while (e < pivotPoint) {
				++left;
				e = input[left];
			}
			if (left < right) {
				input[left] = f;
				input[right] = e;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (left === right) {
			e = input[left];
			q = int(e >= pivotPoint);
			q &= int(right > 0);
			right -= q;
			q = int(e <= pivotPoint);
			left += q;
		}
		if (i < right)
			quickSortOnNumber(input, sInput, i, right, d + 1);
		if (j > left) {
			i = left;
			right = j;
			pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
			size = right - left;
			++d;
		} else break
	} while (true);
	return;
	var e:Number = 0, f:Number = 0, t:* = undefined, q:int = 0;
}
internal function quickSortByObject(input:Object, left:int, right:int, c:Function):void { // >0 = a>b; <0 = a<b; =0 = b==a
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*, e:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					e = input[left];
					if (c(pivotPoint, e) > 0) {
						pivotPoint = e;
						do {
							size = left--;
							e = input[left];
							input[size] = e;
						} while (left > i && c(pivotPoint, e) < 0);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			t = input[right];
			while (c(t, pivotPoint) > 0) {
				--right;
				t = input[right];
			}
			e = input[left];
			while (c(e, pivotPoint) < 0) {
				++left;
				e = input[left];
			}
			if (left < right) {
				input[left] = t;
				input[right] = e;
				++left, --right;
			}
		}
		if (left === right) {
			e = input[left];
			t = c(e, pivotPoint)
			size = int(t >= 0);
			size &= int(right > 0);
			right -= size;
			size = int(t <= 0);
			left += size;
		}
		if (i < right) {
			quickSortByObject(input, i, right, c);
		}
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
	} while (true);
}
internal function quickSortByOnObject(input:Vector.<*>, sInput:Object, left:int, right:int, c:Function):void { // >0 = a>b; <0 = a<b; =0 = b==a
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[uint((right >>> 1) + (left >>> 1))], t:*, e:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					e = input[left];
					if (c(pivotPoint, e) > 0) {
						pivotPoint = e;
						t = sInput[left];
						do {
							size = left--;
							e = input[left];
							input[size] = e;
							sInput[size] = sInput[left];
						} while (left > i && c(pivotPoint, e) < 0);
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			t = input[right];
			while (c(t, pivotPoint) > 0) {
				--right;
				t = input[right];
			}
			e = input[left];
			while (c(e, pivotPoint) < 0) {
				++left;
				e = input[left];
			}
			if (left < right) {
				input[left] = t;
				input[right] = e;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (left === right) {
			e = input[left];
			t = c(e, pivotPoint)
			size = int(t >= 0);
			size &= int(right > 0);
			right -= size;
			size = int(t <= 0);
			left += size;
		}
		if (i < right) {
			quickSortByOnObject(input, sInput, i, right, c);
		}
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
	} while (true);
}
internal function quickSortByOnNumber(input:Vector.<Number>, sInput:Object, left:int, right:int, c:Function):void { // >0 = a>b; <0 = a<b; =0 = b==a
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:Number = input[uint((right >>> 1) + (left >>> 1))], t:Number, e:Number, o:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					e = input[left];
					if (c(pivotPoint, e) > 0) {
						pivotPoint = e;
						o = sInput[left];
						do {
							size = left--;
							e = input[left];
							input[size] = e;
							sInput[size] = sInput[left];
						} while (left > i && c(pivotPoint, e) < 0);
						input[left] = pivotPoint;
						sInput[left] = o;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			t = input[right];
			while (c(t, pivotPoint) > 0) {
				--right;
				t = input[right];
			}
			e = input[left];
			while (c(e, pivotPoint) < 0) {
				++left;
				e = input[left];
			}
			if (left < right) {
				input[left] = t;
				input[right] = e;
				o = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = o;
				++left, --right;
			}
		}
		if (left === right) {
			e = input[left];
			t = c(e, pivotPoint)
			size = int(t >= 0);
			size &= int(right > 0);
			right -= size;
			size = int(t <= 0);
			left += size;
		}
		if (i < right) {
			quickSortByOnNumber(input, sInput, i, right, c);
		}
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
	} while (true);
}
internal function quickSortInt(input:Vector.<int>, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:int = input[uint((right >>> 1) + (left >>> 1))], t:int;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					t = input[left];
					if (t < pivotPoint) {
						pivotPoint = t;
						do {
							size = left--;
							t = input[left];
							input[size] = t;
						} while (left > i && pivotPoint < t);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortInt(input, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortUint(input:Vector.<uint>, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:uint = input[uint((right >>> 1) + (left >>> 1))], t:uint;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left] = input[(--left,left)];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortUint(input, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortNumber(input:Vector.<Number>, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:Number = input[uint((right >>> 1) + (left >>> 1))], t:Number;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left--] = input[left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortNumber(input, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[uint((right >>> 1) + (left >>> 1))];
		size = right - left;
		++d;
	} while (true);
}
internal function sort(input:Vector.<*>, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	var q:uint = startIndex, left:uint = q, right:uint = q + n;
	while (q !== right) {
		t = input[q];
		if (t === undefined) {
			--right;
			input[q] = input[right];
			input[right] = undefined;
		} else if (t === null) {
			input[q] = input[left];
			input[left] = null;
			++left;
			++q;
		} else ++q;
	}
	if (right > left) {
		q = right;
		while (q > left) {
			--q;
			t = input[q];
			if (t !== t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			}
		}
		--right;
		if (right > left) {
			if (options === NUMERIC) {
				quickSort(input, left, right, 0);
			} else {
				tempVec = sortVec;
				q = right;
				if (options & CASEINSENSITIVE) {
					tempVec[q] = String(input[q]).toLowerCase();
					while (q > left) --q, tempVec[q] = String(input[q]).toLowerCase();
				} else {
					tempVec[q] = String(input[q]);
					while (q > left) --q, tempVec[q] = String(input[q]);
				}
				quickSortOn(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		options = startIndex;
		n += options;
		while (n > options) {
			--n;
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options;
		}
	}
	return;
	var tempVec:Vector.<*>, t:*;
}
internal function sortOn(input:Vector.<*>, name:String, options:uint, n:uint, startIndex:int):void {
	if (n < 2) return;
	var left:uint = startIndex, right:uint = left + n, hnan:int;
	var tempVec:Vector.<*> = sortVec, i:uint = right, j:uint = right, t:*;
	while (j > left) {--j;
		t = input[j];
		t = t[name];
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left] = null;
			++left,++j;
		} else if (t === undefined) {
			--i,--right
			tempVec[i] = tempVec[right];
			tempVec[right] = undefined;
			t = input[right];
			input[right] = input[j];
			input[j] = t;
		} else--i, tempVec[i] = t;
		hnan |= int(t !== t);
	}
	if (right > left) {
		j = right;
		if (hnan) while (j > left) {
			--j;
			t = tempVec[j];
			if (t !== t) {
				--right
				tempVec[j] = tempVec[right];
				tempVec[right] = NaN;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		}
		--right;
		if (right > left) {
			i = left;
			if (options & CASEINSENSITIVE) {
				tempVec[i] = String(tempVec[i]).toUpperCase();
				while (i < right) ++i, tempVec[i] = String(tempVec[i]).toUpperCase();
			} else {
				tempVec[i] = String(tempVec[i]);
				while (i < right) ++i, tempVec[i] = String(tempVec[i]);
			}
			quickSortOn(tempVec, input, left, right, 0);
		}
	}
	if (options & DESCENDING) {
		i = startIndex,
		options = n + i;
		while (n > i) {
			--options;
			t = input[i];
			input[i] = input[options];
			input[options] = t;
			++i;
		}
	}
}
internal function sortArray(input:Array, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	if (options & NUMERIC) {
		sortObjectNumber(input, startIndex, n);
	} else {
		q = startIndex, left = q, right = q + n, hnan = 1;
		while (q !== right) {
			t = input[q];
			if (t === undefined) {
				--right;
				input[q] = input[right];
				input[right] = undefined;
			} else if (t === null) {
				input[q] = input[left];
				input[left] = null;
				++left;
				++q;
			} else ++q;
			hnan &= int(t === t);
		}
		if (right > left) {
			q = right;
			if (!hnan) while (q > left) {
				--q;
				t = input[q];
				if (t !== t) {
					--right;
					input[q] = input[right];
					input[right] = NaN;
				}
			}
			--right;
			if (right > left) {
				tempVec = sortVec;
				q = right;
				if (options & CASEINSENSITIVE) {
					tempVec[q] = String(input[q]).toLowerCase();
					while (q > left) --q, tempVec[q] = String(input[q]).toLowerCase();
				} else {
					tempVec[q] = String(input[q]);
					while (q > left) --q, tempVec[q] = String(input[q]);
				}
				quickSortOnArray(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		options = startIndex;
		n += options;
		while (n > options) {
			--n;
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options;
		}
	}
	return;
	var tempVec:Vector.<*>, t:*, q:uint, left:uint, right:uint, hnan:int;
}
internal function sortOnArray(input:Array, name:String, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	var left:uint = startIndex, right:uint = left + n;
	var tempVec:Vector.<*> = sortVec, i:uint = right, j:uint = n;
	while (j) {
		--j;
		t = input[j];
		t = t[name];
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left] = null;
			++left;
			++j;
		} else if (t === undefined) {
			--i,--right;
			tempVec[i] = tempVec[right];
			tempVec[right] = undefined;
			t = input[right];
			input[right] = input[j];
			input[j] = t;
		} else --i,tempVec[i] = t;
		if (j === left) break;
	}
	if (right > left) {
		j = right;
		while (j > left) {
			--j;
			t = tempVec[j];
			if (t !== t) {
				--right;
				tempVec[j] = tempVec[right];
				tempVec[right] = NaN;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		}
		--right;
		if (right > left) {
			i = right;
			if (options & CASEINSENSITIVE) {
				tempVec[i] = String(tempVec[i]).toUpperCase();
				while (i > left) --i, tempVec[i] = String(tempVec[i]).toUpperCase();
			} else {
				tempVec[i] = String(tempVec[i]);
				while (i > left) --i, tempVec[i] = String(tempVec[i]);
			}
			quickSortOnArray(tempVec, input, left, right, 0);
		}
	}
	if (options & DESCENDING) {
		i = startIndex;
		options = i + n;
		while (options > i) {
			--options;
			t = input[i];
			input[i] = input[options];
			input[options] = t;
			++i;
		}
	}
	return;
	var t:*;
}
internal function sortObject(input:Object, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	if (options & NUMERIC) {
		sortObjectNumber(input, startIndex, n);
	} else {
		q = startIndex, left = q, right = q + n, hnan = 1;
		while (q < right) {
			t = input[q];
			if (t === undefined) {
				--right;
				input[q] = input[right];
				input[right] = undefined;
			} else if (t === null) {
				input[q] = input[left];
				input[left] = null;
				++left;
				++q;
			} else ++q;
			hnan &= int(t === t);
		}
		if (right > left) {
			q = right;
			if (!hnan) while (q < left) {
				--q;
				t = input[q];
				if (t !== t) {
					--right;
					input[q] = input[right];
					input[right] = NaN;
				}
			}
			--right;
			if (right > left) {
				tempVec = sortVec;
				q = right;
				if (options & CASEINSENSITIVE) {
					tempVec[q] = String(input[q]).toLowerCase();
					while (q > left) --q, tempVec[q] = String(input[q]).toLowerCase();
				} else {
					tempVec[q] = String(input[q]);
					while (q > left) --q, tempVec[q] = String(input[q]);
				}
				quickSortOnObject(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		options = startIndex;
		n += options;
		while (n > options) {
			--n;
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options;
		}
	}
	return;
	var tempVec:Vector.<*>, t:*, q:uint, left:uint, right:uint, hnan:int;
}
internal function sortOnObject(input:Object, name:String, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	var left:uint = startIndex, right:uint = left + n;
	var tempVec:Vector.<*> = sortVec, i:uint = right, t:*, j:uint = right;
	while (j > left) {--j;
		t = input[j];
		t = t[name];
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left] = null;
			++left,++j;
		} else if (t === undefined) {
			--right,--i;
			tempVec[i] = tempVec[right];
			tempVec[right] = undefined;
			t = input[right];
			input[right] = input[j];
			input[j] = t;
		} else --i,tempVec[i] = t;
	}
	if (right > left) {
		j = right;
		while (j > left) { --j;
			t = tempVec[j];
			if (t !== t) {
				--right;
				tempVec[j] = tempVec[right];
				tempVec[right] = NaN;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		}
		--right;
		if (right > left) {
			i = right;
			if (options & CASEINSENSITIVE) {
				tempVec[i] = String(tempVec[i]).toUpperCase();
				while (i > left) --i, tempVec[i] = String(tempVec[i]).toUpperCase();
			} else {
				tempVec[i] = String(tempVec[i]);
				while (i > left) --i, tempVec[i] = String(tempVec[i]);
			}
			quickSortOnObject(tempVec, input, left, right, 0);
		}
	}
	if (options & DESCENDING) {
		i = startIndex
		options = i + n - 1;
		while (n > i) {
			t = input[i];
			input[i] = input[options];
			input[options] = t;
			++i, --options;
		}
	}
}
internal function sortObjectNumber(input:Object, startIndex:uint, n:uint):void {
	var left:uint = startIndex;
	n += startIndex;
	var dat:Vector.<Number> = numVec, s:int = 1, p:Number = input[startIndex];
	for (; startIndex < n; ++startIndex) {
		e = input[startIndex];
		dat[startIndex] = e;
		s &= int(!(e > p));
		p = e;
		if (e !== e) {
			--n;
			input[startIndex] = input[n];
			input[n] = e;
			--startIndex;
		}
	}
	--n;
	if (!s) quickSortOnNumber(dat, input, left, n, 0);
	return;
	var e:Number = 0;
}
internal function sortOnNumber(input:Object, name:String, options:uint, length:uint, startIndex:uint):void {
	if (length < 2) return;
	var right:uint = startIndex + length;
	var tempVec:Vector.<Number> = numVec, j:uint = startIndex;
	var p:Number = input[j][name], s:int = 1;
	for (; j < right; ++j) {
		e = input[j];
		t = e[name];
		tempVec[j] = t;
		s &= int(!(t > p));// ! > instead of <= to account for NaN
		p = t;
		if (t !== t) {
			--right;
			input[j] = input[right];
			input[right] = e;
			--j;
		}
	}
	--right;
	if (!s) quickSortOnNumber(tempVec, input, startIndex, right, 0);
	if (options & DESCENDING) {
		j = startIndex;
		options = j + length - 1;
		while (options > j) {
			e = input[j];
			input[j] = input[options];
			input[options] = e;
			++j;
			--options;
		}
	}
	return;
	var t:Number = 0, e:* = undefined;
}
internal function sortNumber(input:Vector.<Number>, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	var q:uint = startIndex, left:uint = q, right:uint = q + n, t:Number;
	while (q < right) {
		t = input[q];
		if (t !== t) {
			--right;
			input[q] = input[right];
			input[right] = NaN;
		} else ++q;
	}
	--right;
	if (right > left) {
		if (options === NUMERIC) {
			quickSortNumber(input, left, right, 0);
		} else {
			var tempVec:Vector.<*> = sortVec;
			q = right;
			if (options & CASEINSENSITIVE) {
				tempVec[q] = String(tempVec[q]).toUpperCase();
				while (q > left) --q, tempVec[q] = String(tempVec[q]).toUpperCase();
			} else {
				tempVec[q] = String(input[q]);
				while (q > left) --q, tempVec[q] = String(input[q]);
			}
			quickSortOnObject(tempVec, input, left, right, 0);
		}
	}
	if (options & DESCENDING) {
		options = startIndex;
		n += options;
		while (n > options) {
			--n;
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options;
		}
	}
}
internal function sortInt(input:Vector.<int>, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	var q:uint = startIndex, left:uint = q, right:uint = q + n - 1;
	if (right > left) {
		if (options & NUMERIC) {
			quickSortInt(input, left, right, n);
		} else {
			var tempVec:Vector.<*> = sortVec;
			q = right;
			if (options & CASEINSENSITIVE) {
				tempVec[q] = String(tempVec[q]).toUpperCase();
				while (q > left) --q, tempVec[q] = String(tempVec[q]).toUpperCase();
			} else {
				tempVec[q] = String(input[q]);
				while (q > left) --q, tempVec[q] = String(input[q]);
			}
			quickSortOnObject(tempVec, input, left, right, 0);
		}
	}
	var t:int;
	if (options & DESCENDING) {
		options = startIndex;
		n += options;
		while (n > options) {
			--n;
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options;
		}
	}
}
internal function sortUint(input:Vector.<uint>, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	var q:uint = startIndex, left:uint = q, right:uint = q + n - 1, t:uint = input[q];
	if (right > left) {
		if (options === NUMERIC) {
			quickSortUint(input, left, right, 0);
		} else {
			var tempVec:Vector.<*> = sortVec;
			q = right;
			if (options & CASEINSENSITIVE) {
				tempVec[q] = String(tempVec[q]).toUpperCase();
				while (q > left) --q, tempVec[q] = String(tempVec[q]).toUpperCase();
			} else {
				tempVec[q] = String(input[q]);
				while (q > left) --q, tempVec[q] = String(input[q]);
			}
			quickSortOnObject(tempVec, input, left, right, 0);
		}
	}
	if (options & DESCENDING) {
		options = startIndex;
		n += options;
		while (n > options) {
			--n;
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options;
		}
	}
}
internal function sortVector(input:*, options:uint, n:uint, startIndex:uint):void {
	if (input is Vector.<*>) sort(input, options, n, startIndex);
	else sortObject(input, options, n, startIndex);
}
internal function sortBy(input:Object, options:uint, n:uint, startIndex:uint, sortFunc:Function):void {
	if (n < 2) return;
	q = startIndex, left = q, right = q + n;
	--right;
	if (options & FORCESTRING) {
		tempVec = sortVec;
		if (options & CASEINSENSITIVE) {
			for (; q <= right; ++q) tempVec[q] = String(input[q]).toLowerCase();
		} else {
			for (; q <= right; ++q) tempVec[q] = String(input[q]);
		}
		quickSortByOnObject(tempVec, input, left, right, sortFunc);
	} else if (options & NUMERIC) {
		nVec = numVec;
		for (n = q; n <= right; ++n) e = input[n], nVec[n] = e;
		quickSortByOnNumber(nVec, input, left, right, sortFunc);
	} else {
		quickSortByObject(input, left, right, sortFunc);
	}
	if (options & DESCENDING) {
		options = startIndex;
		n = right;
		while (n > options) {
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options, --n;
		}
	}
	return;
	var tempVec:Vector.<*> = null, nVec:Vector.<Number> = null, t:* = null, q:uint, left:uint, right:uint, e:Number;
}
internal function sortByOn(input:Object, name:String, options:uint, n:uint, startIndex:uint, sortFunc:Function):void {
	if (n < 2) return;
	q = startIndex, left = q, right = q + n;
	--right;
	if (options & FORCESTRING) {
		tempVec = sortVec;
		if (options & CASEINSENSITIVE) {
			for (; q <= right; ++q) t = input[q], tempVec[q] = String(t[name]).toLowerCase();
		} else {
			for (; q <= right; ++q) t = input[q], tempVec[q] = String(t[name]);
		}
		quickSortByOnObject(tempVec, input, left, right, sortFunc);
	} else if (options & NUMERIC) {
		nVec = numVec;
		for (n = q; n <= right; ++n) t = input[n], e = t[name], nVec[n] = e;
		quickSortByOnNumber(nVec, input, left, right, sortFunc);
	} else {
		tempVec = sortVec;
		for (n = q; n <= right; ++n) t = input[n], tempVec[n] = t[name];
		quickSortByOnObject(tempVec, input, left, right, sortFunc);
	}
	if (options & DESCENDING) {
		options = startIndex;
		n = right;
		while (n > options) {
			t = input[options];
			input[options] = input[n];
			input[n] = t;
			++options, --n;
		}
	}
	return;
	var tempVec:Vector.<*> = null, nVec:Vector.<Number> = null, t:* = null, q:uint, left:uint, right:uint, e:Number;
}
//}
