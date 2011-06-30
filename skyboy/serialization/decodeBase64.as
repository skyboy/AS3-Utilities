package skyboy.serialization {
	/**
	 * decodeBase64 by skyboy. June 29th 2011.
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
	import flash.utils.ByteArray;
	
	public function decodeBase64(input:*, options:uint = 0):* {
		var decode:ByteArray, out:ByteArray = median;
		var ops:uint = options >> 3 & 15;
		const invalid:uint = uint(-1), pad:uint = 64, space:uint = 128;
		var temp:Vector.<uint>;
		if (!ops || (ops > 7)) {
			EncMed = Base64Helper.Base64Stdr;
			temp = Base64Helper.Base64Std;
		} else if (ops == 1) {
			EncMed = Base64Helper.Base64FileNamer;
			temp = Base64Helper.Base64FileName;
		} else if (ops == 2) {
			EncMed = Base64Helper.Base64URLr;
			temp = Base64Helper.Base64URL;
		} else if (ops == 3) {
			EncMed = Base64Helper.Base64XMLTokr;
			temp = Base64Helper.Base64XMLTok;
		} else if (ops == 4) {
			EncMed = Base64Helper.Base64XMLIdnr;
			temp = Base64Helper.Base64XMLIdn;
		} else if (ops == 5) {
			EncMed = Base64Helper.Base64ProgID1r;
			temp = Base64Helper.Base64ProgID1;
		} else if (ops == 6) {
			EncMed = Base64Helper.Base64ProgID2r;
			temp = Base64Helper.Base64ProgID2;
		} else if (ops == 7) {
			EncMed = Base64Helper.Base64RegExpr;
			temp = Base64Helper.Base64RegExp;
		}
		if (input is ByteArray) {
			decode = new ByteArray();
			decode.writeBytes(input, 0, input.length);
		} else if (input is String) {
			decode = new ByteArray();
			decode.writeUTFBytes(input);
		} else if (input is Number) {
			decode = new ByteArray();
			decode.writeDouble(input);
		} else if (input is Vector.<uint> || input is Vector.<int>) {
			decode = new ByteArray();
			var i:int = input.length, b:int, d:int = i * 4;
			decode.length = d;
			while (i % 4) decode[--d] = input[--i];
			while (i) {
				decode[--d] = input[--i];
				decode[--d] = input[--i];
				decode[--d] = input[--i];
				decode[--d] = input[--i];
			}
		} else if (input is Array) {
			decode = new ByteArray();
			i = input.length, d = i * 4;
			decode.length = d;
			while (i % 4) decode[--d] = uint(input[--i]);
			while (i) {
				decode[--d] = uint(input[--i]);
				decode[--d] = uint(input[--i]);
				decode[--d] = uint(input[--i]);
				decode[--d] = uint(input[--i]);
			}
		} else throw new Error("Unexpected " + Base64Helper.PString(input) + ".");
		var c:int;
		i = decode.length;
		d = -1;
		b = 0;
		if (!((options >>> 10) & 1)) {
			if ((options >>> 9) & 1) {
				while (i--) {
					if (EncMed[decode[++d]] <= 64) {
						decode[b++] = decode[d];
					}
				}
			} else {
				while (i--) {
					c = EncMed[decode[++d]];
					if (c <= 64) {
						decode[b++] = decode[d];
					} else if (c == invalid) throw new Error("Unexpected character " + decode[d] + " @" + d);
				}
			}
			decode.length = b;
		} else {
			while (i--) {
				if (EncMed[decode[++d]] > 64) {
					throw new Error("Unexpected character " + decode[d] + " @" + d);
				}
			}
		}
		if (options >> 11 & 1) {
			i = decode.length;
			while (EncMed[decode[--i]] == 64) void;
			decode.length = ++i;
			i = 0;
			const SUMI:uint = 0xB704CE;
			const SUMP:uint = 0x1864CFB;
			const SUMA:uint = 0x1000000;
			const AN:uint = 63;
			var end:uint = decode.length - (decode.length % 75);
			var i2:int = 0;
			var i3:int = 0;
			var tempBA:ByteArray = new ByteArray();
			tempBA.length = decode.length;
			while (i2 != end) {
				tempBA.writeBytes(decode, i2, 72);
				for (var sum:uint = SUMI, len:int = 36; len--; ) {
					sum ^= decode[i2++] << 16;
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum ^= decode[i2++] << 16;
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
				}
				var tempi:int = int(decode[i2] == temp[sum >>> 12 & AN]);
				tempi += int(decode[++i2] == temp[sum >>> 6 & AN]) + int(decode[++i2] == temp[sum & AN]);
				if (tempi != 3) throw new Error("(CRC) Invalid Base64 data.");
				i += 72;
				++i2;
			}
			len = (decode.length % 75) - 3;
			if (len > 0) {
				tempBA.writeBytes(decode, i2, len);
				i += len - int(((len - 2) % 4) == 0); // an artifact of encoding means every 3 digits will jump in length by 1 more than normally expected
						// ((len - 2) % 4) == 0 checks for this jump, and then corrects it by subtracting 1. the new jump ((len - 2) % 4) == 1 is handled without error
				sum = SUMI;
				while (len--) {
					sum ^= decode[i2++] << 16;
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
					sum <<= 1; sum ^= SUMP * int((sum & SUMA) != 0);
				}
				tempi = int(decode[i2] == temp[sum >>> 12 & AN]);
				tempi += int(decode[++i2] == temp[sum >>> 6 & AN]) + int(decode[++i2] == temp[sum & AN]);
				if (tempi != 3) throw new Error("(CRC) Invalid Base64 data.");
			} else if (len + 3) throw new Error("(CRC) Invalid Base64 data.");
			decode.clear();
			decode.writeBytes(tempBA, 0, ++i);
		}
		i = decode.length
		c = i % 4;
		i >>>= 2;
		var o:int = -1;
		d = -1;
		while (i--) {
			b = EncMed[decode[++d]];
			out[++o] = b << 2;
			b = EncMed[decode[++d]];
			out[o] |= b >> 4;
			out[++o] = b << 4;
			b = EncMed[decode[++d]];
			out[o] |= b >> 2;
			out[++o] = b << 6;
			b = EncMed[decode[++d]];
			out[o] |= b;
		}
		switch (c) {
			case 1:
			b = EncMed[decode[++d]];
			out[++o] = b << 2;
			break;
			case 2:
			b = EncMed[decode[++d]];
			out[++o] = b << 2;
			b = EncMed[decode[++d]];
			out[o] |= b >> 4;
			out[++o] = b << 4;
			break;
			case 3:
			b = EncMed[decode[++d]];
			out[++o] = b << 2;
			b = EncMed[decode[++d]];
			out[o] |= b >> 4;
			out[++o] = b << 4;
			b = EncMed[decode[++d]];
			out[o] |= b >> 2;
			out[++o] = b << 6;
			break;
			case 0:
			default:
			break;
		}
		ops = options & 3;
		if (!ops) {
			var rtnStr:String = out.readUTFBytes(o);
			out.length = 0;
			return rtnStr;
		} else if (ops == 1) {
			tempBA = new ByteArray();
			tempBA.writeBytes(out, 0, o);
			out.length = 0;
			return tempBA;
		} else if (ops == 2) {
			var tempVec:Vector.<int> = new Vector.<int>(o);
			decode = out;
			i = o;
			while (i % 4) { tempVec[--i] = decode[i]; }
			while (i) {
				tempVec[--i] = decode[i];
				tempVec[--i] = decode[i];
				tempVec[--i] = decode[i];
				tempVec[--i] = decode[i];
			}
			decode.length = 0;
			return tempVec;
		} else {
			var tempA:Array = new Array(o);
			decode = out;
			i = o;
			while (i % 4) { tempA[--i] = decode[i]; }
			while (i) {
				tempA[--i] = decode[i];
				tempA[--i] = decode[i];
				tempA[--i] = decode[i];
				tempA[--i] = decode[i];
			}
			tempBA.length = 0;
			return tempA;
		}
	}
}
import flash.utils.ByteArray;
internal const median:ByteArray = new ByteArray();
internal var EncMed:Vector.<uint>;
