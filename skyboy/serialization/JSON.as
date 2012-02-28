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
			var i:int = 0x10000;
			while (i--) {
				encRL[i] = (0x30303030 | ((i & 0xF000) << 12) | ((i & 0xF00) << 8) | ((i & 0xF0) << 4) | (i & 0xF)) +
				(((int((i & 0xF000) > 0x9000) * 0x7000) << 12) |
				((int((i & 0xF00) > 0x900) * 0x700) << 8) |
				((int((i & 0xF0) > 0x90) * 0x70) << 4) |
				((int((i & 0xF) > 0x9) * 0x7)));
			}
			i = 0x80;
			while (i--) {
				encD[i] = i;
			}
			encD[0x62] = 8;
			encD[0x66] = 12;
			encD[0x6E] = 10;
			encD[0x72] = 13;
			encD[0x74] = 9;
			encMap[Vector.<int>] 	= encodeVecI;
			encMap[Vector.<uint>] 	= encodeVecU;
			encMap[Vector.<Number>] = encodeVecN;
			encMap[Vector.<*>] 		= encodeVecO;
			encMap[Array] 			= encodeArry;
			encMap[String] 			= encodeString;
			encMap['string'] 		= encodeString;
			encMap[XML] 			= encodeXML;
			encMap['xml'] 			= encodeXML;
			encMap[XMLList] 		= encodeXMLL;
			encMap[Date] 			= encodeDate;
			encMap[Number] 			= encodeNumber;
			encMap['number'] 		= encodeNumber;
			encMap[Dictionary] 		= encodeDict;
			encMap[Object] 			= encodeObject;
			encMap[Boolean] 		= encodeBool;
			encMap['boolean'] 		= encodeBool;
			encMap['object'] 		= encodeObj2; // nulls are of type object
			encMap['undefined'] 	= encodeObj2;
		}
		private var containsSlash:int;
		private const strArr:ByteArray = new ByteArray();
		private const encRL:Vector.<int> = new Vector.<int>(0x10000, true);
		private const encD:Vector.<int> = new Vector.<int>(0x80, true);
		private const encMap:Dictionary = new Dictionary();
		private var i:int;
		
		public static const errorID:int = 0x4A534F4E;
		
		private function decode(data:String):* {
			if (!data) return null;
			var e:int = data.length;
			var a:int, c:int = data.charCodeAt(a), temp:int;
			while ((int(c === 0x20) | int(c === 0x09) | int(c === 10) | int(c === 13))) {
				c = data.charCodeAt(++a);
			}
			var rtn:*;
			i = a;
			temp = data.indexOf('\\') + 1
			containsSlash = temp;
			if (c === 0x7B) {
				rtn = handleObject(data, e);
			} else if (c === 0x5B) {
				rtn = handleArray(data, e, data.charCodeAt(a + 1));
			} else if ((int(c === 0x22) | int(c === 0x27))) {
				rtn = '"';
				if (c === 0x27) rtn = "'";
				++a;
				if (temp) {
					rtn = handleString(data, e, data.charCodeAt(a), c);
				} else rtn = data.substring(a, data.indexOf(rtn, a));
			} else if ((int(c === 0x2D) | int(c === 0x2E) | (int(c > 0x2F) & int(c < 0x3A)) | int(c === 0x2B))) {
				rtn = handleNumber2(data, e);
			} else if ((int(c === 0x74) | int(c === 0x66) | int(c === 0x6E))) {
				rtn = handleLit(data, e, a);
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
		private function encode(data:Object):String {
			if (data == null) return "null";
			var ret:ByteArray = strArr, c:String, enc:Vector.<int> = encRL;
			ret.position = 0;
			if ("toJSON" in data) if (data.toJSON is Function) {
				c = tryToJSON(data);
				if (c !== null) return c;
			}
			var a:Function = encMap[data.constructor];
			if (Boolean(a)) a(data, ret, enc, encMap);
			else encodeObject(data, ret, enc, encMap);
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
		
		private function encodeArry(arr:Array, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			var i:int, e:int = arr.length - 1, f:Function, el:*;
			rtn.writeByte(0x5B); // [
			if (e >= 0) {
				while (i < e) {
					el = arr[i];
					f = map[typeof el];
					f(el, rtn, enc, map);
					rtn.writeByte(0x2C); // ,
					++i;
				}
				el = arr[i];
				f = map[typeof e];
				f(el, rtn, enc, map);
			}
			rtn.writeByte(0x5D); // ]
		}
		private function encodeVecO(arr:*, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void { // * because vector can be of any type other than number/int/uint and no two vector 'types' are compatible
			if (arr is Vector.<Boolean>) {
				encodeVecB(arr, rtn, enc);
				return;
			} else if (arr is Vector.<String>) {
				encodeVecS(arr, rtn, enc);
				return;
			}
			var i:int, e:int = arr.length - 1, f:Function, el:*;
			rtn.writeByte(0x5B); // [
			if (e >= 0) {
				while (i < e) {
					el = arr[i];
					f = map[typeof el];
					f(el, rtn, enc, map);
					rtn.writeByte(0x2C); // ,
					++i;
					f = null;
				}
				el = arr[i];
				f = map[typeof el];
				f(el, rtn, enc, map);
			}
			rtn.writeByte(0x5D); // ]
		}
		private function encodeVecN(a:Vector.<Number>, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			var e:int = a.length - 1, i:int;
			rtn.writeByte(0x5B); // [
			if (e >= 0) {
				while (i < e) {
					rtn.writeUTFBytes(String(a[i]));
					rtn.writeByte(0x2C); // ,
					++i;
				}
				rtn.writeUTFBytes(String(a[i]));
			}
			rtn.writeByte(0x5D); // ]
		}
		private function encodeVecU(a:Vector.<uint>, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			var e:int = a.length - 1, i:int;
			rtn.writeByte(0x5B); // [
			if (e >= 0) {
				while (i < e) {
					rtn.writeUTFBytes(String(a[i]));
					rtn.writeByte(0x2C); // ,
					++i;
				}
				rtn.writeUTFBytes(String(a[i]));
			}
			rtn.writeByte(0x5D); // ]
		}
		private function encodeVecI(a:Vector.<int>, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			var e:int = a.length - 1, i:int;
			rtn.writeByte(0x5B); // [
			if (e >= 0) {
				while (i < e) {
					rtn.writeUTFBytes(String(a[i]));
					rtn.writeByte(0x2C); // ,
					++i;
				}
				rtn.writeUTFBytes(String(a[i]));
			}
			rtn.writeByte(0x5D); // ]
		}
		private function encodeVecB(a:Vector.<Boolean>, rtn:ByteArray, enc:Vector.<int>):void {
			var e:int = a.length - 1, i:int;
			rtn.writeByte(0x5B); // [
			if (e >= 0) {
				while (i < e) {
					if (a[i]) { // Boolean vectors can technically contain null (last test: FP11.1) due to poor Adobe coding. no special cases for it here, though.
						rtn.writeInt(0x74727565); // true
						rtn.writeByte(0x2C); // ,
					} else {
						rtn.writeShort(0x6661); // fa
						rtn.writeInt(0x6C73652C); // lse,
					}
					++i;
				}
				rtn.writeUTFBytes(String(a[i]));
			}
			rtn.writeByte(0x5D); // ]
		}
		private function encodeVecS(a:Vector.<String>, rtn:ByteArray, enc:Vector.<int>):void {
			var e:int = a.length - 1, i:int, b:String;
			rtn.writeByte(0x5B); // [
			if (e >= 0) {
				while (i < e) {
					b = a[i] as String;
					if (b !== null) encodeString(String(a[i] as String), rtn, enc);
					else rtn.writeInt(0x6E756C6C);
					rtn.writeByte(0x2C);
					++i;
				}
				b = a[i];
				if (b !== null) encodeString(String(a[i] as String), rtn, enc);
				else rtn.writeInt(0x6E756C6C);
			}
			rtn.writeByte(0x5D); // ]
		}
		private function encodeBool(a:Boolean, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			if (a) {
				rtn.writeInt(0x74727565); // true
				return;
			}
			rtn.writeByte(0x66); // f
			rtn.writeInt(0x616C7365); // alse
		}
		private function encodeDate(a:Date, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			rtn.writeUTFBytes(String(a.getTime()));
		}
		private function encodeDict(dic:Dictionary, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			var e:Object, f:Function, map:Dictionary = encMap;
			rtn.writeByte(0x7B); // {
			for (var b:* in dic) {
				if (b is String) {e = dic[b];
					encodeString(b, rtn, enc, null, true);
					f = map[typeof e];
					f(e, rtn, enc, map);
					rtn.writeByte(0x2C);
				} else if (b is Number) {e = dic[b];
					encodeString(String(b), rtn, enc, null, true);
					f = map[typeof e];
					f(e, rtn, enc, map);
					rtn.writeByte(0x2C);
				} else if (b is Date) {e = dic[b];
					encodeString(String((b as Date).getTime()), rtn, enc, null, true);
					f = map[typeof e];
					f(e, rtn, enc, map);
					rtn.writeByte(0x2C);
				} else if (b is XML) {e = dic[b];
					encodeString((b as XML).toXMLString(), rtn, enc, null, true);
					f = map[typeof e];
					f(e, rtn, enc, map);
					rtn.writeByte(0x2C);
				} else if (b is XMLList) {e = dic[b];
					encodeString((b as XMLList).toXMLString(), rtn, enc, null, true);
					f = map[typeof e];
					f(e, rtn, enc, map);
					rtn.writeByte(0x2C);
				} else if (b is Boolean) {e = dic[b];
					encodeString(String(b), rtn, enc, null, true);
					f = map[typeof e];
					f(e, rtn, enc, map);
					rtn.writeByte(0x2C);
				}
			}
			if (b !== undefined) rtn.position--;
			rtn.writeByte(0x7D); // }
		}
		private function encodeObject(a:Object, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			if (!a) {
				rtn.writeInt(0x6E756C6C);
				return;
			}
			if ("toJSON" in a) if (a.toJSON is Function) {
				c = tryToJSON(a);
				if (c !== null) {
					rtn.writeUTFBytes(c);
					return;
				}
			}
			rtn.writeByte(0x7B); // {
			var c:String, e:Object, f:Function;
			for (c in a) {
				encodeString(c, rtn, enc, null, true);
				e = a[c];
				f = map[typeof e];
				f(e, rtn, enc, map);
				rtn.writeByte(0x2C);
			}
			if (c !== null) rtn.position--;
			rtn.writeByte(0x7D); // }
		}
		private function encodeObj2(a:Object, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			if (!a) {
				rtn.writeInt(0x6E756C6C);
				return;
			}
			var f:Function = map[a.constructor];
			if (Boolean(f)) {
				f(a, rtn, enc, map);
				return;
			}
			encodeObject(a, rtn, enc, map);
		}
		private function encodeXML(a:XML, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			encodeString(a.toXMLString(), rtn, enc);
		}
		private function encodeXMLL(a:XMLList, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			encodeString(a.toXMLString(), rtn, enc);
		}
		private function encodeNumber(e:Number, rtn:ByteArray, enc:Vector.<int>, map:Dictionary):void {
			if ((e * 0) !== 0) {
				rtn.writeByte(0x30);
				return;
			}
			rtn.writeUTFBytes(String(e));
		}
		private function encodeString(data:String, rtn:ByteArray, enc:Vector.<int>, map:Dictionary = null, colon:Boolean = false):void {
			var c:int, i:int;
			var e:int = data.length, t:int;
			rtn.writeByte(0x22); // "
			while (i < e) {
				c = data.charCodeAt(i++);
				if (int(c < 0x20) | int(c > 0x7E)) { // ' ' | '~'
					t = int(c <= 0xFFFF);
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
		
		private function min(a:Number, b:Number):Number {
			var c:int = int(a < b);
			return (c * a) + ((1 - c) * b); // fast a < b ? a : b;
		}
		private function handleString(data:String, e:int, c:int, end:int):String { // additional arguments to provide speed boosts
			var a:int = i+1; // passed in 'c' is first character of string. 'end' is teminator (" or ')
			if (c == end) { // fastpath: empty string
				i = a;
				return '';
			}
			var t:int = data.charCodeAt(a + 1), inx:int = int(c != 0x5C);
			if (inx & int(t == end)) { // fastpath: single character string
				i = a + 1;
				return String.fromCharCode(c);
			}
			var p:int = containsSlash, p1:int, p2:int, temp:String = '"';
			if (end === 0x27) temp = "'";
			if (p & int(a > p)) p = data.indexOf('\\', a) + 1, containsSlash = p;
			p1 = data.indexOf(temp, a);
			if ((int(!p) | int(p > p1)) & int(Boolean(p1 + 1))) {
				i = p1;
				return data.substring(a, p1);
			}
			var rtn:ByteArray = strArr;
			if (inx & int(c < 0x80)) rtn[0] = c, c = t, ++a;
			var enc:Vector.<int> = encD;
			rtn.position = 0;
			const low:int = 0x7F, u:int = 0x75, x:int = 0x78, slash:int = 0x5C;
			const two:int = 2, seven:int = 7, nine:int = 9, space:int = 0x20, tt:int = 22;
			while (a < e) {
				if (c === slash) {
					c = data.charCodeAt(++a);
					if (c > low) return handleMBString(data, e, c, rtn, inx, a, end);
					c = enc[c];
					if (c === u) {
						t = data.charCodeAt(++a) - 0x30;
						t -= (seven & -int(t > nine)) | (space & -int(t > tt));
						p1 = data.charCodeAt(++a) - 0x30;
						p1 -= (seven & -int(p1 > nine)) | (space & -int(p1 > tt));
						p2 = data.charCodeAt(++a) - 0x30;
						p2 -= (seven & -int(p2 > nine)) | (space & -int(p2 > tt));
						p = data.charCodeAt(++a) - 0x30;
						p -= (seven & -int(p > nine)) | (space & -int(p > tt));
						if (uint(t | p1 | p2 | p) > 15) { // comparing with uint instead of int means the <0 check is combined
							error(data, a - 6, "Expected 0-F after \\u", 6);
						}
						rtn.position = inx;
						// 0xE00000 | ((i & 0xF000) << 4) | 0x8000 | ((i & 0xFC0) << 2) | 0x80 | (i & 0x3F)
						p1 = (p1 << two) | (p2 >> two);
						p = ((p2 << two) | p) & 0x3F;
						rtn.writeInt((0xE0 | t) | ((0x80 | p1) << 8) | ((0x80 | p) << 16));
						inx += 3;
						c = data.charCodeAt(++a);
						continue;
					} else if (c === x) {
						t = data.charCodeAt(++a) - 0x30;
						t -= (seven & -int(t > nine)) | (space & -int(t > tt));
						p = data.charCodeAt(++a) - 0x30;
						p -= (seven & -int(p > nine)) | (space & -int(p > tt));
						if (uint(t | p) > 15) { // comparing with uint instead of int means the <0 check is combined
							error(data, a - 4, "Expected 0-F after \\x", 4);
						}
						c = (t << 4) | p;
						rtn.position = inx;
						rtn.writeShort((0xC0 | ((c >> 6) & 0x1F)) | ((0x80 | (c & 0x3F)) << 8));
						++inx;
						++inx;
						c = data.charCodeAt(++a);
						continue;
					}
				} else if (c === end) {
					i = a;
					rtn.position = 0;
					return rtn.readUTFBytes(inx);
				} else if (c > low) {
					return handleMBString(data, e, c, rtn, inx, a, end);
				}
				rtn[inx] = c;
				++inx;
				c = data.charCodeAt(++a);
			}
			error(data, i, "Unterminated String.", 1);
			return null; // not reached
		}
		private function handleMBString(data:String, e:int, c:int, rtn:ByteArray, inx:int, a:int, end:int):String { // the much slower method capable of handling multi-byte characters
			var t:int, p:int, p1:int, p2:int;
			var enc:Vector.<int> = encD;
			rtn.position = inx;
			while (a < e) {
				c = data.charCodeAt(++a);
				if (c === 0x5C) {
					if (c < 0x80) {
						c = enc[data.charCodeAt(++a)];
						if (c === 0x75) {
							t = data.charCodeAt(++a) - 0x30;
							t -= (-int(t > 9) & 7) | (-int(t > 22) & 0x20);
							p1 = data.charCodeAt(++a) - 0x30;
							p1 -= (-int(p1 > 9) & 7) | (-int(p1 > 22) & 0x20);
							p2 = data.charCodeAt(++a) - 0x30;
							p2 -= (-int(p2 > 9) & 7) | (-int(p2 > 22) & 0x20);
							p = data.charCodeAt(++a) - 0x30;
							p -= (-int(p > 9) & 7) | (-int(p > 22) & 0x20);
							if (uint(t | p1 | p2 | p) > 15) { // comparing with uint instead of int means the <0 check is combined
								error(data, a - 6, "Expected 0-F after \\u", 6);
							}
							c = ((((((t << 4) | p1) << 4) | p2) << 4) | p);
						} else if (c === 0x78) {
							t = data.charCodeAt(++a) - 0x30;
							t -= (-int(t > 9) & 7) | (-int(t > 22) & 0x20);
							p = data.charCodeAt(++a) - 0x30;
							p -= (-int(p > 9) & 7) | (-int(p > 22) & 0x20);
							if (uint(t | p) > 15) { // comparing with uint instead of int means the <0 check is combined
								error(data, a - 4, "Expected 0-F after \\x", 4);
							}
							c = (t << 4) | p;
						}
					}
				} else if (c === end) {
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
		private function handleFNumber(data:String, e:int, a:int, c:int, r:Number, n:int):Number { // original method
			if ((int(c > 0x2F) & int(c < 0x3A))) {
				r = c - 0x30;
				while (int((c = int(data.charCodeAt(++a))) > 0x2F) & int(c < 0x3A)) {
					r = (r * 10) + (c - 0x30);
					// TODO: largest represtnable number in Number is over 18 digits; can't use int here, performance pentalty for extremely large values\
					// but beyond 52 bits of precision, Number loses accuracy. @parseFloat()@/@Number()@ may limit to 53 bits in a long. investigate.
				}
				if (int(c === 0x20) | int(c === 0x09) | int(c === 10) | int(c === 13) | int(c === 0x2C) | int((c | 0x20) === 0x7D)) {
					i = a - 1;
					return n * r;
				}
			}
			var t:int = 1, ex:int, exn:int, d:Number = 10;
			if (c === 0x2E) {
				while (int((c = int(data.charCodeAt(++a))) > 0x2F) & int(c < 0x3A)) {
					r += (c - 0x30) / (t *= 10); // i don't think i can improve this.
				}
				if (int(c === 0x20) | int(c === 0x09) | int(c === 10) | int(c === 13) | int(c === 0x2C) | int((c | 0x20) === 0x7D)) {
					i = a - 1;
					return n * r;
				}
			}
			if ((c | 0x20) === 0x65) {
				c = data.charCodeAt(++a);
				if (c == 0x2D) {
					exn = 1;
					c = data.charCodeAt(++a);
				} else if (c == 0x2B) c = data.charCodeAt(++a);
				t = 3;
				while (int(c > 0x2F) & int(c < 0x3A) & int(Boolean(t--))) { // limit the number of digits gathered for exponent to 3.
					ex *= 10;
					c -= 0x30;
					ex += c;
					t += int(int(!c) & int(t == 2)); // consume leading 0s
					c = data.charCodeAt(++a);
				}
				if (int(c > 0x2F) & int(c < 0x3A)) {
					d = NaN; // mark that we have gone over 3 digits (excluding leading 0s); this value is too great
					do {
						c = data.charCodeAt(++a); // consume the remainder.
					} while (int(c > 0x2F) & int(c < 0x3A));
				}
				t = 10;
				if (exn) {
					if (int(ex < 325) & int(d == d)) while (ex) {
						r /= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
						r /= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
					} else r = 0; // >= 325 for negative exponents results in 0
				} else {
					if (int(ex < 309) & int(d == d)) while (ex) {
						r *= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
						r *= ((ex & 1) * t + (~ex & 1));
						ex >>>= 1;
						t *= t;
					} else r = Infinity; // >= 309 for positive exponents results in Infinity
				}
				if (int(c === 0x20) | int(c === 0x09) | int(c === 10) | int(c === 13) | int(c === 0x2C) | int((c | 0x20) === 0x7D)) {
					i = a - 1;
					return n * r;
				}
			}
			if (a > e) {
				i = e;
				return n * r;
			}
			error(data, a);
			return NaN; // not reached
		}
		private function handleNumber(data:String, e:int):Number { // fast int-first method
			var a:int = i, c:int = data.charCodeAt(a), r:int, n:int = 1, C:int;
			if (c === 0x2D) {
				c = data.charCodeAt(++a);
				n = -1;
			} else if (c === 0x2B) {
				c = data.charCodeAt(++a);
			}
			if ((int(c > 0x2F) & int(c < 0x3A))) {
				r = c - 0x30;
				while (Boolean(int((c = int(data.charCodeAt(++a))) > 0x2F) & int(c < 0x3A) & int(C <= 9))) {
					r *= 10;
					c -= 48;
					r += c;
					++C;
				}
				if (C > 9) return handleFNumber(data, e, a, c, r, n);
				if (int(c === 0x20) | int(c === 0x09) | int(c === 10) | int(c === 13) | int(c === 0x2C) | int((c | 0x20) === 0x7D)) {
					i = a - 1;
					return n * r;
				}
			}
			if (c === 0x2E) return handleFNumber(data, e, a, c, r, n);
			if ((c | 0x20) === 0x65) return handleFNumber(data, e, a, c, r, n);
			if (a > e) {
				i = e;
				return n * r;
			}
			error(data, a);
			return NaN; // not reached
		}
		private function handleLit(data:String, e:int, q:int):* {
			var a:int = data.charCodeAt(q++), b:int = data.charCodeAt(q++);
			var c:int = data.charCodeAt(q++), d:int = data.charCodeAt(q);
			i = q;
			if (int(a === 0x74) & int(b === 0x72) & int(c === 0x75) & int(d === 0x65)) return true
			else if (int(a === 0x6E) & int(b === 0x75) & int(c === 0x6C) & int(d === 0x6C)) return null;
			else if (a === 0x66) {
				if (int(b === 0x61) & int(c === 0x6C) & int(d === 0x73) & int(data.charCodeAt(++i) === 0x65)) return false;
				error(data, --i, "Expected 'false'", 4);
			} else {
				if (a === 0x74) error(data, i, "Expected 'true'", 3);
				error(data, i, "Expected 'null'", 3);
			}
		}
		private function handleArray(data:String, e:int, c:int, ...rtn):Array { // implicit allocation of return array. much faster
			var a:int = i + 1;
			if (c === 0x5D) {
				i = a;
				return rtn;
			}
			var inx:int, p:Boolean = true;
			while (a < e) {
				while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13))) {
					c = data.charCodeAt(++a);
				}
				if (c === 0x5D) {
					if (p) error(data, a, "Expected value.", 1);
					rtn.length = inx;
					i = a;
					return rtn;
				} else if (p) {
					p = false;
					i = a;
					if ((int(c === 0x22) | int(c === 0x27))) {
						rtn[inx] = handleString(data, e, data.charCodeAt(a + 1), c);
						a = i;
					} else if ((int(c === 0x2D) | int(c === 0x2E) | (int(c > 0x2F) & int(c < 0x3A)) | int(c === 0x2B))) {
						rtn[inx] = handleNumber(data, e);
						a = i;
					} else if (c === 0x7B) {
						rtn[inx] = handleObject(data, e);
						a = i;
					} else if (c === 0x5B) {
						rtn[inx] = handleArray(data, e, data.charCodeAt(a + 1));
						a = i;
					} else if ((int(c === 0x74) | int(c === 0x66) | int(c === 0x6E))) {
						rtn[inx] = handleLit(data, e, a);
						a = i;
					} else error(data, a, "Expected value.", 1); // by having nothing after this, the jumps out of the above tree all result at the top of the loop.
				} else if ((inx += int(p = (c === 0x2C)),p)) void;
				else error(data, a, "Expected , or ]");
				c = data.charCodeAt(++a);
			}
			error(data, i, "Unterminated Array.", 1);
			return null; // not reached
		}
		private function handleObject(data:String, e:int):Object {
			var c:int, a:int = i, rtn:Object = new Object, inx:String, p:Boolean = true;
			c = data.charCodeAt(++a);
			if (c === 0x7D) {
				i = a;
				return rtn;
			}
			while (a < e) {
				while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13))) {
					c = data.charCodeAt(++a);
				}
				if (c === 0x7D) {
					if (p) error(data, a, "Expected value.", 1)
					i = a;
					return rtn;
				} else if (p) {
					p = false;
					if ((int(c === 0x22) | int(c === 0x27))) {
						i = a;
						inx = handleString(data, e, data.charCodeAt(a + 1), c);
						a = i;
						 do {
							c = data.charCodeAt(++a);
						} while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13)));
						if (c === 0x3A) {
							do {
								c = data.charCodeAt(++a);
							} while ((int(c == 0x20) | int(c == 0x09) | int(c == 10) | int(c == 13))); // wish i could omit these
							i = a;
							if ((int(c === 0x22) | int(c === 0x27))) {
								rtn[inx] = handleString(data, e, data.charCodeAt(a + 1), c);
								a = i;
							} else if ((int(c === 0x2D) | int(c === 0x2E) | (int(c > 0x2F) & int(c < 0x3A)) | int(c === 0x2B))) {
								rtn[inx] = handleNumber(data, e);
								a = i;
							} else if (c === 0x5B) {
								rtn[inx] = handleArray(data, e, data.charCodeAt(a + 1));
								a = i;
							} else if (c === 0x7B) {
								rtn[inx] = handleObject(data, e);
								a = i;
							} else if ((int(c === 0x74) | int(c === 0x66) | int(c === 0x6E))) {
								rtn[inx] = handleLit(data, e, a);
								a = i;
							} else error(data, a, "Expected value.", 1); // values arranged in an attempt to get best performance
						} else error(data, a, "Expected :");
					} else error(data, a, "Expected \" or '"); // rearranging this saves one jump for every object property.
				} else if ((p = (c === 0x2C))) void;
				else error(data, a, "Expected , or }");
				c = data.charCodeAt(++a);
			}
			error(data, a, "Unterminated Object.", 1);
			return null; // not reached
		}
		private function error(data:String, i:int, e:String = null, l:int = 0):void {
			if (l) {
				if (l > 1) {
					throw new Error("Malformed JSON at: " + i + ", '" + data.substr(i, l) + (e ? "'. " + e : "'."), errorID);
				} else {
					throw new Error("Malformed JSON at: " + i + ", '" + data.charAt(i) + (e ? "'. " + e : "'."), errorID);
				}
			} else {
				throw new Error("Malformed JSON at char: " + i + ", '" + data.charAt(i) + (e ? "'. " + e : "'."), errorID);
			}
		}
	}
}
