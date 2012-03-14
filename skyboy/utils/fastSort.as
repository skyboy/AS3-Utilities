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
	 *
	 * @param	*: input	The object to be sorted. Either an Array, Vector, or any Object (or subclass of) that has a length property and numeric indicies
	 * @param	*: rest0	Either options (pass in the same you would for Array's sort method) or a String to trigger sortOn functionality (def: stringSort)
	 * @param	*: rest1	Either options if rest0 is a String or length (def: stringSort or input.length)
	 * @param 	*: rest2	Either length if rest0 is String or startIndex for sorting (def: input.length or 0)
	 * @param 	*: rest3	Either startIndex if rest0 is String or undefined (def: 0 or undefined)
	 */
	public function fastSort(input:*, ...rest):void {
	//public function fastSort(input:*, rest0:* = 0, rest1:* = undefined, rest2:* = undefined, rest3:* = undefined):void {
		if (!input) throw new ArgumentError("Can not sort null");
		var sortON:Boolean = rest[0] is String;
		var optI:uint = int(sortON);
		var lenI:uint = 1 + optI;
		var startI:uint = 2 + optI;
		if (("length" in input) && (input.length is int)) {// grab length from the input
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
		if (sortON) {
			if (optI & NUMERIC) {
				numVec.length = length + rest[startI];
				sortOnNumber(input, rest[0], optI, length, rest[startI]);
			} else {
				sortVec.length = length + rest[startI];
				if (input is Array) {
					sortOnArray(input, rest[0], optI, length, rest[startI]);
				} else if (input is Vector.<*>) {// numeric vectors not included
					sortOn(input, rest[0], optI, length, rest[startI]);
				} else {
					sortOnObject(input, rest[0], optI, length, rest[startI]);
				}
			}
		} else {
			if (!(optI & NUMERIC)) sortVec.length = length + rest[startI];
			f = LookupTable[input.constructor];
			if (Boolean(f)) f(input, optI, length, rest[startI]);
			else sortObject(input, optI, length, rest[startI]);
		}
		sortVec.length = 0;// clear the vectors (O(1) operation)
		tempVec.length = 0;
		numVec.length = 0;
		return;
		var length:uint, f:Function;// avoid compiler setting default values for these
	}
	
}
import flash.system.System;
import flash.utils.Dictionary;
//{
internal const NUMERIC:uint 			= Array.NUMERIC;
internal const DESCENDING:uint 			= Array.DESCENDING;
internal const CASEINSENSITIVE:uint 	= Array.CASEINSENSITIVE;
internal const sortVec:Vector.<*> 		= new Vector.<*>(0xFFFF);
internal const tempVec:Vector.<*> 		= new Vector.<*>(0xFFFF);
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
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOn(input:Vector.<*>, sInput:Vector.<*>, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortArray(input:Array, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right, i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnArray(input:Vector.<*>, sInput:Array, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortObject(input:Object, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnObject(input:Vector.<*>, sInput:Object, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnNumber(input:Vector.<Number>, sInput:Object, left:int, right:int, d:int):void {
	if (left >= right) return;
	var j:int = right;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:Number = input[(right + left) >>> 1];
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
							q = left - 1;
							e = input[q];
							input[left] = e;
							sInput[left] = sInput[q];
							left = q;
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
			if (input[right] > pivotPoint) do {
				--right;
			} while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do {
				++left;
			} while (input[left] < pivotPoint);
			if (left < right) {
				e = input[left];
				input[left] = input[right];
				input[right] = e;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left === right) {
				e = input[left];
				right -= int(e >= pivotPoint);
				left += int(e <= pivotPoint);
			}
			if (i < right) {
				quickSortOnNumber(input, sInput, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
	return;
	var e:Number, t:*, q:int;
}
internal function quickSortInt(input:Vector.<int>, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:int = input[(right + left) >>> 1], t:int;
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
				quickSortInt(input, i, right, d + 1);
			}
		}
		left |= int(!left) & int(!right);
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortUint(input:Vector.<uint>, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:uint = input[(right + left) >>> 1], t:uint;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortNumber(input:Vector.<Number>, left:uint, right:uint, d:int):void {
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:Number = input[(right + left) >>> 1], t:Number;
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
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function sort(input:Vector.<*>, options:uint, length:uint, startIndex:uint):void {
	var n:uint = length;
	if (n < 2) return;
	var q:uint = startIndex, left:uint = q, right:uint = q + n;
	var t:*;
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
		q = left;
		while (q < right) {
			t = input[q];
			if (t !== t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if ((--right,right)) {
			if (uint(right - 1) > left) {
				if (options === NUMERIC) {
					quickSort(input, left, right, 0);
				} else {
					var tempVec:Vector.<*> = sortVec;
					q = right;
					if (!(options & NUMERIC)) if (options & CASEINSENSITIVE) {
						tempVec[q] = String(input[q]).toLowerCase();
						while (q-- > left) tempVec[q] = String(input[q]).toLowerCase();
					} else {
						tempVec[q] = String(input[q]);
						while (q-- > left) tempVec[q] = String(input[q]);
					}
					quickSortOn(tempVec, input, left, right, 0);
				}
			}
		}
	}
	if (options & DESCENDING) {
		var i:uint = startIndex;
		n += i;
		while (n > i) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
	}
}
internal function sortOn(input:Vector.<*>, name:String, options:uint, length:int, startIndex:int):void {
	var n:int = length;
	if (n < 2) return;
	var left:int = startIndex, right:int = left + n;
	var tempVec:Vector.<*> = sortVec, i:int = right, j:int = n, t:*;
	while (j) {--j;
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left] = null;
			++left;
			++j;
		} else if (t === undefined) {
			if ((--i,i) !== (--right,right)) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[(--i,i)] = t;
		if (j === left) break;
	}
	if (right > left) {
		j = right;
		while ((--j,j) > left) {
			t = tempVec[j];
			if (t !== t) {
				if (j !== (--right,right)) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if ((--right,right)) {
			if (right - 1 > left) {
				if (!(options & NUMERIC)) {
					i = left;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i < right) ++i, tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i < right) ++i, tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOn(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = startIndex, n += i;
		if (n & 1) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
		n >>>= 1;
		while (n > i) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
	}
}
internal function sortArray(input:Array, options:uint, length:uint, startIndex:uint):void {
	var n:uint = length;
	if (n < 2) return;
	var q:uint = startIndex, left:uint = q, right:uint = q + n;
	var t:*;
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
		q = left;
		while (q < right) {
			t = input[q];
			if (t !== t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if ((--right,right)) {
			if (uint(right - 1) > left) {
				if (options === NUMERIC) {
					quickSortArray(input, left, right, 0);
				} else {
					var tempVec:Vector.<*> = sortVec;
					q = right;
					if (!(options & NUMERIC)) if (options & CASEINSENSITIVE) {
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
	}
	if (options & DESCENDING) {
		var i:uint = startIndex;
		n += i;
		while (n > i) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
	}
}
internal function sortOnArray(input:Array, name:String, options:uint, length:uint, startIndex:uint):void {
	var n:uint = length;
	if (n < 2) return;
	var left:uint = startIndex, right:uint = left + n;
	var tempVec:Vector.<*> = sortVec, i:uint = right, t:*, j:uint = n;
	while (j) {--j;
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left] = null;
			++left;
			++j;
		} else if (t === undefined) {
			if ((--i,i) !== (--right,right)) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[(--i,i)] = t;
		if (j === left) break;
	}
	if (right > left) {
		j = right;
		while ((--j,j) > left) {
			t = tempVec[j];
			if (t !== t) {
				if (j !== (--right,right)) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if ((--right,right)) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i > left) --i, tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i > left) --i, tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOnArray(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = startIndex, n += i;
		while (n > i) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
	}
}
internal function sortObject(input:Object, options:uint, length:uint, startIndex:uint):void {
	var n:int = length;
	if (n < 2) return;
	var q:int = startIndex, left:uint = q, right:uint = q + n;
	var t:*;
	while (uint(q) !== right) {
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
		q = left;
		while (uint(q) < right) {
			t = input[q];
			if (t !== t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if ((--right,right)) {
			if (uint(right - 1) > left) {
				if (options & NUMERIC) {
					quickSortObject(input, left, right, 0);
				} else {
					var tempVec:Vector.<*> = sortVec;
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
	}
	if (options & DESCENDING) {
		var i:int = 0;
		while (n > i) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
	}
}
internal function sortOnObject(input:Object, name:String, options:uint, n:uint, startIndex:uint):void {
	if (n < 2) return;
	var left:uint = startIndex, right:uint = left + n;
	var tempVec:Vector.<*> = sortVec, i:uint = right, t:*, j:uint = right;
	while (j > left) {--j;
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left] = null;
			++left;
			++j;
		} else if (t === undefined) {
			if ((--i,i) !== (--right,right)) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[(--i,i)] = t;
		if (j === left) break;
	}
	if (right > left) {
		j = right;
		while (j > left) { --j;
			t = tempVec[j];
			if (t !== t) {
				if (j !== (--right,right)) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		--right;
		if (right) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i > left) --i, tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i > left) --i, tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOnObject(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = startIndex, n += i;
		--n;
		while (n > i) {
			t = input[i];
			input[i] = input[n];
			input[n] = t;
			++i, --n;
		}
	}
}
internal function sortOnNumber(input:Object, name:String, options:uint, length:uint, startIndex:uint):void {
	if (length < 2) return;
	var left:uint = startIndex, right:uint = left + length;
	var tempVec:Vector.<Number> = numVec, i:uint = right, j:uint = right;
	var p:Number = input[j - 1][name], s:int = 1;
	while (j > left) { --j;
		e = input[j];
		t = e[name];
		s &= int(!(t > p)); // ! > instead of <= to account for NaN
		if (t !== t) {
			--right;
			tempVec[j] = tempVec[right];
			input[j] = input[right];
			input[right] = e;
		}
	}
	--right;
	if (int(!s) & int(right > left)) {
		quickSortOnNumber(tempVec, input, left, right, 0);
	}
	if (options & DESCENDING) {
		i = startIndex;
		options = i + length - 1;
		while (options > i) {
			e = input[i];
			input[i] = input[options];
			input[options] = e;
			++i;
			--options;
		}
	}
	return;
	var t:Number, e:*;
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
			if (!(options & NUMERIC)) {
				tempVec[q] = String(input[q]);
				while (q-- > left) tempVec[q] = String(input[q]);
			}
			quickSortOnObject(tempVec, input, left, right, 0);
		}
	}
	if (options & DESCENDING) {
		var i:uint = startIndex;
		n += i;
		while (n > i) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
	}
}
internal function sortInt(input:Vector.<int>, options:uint, length:uint, startIndex:uint):void {
	if (length < 2) return;
	var q:uint = startIndex, left:uint = q, right:uint = q + length - 1;
	if (right > left) {
		if (options & NUMERIC) {
			quickSortInt(input, left, right, length);
		} else {
			var tempVec:Vector.<*> = sortVec;
			q = right;
			tempVec[q] = String(input[q]);
			while (q < right) ++q, tempVec[q] = String(input[q]);
			quickSortOnObject(tempVec, input, left, right, 0);
		}
	}
	var t:int;
	if (options & DESCENDING) {
		options = startIndex;
		length += options;
		while (length > options) {
			t = input[options];
			input[options] = input[(--length,length)];
			input[length] = t;
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
			if (!(options & NUMERIC)) {
				tempVec[q] = String(input[q]);
				while (q-- > left) tempVec[q] = String(input[q]);
			}
			quickSortOnObject(tempVec, input, left, right, 0);
		}
	}
	if (options & DESCENDING) {
		var i:uint = startIndex;
		n += i;
		while (n > i) {
			t = input[i];
			input[i] = input[(--n,n)];
			input[n] = t;
			++i;
		}
	}
}
internal function sortVector(input:*, options:uint, length:uint, startIndex:uint):void {
	if (input is Vector.<*>) sort(input, options, length, startIndex);
	else sortObject(input, options, length, startIndex);
}






//}
