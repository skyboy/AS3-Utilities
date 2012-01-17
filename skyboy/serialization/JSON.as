package skyboy.serialization {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Dictionary;
	/**
	 * JSON by skyboy. June 28th 2010.
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
	final public class JSON {
		private static const instance:JSON = new JSON();
		public function JSON() {
			if (instance) throw new Error("This class has no instance methods.")
			strArr.length = 0xFFFF; strArr.endian = Endian.LITTLE_ENDIAN;
			strArrE.length = 0xFFFF; strArrE.endian = Endian.BIG_ENDIAN;
			var i:int = 0x10000;
			while (i--) {
				encRL[i] = (0x30303030 | ((i & 0xF000) << 12) | ((i & 0xF00) << 8) | ((i & 0xF0) << 4) | (i & 0xF)) +
				(((int((i & 0xF000) > 0x9000) * 0x7000) << 12) |
				((int((i & 0xF00) > 0x900) * 0x700) << 8) |
				((int((i & 0xF0) > 0x90) * 0x70) << 4) |
				((int((i & 0xF) > 0x9) * 0x7)));
			}
			i = 0x100;
			while (i--) {
				encD[i] = i;
			}
			encD[0x62] = 8;
			encD[0x66] = 12;
			encD[0x6E] = 10;
			encD[0x72] = 13;
			encD[0x74] = 9;
		}
		private const preArrs:Vector.<Array> = new Vector.<Array>();
		private const preObjs:Vector.<Object> = new Vector.<Object>();
		private const strArr:ByteArray = new ByteArray();
		private const strArrE:ByteArray = new ByteArray();
		private const encRL:Vector.<int> = new Vector.<int>(0x10000, true);
		private const encD:Vector.<int> = new Vector.<int>(0x100, true);
		private var i:int;
		
		public static const errorID:int = 0x4A534F4E;
		
		private function decode(data:String):* {
			if (!data) return null;
			var e:int = data.length, temp:int;
			var preObjs:Vector.<Object> = preObjs, preArrs:Vector.<Array> = preArrs;
			var o2:int = preObjs.length, objs:int = -o2;
			while (~(temp = data.indexOf("}", temp + 1))) ++objs;
			if (objs > 0) {
				objs += o2;
				preObjs.length = objs;
				while (o2 < objs) preObjs[o2++] = new Object;
			}
			o2 = preArrs.length
			objs = -o2;
			temp = 0;
			while (~(temp = data.indexOf("]", temp + 1))) ++objs;
			if (objs > 0) {
				objs += o2;
				preArrs.length = objs;
				temp = e / min(e, objs * 3);
				while (o2 < objs) preArrs[o2++] = new Array(temp);
			}
			strArr.length = e;
			var a:int,c:int = data.charCodeAt(a);
			while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13))) {
				c = data.charCodeAt(++a);
			}
			var rtn:*;
			i = a;
			if (c == 0x7B) {
				rtn = handleObject(data, e);
			} else if (c == 0x5B) {
				rtn = handleArray(data, e);
			} else if ((int(c == 0x22) | int(c == 0x27))) {
				rtn = handleString(data, e);
			} else if ((int(c == 0x2D) | int(c == 0x2E) | (int(c > 0x2F) & int(c < 0x3A)) | int(c == 0x2B))) {
				rtn = handleNumber2(data, e);
			} else if (isLit(c)) {
				rtn = handleLit(data, e);
			} else  error(data, i);
			return rtn;
		}
		public static function decode(data:String):* {
			return instance.decode(data);
		}
		public static function parse(data:String):* {
			return instance.decode(data);
		}
		public static function get index():int {
			return instance.i;
		}
		
		private function tryToJSON(data:*):String {
			try {
				return data.toJSON() as String;
			} catch (e:ArgumentError) {
				if (e.errorID != 1063) throw e;
			}
			return null;
		}
		private function encode2(data:*):void {
			var ret:ByteArray = strArrE, c:String;
			if (data == null) {
				ret.writeUTFBytes("null");
				return;
			}
			if ("toJSON" in data) if (data.toJSON is Function) {
				c = tryToJSON(data);
				if (c != null) {
					handleStringE2(c, ret);
					return;
				}
			}
			if (data is Function) ret.writeUTFBytes("null");
			else if (data is String) {
				handleStringE2(data, ret, false);
			} else if (data is Number) {
				if ((data * 0) != 0) data = 0;
				ret.writeUTFBytes(String(data));
			} else if (data is Boolean) {
				ret.writeUTFBytes(String(data));
			} else if (data is Date) {
				ret.writeUTFBytes(String(data.getTime()));
			} else if (data is Array || getQualifiedClassName(data).indexOf("__AS3__.vec::Vector.<") == 0) {
				var i:int, e:int = data.length - 1;
				ret.writeByte(0x5B); // [
				if (e > 0) {
					if (e & 1) encode2(data[i++]), ret.writeByte(0x2C); // ,
					e >>>= 1;
					while (e--) {
						encode2(data[i++]);
						ret.writeByte(0x2C); // ,
						encode2(data[i++]);
						ret.writeByte(0x2C); // ,
					}
					encode2(data[i]);
				} else if (!e) {
					encode2(data[i]);
				}
				ret.writeByte(0x5D); // ]
			} else if (data is Dictionary) {
				ret.writeByte(0x7B); // {
				for (var b:* in data) {
					if (b is String) handleStringE2(b, ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is Number) handleStringE2(String(b), ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is Date) handleStringE2(String(b.getTime()), ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is XML) handleStringE2(b.toXMLString(), ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is Boolean) handleStringE2(String(b), ret), encode2(data[b]), ret.writeByte(0x2C);
				}
				if (b !== undefined) ret.position--;
				ret.writeByte(0x7D); // }
			} else if (data is XML) {
				handleStringE2(data.toXMLString(), ret, false);
			} else if (data is Object) {
				ret.writeByte(0x7B); // {
				for (c in data) {
					handleStringE2(c, ret), encode2(data[c]), ret.writeByte(0x2C);
				}
				if (c != null) ret.position--;
				ret.writeByte(0x7D); // }
			} else ret.writeUTFBytes("null");
		}
		private function encode(data:*):String {
			if (data == null) return "null";
			var ret:ByteArray = strArrE, c:String;
			ret.position = 0;
			if ("toJSON" in data) if (data.toJSON is Function) {
				c = tryToJSON(data);
				if (c !== null) return handleStringE(c, false);
			}
			if (data is Function) return "null";
			if (data is String) {
				handleStringE2(data, ret, false);
			} else if (data is Number) {
				if ((data * 0) != 0) data = 0;
				ret.writeUTFBytes(String(data));
			} else if (data is Boolean) {
				ret.writeUTFBytes(String(data));
			} else if (data is Date) {
				ret.writeUTFBytes(String(data.getTime()));
			} else if (data is Array || getQualifiedClassName(data).indexOf("__AS3__.vec::Vector.<") == 0) {
				var i:int, e:int = data.length - 1;
				ret.writeByte(0x5B); // [
				if (e > 0) {
					if (e & 1) encode2(data[i++]), ret.writeByte(0x2C); // ,
					e >>>= 1;
					while (e--) {
						encode2(data[i++]);
						ret.writeByte(0x2C); // ,
						encode2(data[i++]);
						ret.writeByte(0x2C); // ,
					}
					encode2(data[i]);
				} else if (!e) {
					encode2(data[i]);
				}
				ret.writeByte(0x5D); // ]
			} else if (data is Dictionary) {
				ret.writeByte(0x7B); // {
				for (var b:* in data) {
					if (b is String) handleStringE2(b, ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is Number) handleStringE2(String(b), ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is Date) handleStringE2(String(b.getTime()), ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is XML) handleStringE2(b.toXMLString(), ret), encode2(data[b]), ret.writeByte(0x2C);
					else if (b is Boolean) handleStringE2(String(b), ret), encode2(data[b]), ret.writeByte(0x2C);
				}
				if (b !== undefined) ret.position--;
				ret.writeByte(0x7D); // }
			} else if (data is XML) {
				handleStringE2(data.toXMLString(), ret, false);
			} else if (data is Object) {
				ret.writeByte(0x7B); // {
				for (c in data) {
					handleStringE2(c, ret), encode2(data[c]), ret.writeByte(0x2C);
				}
				if (c != null) ret.position--;
				ret.writeByte(0x7D); // }
			} else return "null";
			i = ret.position;
			ret.position = 0;
			c = ret.readUTFBytes(i);
			ret.length = 0;
			return c;
		}
		public static function encode(data:*):String {
			return instance.encode(data);
		}
		public static function stringify(data:*):String {
			return instance.encode(data);
		}
		public static function toJSON(data:* = null):String {
			return instance.encode(data);
		}
		
		private function isSpace(c:int):int {
			return (int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13));
		}
		private function isString(c:int):int {
			return (int(c == 0x22) | int(c == 0x27));
		}
		private function isObject(c:int):int {
			return int(c == 0x7B);
		}
		private function isArray(c:int):int {
			return int(c == 0x5B);
		}
		private function isNumber(c:int):int {
			return (int(c == 0x2D) | int(c == 0x2E) | (int(c > 0x2F) & int(c < 0x3A)) | int(c == 0x2B));
		}
		private function isNumeric(c:int):int {
			return (int(c > 0x2F) & int(c < 0x3A));
		}
		private function isLit(c:int):int {
			c |= 0x20;
			return (int(c == 0x74) | int(c == 0x66) | int(c == 0x6E));
		}
		
		private function min(a:Number, b:Number):Number {
			var c:int = int(a < b);
			return (c * a) + ((1 - c) * b); // fast a < b ? a : b;
		}
		private function handleStringE(data:String, colon:Boolean = true):String {
			var rtn:ByteArray = strArrE, c:int, i:int;
			var e:int = data.length, t:int;
			var enc:Vector.<int> = encRL;
			rtn.writeByte(0x22); // "
			while (i < e) {
				c = data.charCodeAt(i++);
				if (int(c < 0x20) | int(c > 0x7E)) { // ' ' | '~'
					t = int(c > 0xFFFF);
					t *= 0xFFFF;
					rtn.writeShort(0x5C75); // \u
					rtn.writeInt(enc[c & t]);
					continue;
				} else if (int(c == 0x22) | int(c == 0x5C)) { // " | \ 
					rtn.writeByte(0x5C); // \ 
				}
				rtn.writeByte(c);
			}
			rtn.writeShort(0x223A); // ":
			i = rtn.position - int(!colon); // faster than the if statement
			rtn.position = 0;
			data = rtn.readUTFBytes(i);
			rtn.length = 0;
			return data;
		}
		private function handleStringE2(data:String, rtn:ByteArray, colon:Boolean = true):void {
			var c:int, i:int;
			var e:int = data.length, t:int;
			var enc:Vector.<int> = encRL;
			rtn.writeByte(0x22); // "
			while (i < e) {
				c = data.charCodeAt(i++);
				if (int(c < 0x20) | int(c > 0x7E)) { // ' ' | '~'
					t = int(c > 0xFFFF);
					t *= 0xFFFF;
					rtn.writeShort(0x5C75); // \u
					rtn.writeInt(enc[c & t]);
					continue;
				} else if (int(c == 0x22) | int(c == 0x5C)) { // " | \ 
					rtn.writeByte(0x5C); // \ 
				}
				rtn.writeByte(c);
			}
			rtn.writeByte(0x22); // "
			if (colon) rtn.writeByte(0x3A); // :
			// ^ unavoidable
		}
		private function handleString(data:String, e:int):String {
			var c:int, rtn:ByteArray = strArr, inx:int, a:int = i, end:int = data.charCodeAt(a);
			var t:int, p:int, p1:int, p2:int;
			var enc:Vector.<int> = encD;
			rtn.position = 0;
			const low:int = 0x7F, u:int = 0x75, x:int = 0x78, slash:int = 0x5C;
			const seven:int = 7, nine:int = 9, space:int = 0x20
			while (a < e) {
				c = data.charCodeAt(++a);
				if (c == slash) {
					c = enc[data.charCodeAt(++a)]; // multi-byte characters will throw an error.
					if (c == u) {
						t = data.charCodeAt(++a) - 0x30;
						t -= (seven * int(t > nine)) | (int(t > 22) * 0x20);
						p1 = data.charCodeAt(++a) - 0x30;
						p1 -= (seven * int(p1 > nine)) | (int(p1 > 22) * 0x20);
						p2 = data.charCodeAt(++a) - 0x30;
						p2 -= (seven * int(p2 > nine)) | (int(p2 > 22) * 0x20);
						p = data.charCodeAt(++a) - 0x30;
						p -= (seven * int(p > nine)) | (int(p > 22) * 0x20);
						if (uint(t | p1 | p2 | p) > uint(15)) { // comparing with uint instead of int means the <0 check is combined
							error(data, a - 6, "Expected 0-F after \\u", 6);
						}
						rtn.position = inx;
						// 0xE00000 | ((i & 0xF000) << 4) | 0x8000 | ((i & 0xFC0) << 2) | 0x80 | (i & 0x3F)
						p1 = (p1 << 2) | (p2 >> 2);
						p = ((p2 << 2) | p) & 0x3F;
						rtn.writeInt((0xE0 | t) | ((0x80 | p1) << 8) | ((0x80 | p) << 16));
						++inx;
						++inx;
						++inx;
						continue;
					} else if (c == x) {
						t = data.charCodeAt(++a) - 0x30;
						t -= (seven * int(t > nine)) | (int(t > 22) * 0x20);
						p = data.charCodeAt(++a) - 0x30;
						p -= (seven * int(p > nine)) | (int(p > 22) * 0x20);
						if (uint(t | p) > uint(15)) { // comparing with uint instead of int means the <0 check is combined
							error(data, a - 4, "Expected 0-F after \\x", 4);
						}
						c = (t << 4) | p;
						rtn.position = inx;
						rtn.writeShort((0xC0 | ((c >> 6) & 0x1F)) | ((0x80 | (c & 0x3F)) << 8));
						++inx;
						++inx;
					}
				} else if (c == end) {
					i = a;
					rtn.position = 0;
					return rtn.readUTFBytes(inx);
				} else if (c > low) {
					return handleMBString(data, e, c, rtn, inx, a, end);
				}
				rtn[inx] = c;
				++inx;
			}
			error(data, i, "Unterminated String.", 1);
			return null; // not reached
		}
		private function handleMBString(data:String, e:int, c:int, rtn:ByteArray, inx:int, a:int, end:int):String {
			var t:int, p:int, p1:int, p2:int;
			var enc:Vector.<int> = encD;
			rtn.position = inx;
			while (a < e) {
				c = data.charCodeAt(++a);
				if (c == 0x5C) {
					c = enc[data.charCodeAt(++a)]; // multi-byte characters will throw an error.
					if (c == 0x75) {
						t = data.charCodeAt(++a) - 0x30;
						t -= (int(t > 9) * 7) | (int(t > 22) * 0x20);
						p1 = data.charCodeAt(++a) - 0x30;
						p1 -= (int(p1 > 9) * 7) | (int(p1 > 22) * 0x20);
						p2 = data.charCodeAt(++a) - 0x30;
						p2 -= (int(p2 > 9) * 7) | (int(p2 > 22) * 0x20);
						p = data.charCodeAt(++a) - 0x30;
						p -= (int(p > 9) * 7) | (int(p > 22) * 0x20);
						if (uint(t | p1 | p2 | p) > uint(15)) { // comparing with uint instead of int means the <0 check is combined
							error(data, a - 6, "Expected 0-F after \\u", 6);
						}
						c = ((((((t << 4) | p1) << 4) | p2) << 4) | p);
					} else if (c == 0x78) {
						t = data.charCodeAt(++a) - 0x30;
						t -= (int(t > 9) * 7) | (int(t > 22) * 0x20);
						p = data.charCodeAt(++a) - 0x30;
						p -= (int(p > 9) * 7) | (int(p > 22) * 0x20);
						if (uint(t | p) > uint(15)) { // comparing with uint instead of int means the <0 check is combined
							error(data, a - 4, "Expected 0-F after \\x", 4);
						}
						c = (t << 4) | p;
					}
				} else if (c == end) {
					i = a;
					inx = rtn.position;
					rtn.position = 0;
					return rtn.readUTFBytes(inx);
				}
				c = (0xF0 | ((c & 0x1C0000) >> 18)) | (0x8000 | ((c & 0x3F000) >> 4)) | 0x800000 | ((c & 0xFC0) << 10) | ((0x80 | (c & 0x3F)) << 16);
				rtn.writeInt(c);
			}
			error(data, i, "Unterminated String.", 1);
			return null;
		}
		private function handleNumber2(data:String, e:int):Number {
			var a:int = i, c:int = data.charCodeAt(a), r:Number = 0, t:int = 1;
			var n:Number, ex:int, exn:int, d:Number = 10;
			if (c == 0x2D) {
				c = data.charCodeAt(++a);
				n = 2;
			} else if (c == 0x2B) {
				c = data.charCodeAt(++a);
			}
			if ((int(c > 0x2F) & int(c < 0x3A))) {
				r = c - 0x30;
				while (int(a < e) & (int(int(c = int(data.charCodeAt(++a))) > 0x2F) & int(c < 0x3A))) {
					r = (r * 10) + (c - 0x30);
				}
			}
			if (c == 0x2E) {
				while (int(a < e) & (int(int(c = int(data.charCodeAt(++a))) > 0x2F) & int(c < 0x3A))) {
					r += (c - 0x30) / (t *= 10);
				}
			}
			if ((c | 0x20) == 0x65) {
				c = data.charCodeAt(++a);
				if (c == 0x2D) {
					exn = 1;
					c = data.charCodeAt(++a);
				} else if (c == 0x2B) c = data.charCodeAt(++a);
				t = 3;
				while (int(c > 0x2F) & int(c < 0x3A) & int(Boolean(t--))) {
					ex = (ex * 10) + (c - 0x30);
					c = data.charCodeAt(++a);
				}
				while (int(c > 0x2F) & int(c < 0x3A)) c = data.charCodeAt(++a); // consume the remainder
				t = 10;
				if (exn) {
					if (ex < 325) while (ex) {
						r /= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
						r /= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
					} else r = 0; // >= 325 for negative exponents results in 0
				} else {
					if (ex < 309)while (ex) {
						r *= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
						r *= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
					} else r = Infinity; // >= 309 for positive exponents results in Infinity
				}
			}
			if (a < e) {
				while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13))) c = data.charCodeAt(++a);
				if (a < e) {
					error(data, a);
				}
			}
			return (1 - n) * r;
		}
		private function handleNumber(data:String, e:int):Number {
			var a:int = i, c:int = data.charCodeAt(a), r:Number = 0, t:int = 1;
			var n:int, ex:int, exn:int, d:Number = 10;
			if (c == 0x2D) {
				c = data.charCodeAt(++a);
				n = 2;
			} else if (c == 0x2B) {
				c = data.charCodeAt(++a);
			}
			if ((int(c > 0x2F) & int(c < 0x3A))) {
				r = c - 0x30;
				while (int((c = int(data.charCodeAt(++a))) > 0x2F) & int(c < 0x3A)) {
					r = (r * 10) + (c - 0x30);
				}
				if (int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13) | int(c == 0x2C) | int((c | 0x20) == 0x7D)) {
					i = a - 1;
					return (1 - n) * r;
				}
			}
			if (c == 0x2E) {
				while (int((c = int(data.charCodeAt(++a))) > 0x2F) & int(c < 0x3A)) {
					r += (c - 0x30) / (t *= 10);
				}
				if (int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13) | int(c == 0x2C) | int((c | 0x20) == 0x7D)) {
					i = a - 1;
					return (1 - n) * r;
				}
			}
			if ((c | 0x20) == 0x65) {
				c = data.charCodeAt(++a);
				if (c == 0x2D) {
					exn = 1;
					c = data.charCodeAt(++a);
				} else if (c == 0x2B) c = data.charCodeAt(++a);
				t = 3;
				while (int(c > 0x2F) & int(c < 0x3A) & int(Boolean(t--))) { // limit the number of digits gathered for exponent to 3.
					ex = (ex * 10) + (c - 0x30);
					c = data.charCodeAt(++a);
				}
				while (int(c > 0x2F) & int(c < 0x3A)) c = data.charCodeAt(++a); // silently consume the remainder.
				t = 10;
				if (exn) {
					if (ex < 325) while (ex) {
						r /= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
						r /= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
					} else r = 0; // >= 325 for negative exponents results in 0
				} else {
					if (ex < 309) while (ex) {
						r *= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
						r *= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
					} else r = Infinity; // >= 309 for positive exponents results in Infinity
				}
				if (int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13) | int(c == 0x2C) | int((c | 0x20) == 0x7D)) {
					i = a - 1;
					return (1 - n) * r;
				}
			}
			if (a > e) {
				i = e;
				return (1 - n) * r;
			}
			error(data, a);
			return NaN; // not reached
		}
		private function handleLit(data:String, e:int):* {
			var a:int = data.charCodeAt(i++) | 0x20, b:int = data.charCodeAt(i++) | 0x20;
			var c:int = data.charCodeAt(i++) | 0x20, d:int = data.charCodeAt(i) | 0x20;
			if (a == 0x74) {
				if (int(b == 0x72) & int(c == 0x75) & int(d == 0x65)) return true
				error(data, i - 3, "Expected 'true'", 3);
			} else if (a == 0x66) {
				if (int(b == 0x61) & int(c == 0x6C) & int(d == 0x73) & int((data.charCodeAt(++i) | 0x20) == 0x65)) return false;
				error(data, i - 4, "Expected 'false'", 4);
			} else if (a == 0x6E) {
				if (int(b == 0x75) & int(c == 0x6C) & int(d == 0x6C)) return null;
				error(data, i - 3, "Expected 'null'", 3);
			}
		}
		private function handleArray(data:String, e:int):Array {
			var c:int, a:int=i, rtn:Array = preArrs.pop(), inx:int, p:Boolean = true;
			while (a < e) {
				do {
					c = data.charCodeAt(++a);
				} while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13)));
				if (c == 0x5D) {
					// throw error on ",]" ?
					rtn.length = inx;
					i = a;
					return rtn;
				} else if (p) {
					p = false;
					i = a;
					if ((int(c == 0x22) | int(c == 0x27))) {
						rtn[inx] = handleString(data, e);++inx;
						a = i;
					} else if ((int(c == 0x2D) | int(c == 0x2E) | (int(c > 0x2F) & int(c < 0x3A)) | int(c == 0x2B))) {
						rtn[inx] = handleNumber(data, e);++inx;
						a = i;
					} else if (c == 0x7B) {
						rtn[inx] = handleObject(data, e);++inx;
						a = i;
					} else if (c == 0x5B) {
						rtn[inx] = handleArray(data, e);++inx;
						a = i;
					} else if (isLit(c)) {
						rtn[inx] = handleLit(data, e);++inx;
						a = i;
					} else error(data, i); // by having nothing after this, the jumps out of the above tree all result at the top of the loop.
				} else if ((p = (c == 0x2C))) void;
				else error(data, a, "Expected , or ]");
			}
			error(data, i, "Unterminated Array.", 1);
			return null; // not reached
		}
		private function handleObject(data:String, e:int):Object {
			var c:int, a:int=i, rtn:Object = preObjs.pop(), inx:String, p:Boolean = true;
			while (a < e) {
				do {
					c = data.charCodeAt(++a);
				} while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13)));
				if (c == 0x7D) {
					// error on ,} ?
					i = a;
					return rtn;
				} else if (p) {
					p = false;
					if ((int(c == 0x22) | int(c == 0x27))) {
						i = a;
						inx = handleString(data, e);
						a = i;
						 do {
							c = data.charCodeAt(++a);
						} while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13)));
						if (c == 0x3A) {
							do {
								c = data.charCodeAt(++a);
							} while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13))); // wish i could omit these
							i = a;
							if ((int(c == 0x22) | int(c == 0x27))) {
								rtn[inx] = handleString(data, e);
								a = i;
							} else if ((int(c == 0x2D) | int(c == 0x2E) | (int(c > 0x2F) & int(c < 0x3A)) | int(c == 0x2B))) {
								rtn[inx] = handleNumber(data, e);
								a = i;
							} else if (c == 0x5B) {
								rtn[inx] = handleArray(data, e);
								a = i;
							} else if (c == 0x7B) {
								rtn[inx] = handleObject(data, e);
								a = i;
							} else if (isLit(c)) {
								rtn[inx] = handleLit(data, e);
								a = i;
							} else error(data, a, "Expected value.", 1); // values arranged in an attempt to get best performance
						} else error(data, a, "Expected :");
					} else error(data, a, "Expected \" or '"); // rearranging this saves one jump for every object property.
				} else if ((p = (c == 0x2C))) void;
				else error(data, a, "Expected , or }");
			}
			error(data, a, "Unterminated Object.", 1);
			return null; // not reached
		}
		private function error(data:String, i:int, e:String = null, l:int = 0):void {
			if (l) {
				if (l > 1) {
					throw new Error("Malformed JSON at: " + i + ", '" + data.substr(i, l) + (e ? "'. " + e : "'."), errorID);
				} else {
					throw new Error("Malformed JSON at: " + this.i + ' ' + i + ", " + data.charAt(i) + (e ? ". " + e : '.'), errorID);
				}
			} else {
				throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + (e ? ". " + e : '.'), errorID);
			}
		}
	}
}
