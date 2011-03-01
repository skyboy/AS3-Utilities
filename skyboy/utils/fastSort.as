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
	public function fastSort(input:*, ...rest):void {
		if (!(input || ("length" in input) || input.length is int)) return;
		sortVec.length = 0;
		sortVec.length = input.length as uint;
		if (rest[0] is String) {
			if (!(rest[1] is Number)) rest[1] = 0;
			if (input is Array) {
				sortOnArray(input, rest[0], rest[1]);
			} else if (input is Vector.<*>) {
				sortOn(input, rest[0], rest[1]);
			} else {
				sortOnObject(input, rest[0], rest[1]);
			}
		} else {
			if (!(rest[0] is Number)) rest[0] = 0;
			if (input is Array) {
				sortArray(input, rest[0]);
			} else if (input is Vector.<*>) {
				sort(input, rest[0]);
			} else {
				sortObject(input, rest[0]);
			}
		}
	}
	
}
internal const NUMERIC:uint = Array.NUMERIC;
internal const DESCENDING:uint = Array.DESCENDING;
internal const CASEINSENSITIVE:uint = Array.CASEINSENSITIVE;
internal const sortVec:Vector.<*> = new Vector.<*>(0xFFFF); // reserve a large amount of space in memory for growth when sorting.
internal function quickSort(input:Vector.<*>, left:uint, right:uint, d:uint):void {
	if (right >= input.length) right = input.length - 1;
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
			if (left == right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSort(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOn(input:Vector.<*>, sInput:Vector.<*>, left:uint, right:uint, d:uint):void {
	var j:uint = right >= input.length ? right = input.length - 1 : right;
	if (left >= right) return;
	var i:uint = left;
	var size:uint = right - left;
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
			if (left == right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOn(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortArray(input:Array, left:uint, right:uint, d:uint):void {
	if (right >= input.length) right = input.length - 1;
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
			if (left == right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortArray(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnArray(input:Vector.<*>, sInput:Array, left:uint, right:uint, d:uint):void {
	var j:uint = right >= input.length ? right = input.length - 1 : right;
	if (left >= right) return;
	var i:uint = left;
	var size:uint = right - left;
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
			if (left == right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnArray(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortObject(input:*, left:uint, right:uint, d:uint):void {
	if (right >= input.length) right = input.length - 1;
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
			if (left == right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortObject(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function quickSortOnObject(input:Vector.<*>, sInput:*, left:uint, right:uint, d:uint):void {
	var j:uint = right >= input.length ? right = input.length - 1 : right;
	if (left >= right) return;
	var i:uint = left;
	var size:uint = right - left;
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
			if (left == right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnObject(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function sort(input:Vector.<*>, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var q:uint, left:uint, right:uint = n;
	var t:*;
	while (q != right) {
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
			if (t != t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (options == NUMERIC) {
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
		var i:uint = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}
internal function sortOn(input:Vector.<*>, name:String, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var tempVec:Vector.<*> = sortVec, i:uint = n, t:*, j:uint = i;
	var left:uint, right:uint = i;
	while (j--) {
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left++] = null;
			++j;
		} else if (t === undefined) {
			if (--i != --right) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[--i] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[j];
			if (t != t) {
				if (j != --right) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i-- > left) tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i-- > left) tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOn(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = 0;
		while (n != i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}
internal function sortArray(input:Array, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var q:uint, left:uint, right:uint = n;
	var t:*;
	while (q != right) {
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
			if (t != t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (options == NUMERIC) {
					quickSortArray(input, left, right, 0);
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
					quickSortOnArray(tempVec, input, left, right, 0);
				}
			}
		}
	}
	if (options & DESCENDING) {
		var i:uint = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}
internal function sortOnArray(input:Array, name:String, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var tempVec:Vector.<*> = sortVec, i:uint = n, t:*, j:uint = i;
	var left:uint, right:uint = i;
	while (j--) {
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left++] = null;
			++j;
		} else if (t === undefined) {
			if (--i != --right) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[--i] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[j];
			if (t != t) {
				if (j != --right) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i-- > left) tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i-- > left) tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOnArray(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}
internal function sortObject(input:*, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var q:uint, left:uint, right:uint = n;
	var t:*;
	while (q != right) {
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
			if (t != t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (options == NUMERIC) {
					quickSortObject(input, left, right, 0);
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
					quickSortOnObject(tempVec, input, left, right, 0);
				}
			}
		}
	}
	if (options & DESCENDING) {
		var i:uint = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}
internal function sortOnObject(input:*, name:String, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var tempVec:Vector.<*> = sortVec, i:uint = n, t:*, j:uint = i;
	var left:uint, right:uint = i;
	while (j--) {
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left++] = null;
			++j;
		} else if (t === undefined) {
			if (--i != --right) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[--i] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[j];
			if (t != t) {
				if (j != --right) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i-- > left) tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i-- > left) tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOnObject(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}
























