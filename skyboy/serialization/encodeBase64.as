package skyboy.serialization {
	/**
	 * encodeBase64 by skyboy. June 29th 2011.
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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import skyboy.serialization.Base64Helper;
	/**
	 * ...
	 * @author skyboy
	 */
	public function encodeBase64(input:*, options:uint = 0, breakAt:uint = 64):* {
		var ops:uint = options >> 3 & 15;
		if (!ops || (ops > 7)) {
			EncMed = Base64Helper.Base64Std;
		} else if (ops == 1) {
			EncMed = Base64Helper.Base64FileName;
		} else if (ops == 2) {
			EncMed = Base64Helper.Base64URL;
		} else if (ops == 3) {
			EncMed = Base64Helper.Base64XMLTok;
		} else if (ops == 4) {
			EncMed = Base64Helper.Base64XMLIdn;
		} else if (ops == 5) {
			EncMed = Base64Helper.Base64ProgID1;
		} else if (ops == 6) {
			EncMed = Base64Helper.Base64ProgID2;
		} else if (ops == 7) {
			EncMed = Base64Helper.Base64RegExp;
		}
		var pad:uint = EncMed[64];
		if (input is ByteArray) encodeByteArray(input);
		else if (input is String) {
			tempBA = new ByteArray();
			tempBA.writeUTFBytes(input);
			encodeByteArray(tempBA);
		} else if (input is Number) {
			tempBA = new ByteArray();
			tempBA.writeDouble(input);
			encodeByteArray(tempBA);
		} else if (input is Vector.<uint>) {
			encodeUVector(input);
		} else if (input is Vector.<int>) {
			encodeIVector(input);
		} else if (input is Bitmap) {
			tempBD = input.bitmapData;
			tempBA = tempBD.getPixels(input.rect);
			encodeByteArray(tempBA);
		} else if (input is BitmapData) {
			tempBA = input.getPixels(input.rect);
			encodeByteArray(tempBA);
		} else throw new Error("Unexpected " + Base64Helper.PString(input) + ".");
		if ((options >> 11) & 1) {
			tempBA = median;
			i = tempBA.length;
			if (tempBA[--i] == pad) --tempBA.length;
			if (tempBA[--i] == pad) --tempBA.length;
			i = 0;
			const SUMI:uint = 0xB704CE;
			const SUMP:uint = 0x1864CFB;
			const SUMA:uint = 0x1000000;
			const AN:uint = 63;
			var i2:int = 0;
			tempBA = new ByteArray();
			end = median.length;
			tempBA.length = end + (end / 18 | 0);
			end -= end % 72;
			while (i != end) {
				tempBA.writeBytes(median, i, 72);
				for (var sum:uint = SUMI, len:int = 72, c:int = 8; len--; c = 8) {
					sum ^= tempBA[i2++] << 16;
					while (c--) {
						sum <<= 1;
						if (sum & SUMA) sum ^= SUMP;
					}
				}
				//tempBA[i2] = EncMed[int(Math.random() * 64)];
				tempBA[i2] = EncMed[sum >>> 12 & AN];
				tempBA[++i2] = EncMed[sum >>> 6 & AN];
				tempBA[++i2] = EncMed[sum & AN];
				tempBA.position = ++i2;
				i += 72;
			}
			len = median.length - end;
			if (len) {
				tempBA.writeBytes(median, end, len);
				sum = SUMI;
				for (c = 8; len--; c = 8) {
					sum ^= tempBA[i2++] << 16;
					while (c--) {
						sum <<= 1;
						if (sum & SUMA) sum ^= SUMP;
					}
				}
				//tempBA[i2] = EncMed[int(Math.random() * 64)];
				tempBA[i2] = EncMed[sum >>> 12 & AN];
				tempBA[++i2] = EncMed[sum >>> 6 & AN];
				tempBA[++i2] = EncMed[sum & AN];
			}
			if (!((options >> 2) & 1)) if (i2 % 3) {
				tempBA[++i2] = pad;
				if (i2 % 3) tempBA[++i2] = pad;
			}
			median.writeBytes(tempBA, 0, i2 + 1);
			median.position = 0;
		} else if ((options >> 2) & 1) {
			tempBA = median;
			i = tempBA.length;
			if (tempBA[--i] == pad) --tempBA.length;
			if (tempBA[--i] == pad) --tempBA.length;
		}
		ops = options >> 7 & 3;
		if (ops != 2) {
			if (ops == 0 || !breakAt) {
				breakAt = 64;
			} else if (ops == 3) {
				breakAt = 76;
			}
			i = 0;
			len = median.length % breakAt;
			var end:uint = median.length - len;
			tempBA = new ByteArray();
			while (i != end) {
				tempBA.writeBytes(median, i, breakAt);
				tempBA.writeByte(10);
				i += breakAt;
			}
			if (len) tempBA.writeBytes(median, end, len);
			median.writeBytes(tempBA, 0, tempBA.length);
			median.position = 0;
			//options = options >>> 2 << 2;
		}
		ops = options & 3;
		if (!ops) {
			var rtnStr:String = median.readUTFBytes(median.length);
			median.length = 0;
			return rtnStr;
		} else if (ops == 1) {
			var tempBA:ByteArray = new ByteArray();
			tempBA.writeBytes(median, 0, median.length);
			median.length = 0;
			return tempBA;
		} else if (ops == 2) {
			var tempVec:Vector.<int> = new Vector.<int>(median.length);
			tempBA = median;
			var i:uint = tempBA.length;
			while (i % 4) { tempVec[--i] = tempBA[i]; }
			while (i) {
				tempVec[--i] = tempBA[i];
				tempVec[--i] = tempBA[i];
				tempVec[--i] = tempBA[i];
				tempVec[--i] = tempBA[i];
			}
			tempBA.length = 0;
			return tempVec;
		} else {
			var temp:Array = new Array(median.length);
			tempBA = median;
			i = tempBA.length;
			while (i % 4) { temp[--i] = tempBA[i]; }
			while (i) {
				temp[--i] = tempBA[i];
				temp[--i] = tempBA[i];
				temp[--i] = tempBA[i];
				temp[--i] = tempBA[i];
			}
			tempBA.length = 0;
			return temp;
		}
		var tempBD:BitmapData; // at the bottom to ensure last varaible after compiling
	}
}
import flash.utils.ByteArray;
internal const median:ByteArray = new ByteArray();
internal var EncMed:Vector.<uint>;
internal function encodeByteArray(a:ByteArray):void {
	var o:ByteArray = median;
	o.position = 0;
	if (!a.length) {
		throw new Error("Empty data.");
		return;
	}
	var i:int = -1, j:int = i, e:int = a.length, b:int = e % 3;
	var enc:Vector.<uint> = EncMed;
	var pad:uint = enc[64];
	o.length = (e + 2 - ((e + 2) % 3)) / 3 << 2;
	if (b) {
		if (b - 1) { // 2
			b = o.length;
			o[--b] = pad;
			o[--b] = enc[(a[--e] & 15) << 2];
			o[--b] = enc[(a[e] >> 4) | ((a[--e] & 3) << 4)];
			o[--b] = enc[a[e] >> 2];
		} else { // 1
			b = o.length;
			o[--b] = pad;
			o[--b] = pad;
			o[--b] = enc[(a[--e] & 3) << 4];
			o[--b] = enc[a[e] >> 2];
		}
		if (!e) return;
	}
	while (e) {
		o[++j] = enc[a[++i] >> 2];
		o[++j] = enc[((a[i] & 3) << 4) | (a[++i] >> 4)];
		o[++j] = enc[((a[i] & 15) << 2) | (a[++i] >> 6)];
		o[++j] = enc[a[i] & 63];
		e -= 3;
	}
}
internal function encodeUVector(a:Vector.<uint>):void {
	var o:ByteArray = median;
	o.position = 0;
	if (!a.length) {
		throw new Error("Empty Vector<uint>.");
		return;
	}
	var i:int = -1, j:int = i, e:int = a.length, b:int = e % 3;
	var enc:Vector.<uint> = EncMed;
	var pad:uint = enc[64];
	e <<= 2;
	o.length = (e + 2 - ((e + 2) % 3)) / 3 << 2;
	e >>>= 2;
	if (b) {
		if (b - 1) { // 2
			b = o.length;
			o[--b] = pad;
			o[--b] = pad;
			o[--b] = enc[(a[--e] << 2) & 63];
			o[--b] = enc[(a[e] >> 4) & 63];
			o[--b] = enc[(a[e] >> 10) & 63];
			o[--b] = enc[(a[e] >> 16) & 63];
			o[--b] = enc[(a[e] >> 22) & 63];
			o[--b] = enc[((a[e] << 4) | (a[--e] >>> 28)) & 63];
			o[--b] = enc[(a[e] >> 2) & 63];
			o[--b] = enc[(a[e] >> 8) & 63];
			o[--b] = enc[(a[e] >> 14) & 63];
			o[--b] = enc[(a[e] >> 20) & 63];
			o[--b] = enc[a[e] >>> 26];
		} else { // 1
			b = o.length;
			o[--b] = pad;
			o[--b] = enc[(a[--e] << 4) & 63];
			o[--b] = enc[(a[e] >> 2) & 63];
			o[--b] = enc[(a[e] >> 8) & 63];
			o[--b] = enc[(a[e] >> 14) & 63];
			o[--b] = enc[(a[e] >> 20) & 63];
			o[--b] = enc[a[e] >>> 26];
		}
		if (!e) return;
	}
	while (e) {
		o[++j] = enc[(a[++i] >>> 26) & 63];
		o[++j] = enc[(a[i] >> 20) & 63];
		o[++j] = enc[(a[i] >> 14) & 63];
		o[++j] = enc[(a[i] >> 8) & 63];
		o[++j] = enc[(a[i] >> 2) & 63];
		o[++j] = enc[((a[i] << 4) | (a[++i] >>> 28)) & 63];
		o[++j] = enc[(a[i] >> 22) & 63];
		o[++j] = enc[(a[i] >> 16) & 63];
		o[++j] = enc[(a[i] >> 10) & 63];
		o[++j] = enc[(a[i] >> 4) & 63];
		o[++j] = enc[((a[i] << 2) | (a[++i] >>> 30)) & 63];
		o[++j] = enc[(a[i] >> 24) & 63];
		o[++j] = enc[(a[i] >> 18) & 63];
		o[++j] = enc[(a[i] >> 12) & 63];
		o[++j] = enc[(a[i] >> 6) & 63];
		o[++j] = enc[a[i] & 63];
		e -= 3;
	}
}
internal function encodeIVector(a:Vector.<int>):void {
	var o:ByteArray = median;
	o.position = 0;
	if (!a.length) {
		throw new Error("Empty Vector<int>.");
		return;
	}
	var i:int = -1, j:int = i, e:int = a.length, b:int = e % 3;
	var enc:Vector.<uint> = EncMed;
	var pad:uint = enc[64];
	e <<= 2;
	o.length = (e + 2 - ((e + 2) % 3)) / 3 << 2;
	e >>>= 2;
	if (b) {
		if (b - 1) { // 2
			b = o.length;
			o[--b] = pad;
			o[--b] = pad;
			o[--b] = enc[(a[--e] << 2) & 63];
			o[--b] = enc[(a[e] >> 4) & 63];
			o[--b] = enc[(a[e] >> 10) & 63];
			o[--b] = enc[(a[e] >> 16) & 63];
			o[--b] = enc[(a[e] >> 22) & 63];
			o[--b] = enc[((a[e] << 4) | (a[--e] >>> 28)) & 63];
			o[--b] = enc[(a[e] >> 2) & 63];
			o[--b] = enc[(a[e] >> 8) & 63];
			o[--b] = enc[(a[e] >> 14) & 63];
			o[--b] = enc[(a[e] >> 20) & 63];
			o[--b] = enc[a[e] >>> 26];
		} else { // 1
			b = o.length;
			o[--b] = pad;
			o[--b] = enc[(a[--e] << 4) & 63];
			o[--b] = enc[(a[e] >> 2) & 63];
			o[--b] = enc[(a[e] >> 8) & 63];
			o[--b] = enc[(a[e] >> 14) & 63];
			o[--b] = enc[(a[e] >> 20) & 63];
			o[--b] = enc[a[e] >>> 26];
		}
		if (!e) return;
	}
	while (e) {
		o[++j] = enc[(a[++i] >>> 26) & 63];
		o[++j] = enc[(a[i] >> 20) & 63];
		o[++j] = enc[(a[i] >> 14) & 63];
		o[++j] = enc[(a[i] >> 8) & 63];
		o[++j] = enc[(a[i] >> 2) & 63];
		o[++j] = enc[((a[i] << 4) | (a[++i] >>> 28)) & 63];
		o[++j] = enc[(a[i] >> 22) & 63];
		o[++j] = enc[(a[i] >> 16) & 63];
		o[++j] = enc[(a[i] >> 10) & 63];
		o[++j] = enc[(a[i] >> 4) & 63];
		o[++j] = enc[((a[i] << 2) | (a[++i] >>> 30)) & 63];
		o[++j] = enc[(a[i] >> 24) & 63];
		o[++j] = enc[(a[i] >> 18) & 63];
		o[++j] = enc[(a[i] >> 12) & 63];
		o[++j] = enc[(a[i] >> 6) & 63];
		o[++j] = enc[a[i] & 63];
		e -= 3;
	}
}
