package skyboy.serialization {
	import flash.utils.ByteArray;
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
	public class JSON {
		public function JSON() {
			throw new Error("This class has no instance methods.")
		}
		private static var i:int;
		private static const preArrs:Vector.<Array> = new Vector.<Array>();
		private static const preObjs:Vector.<Object> = new Vector.<Object>();
		private static const strArr:ByteArray = new ByteArray();strArr.length = 0xFFFF;
		private static const strArrE:ByteArray = new ByteArray();strArrE.length = 0xFFFF;
		public static function parse(data:String):* {
			return decode(data);
		}
		public static function decode(data:String):* {
			if (data == null) {
				return null;
			}
			data = data.valueOf();
			var e:int = data.length;
			if (e == 0) return null;
			var temp:int, objs:int = -preObjs.length;
			while ((temp = data.indexOf("}", temp + 1)) !== -1) ++objs;
			if (objs > 0) {
				preObjs.length = objs;
				while (objs-- > 0) preObjs[objs] = new Object;
			}
			objs = temp = 0;
			while ((temp = data.indexOf("]", temp + 1)) !== -1) ++objs;
			preArrs.length = objs;
			while (objs-- > 0) preArrs[objs] = new Array(e);
			var c:int = data.charCodeAt(i = 0);
			if (isSpace(c)) {
				do {
					c = data.charCodeAt(++i);
				} while (isSpace(c) && i != e);
			}
			var rtn:*;
			if (isObject(c)) {
				rtn = handleObject(data, e);
			} else if (isArray(c)) {
				rtn = handleArray(data, e);
			} else if (isString(c)) {
				rtn = handleString(data, e);
			} else if (isNumber(c)) {
				rtn = handleNumber2(data, e);
			} else if (isLit(c)) {
				return handleLit(data, e);
			}
			if (rtn === undefined) error(data, i);
			strArr.length = 0;
			return rtn;
		}
		private static function tryToJSON(data:*):String {
			try {
				return data.toJSON() as String;
			} catch (e:ArgumentError) {
				if (e.errorID != 1063) throw e;
			}
			return null;
		}
		public static function encode(data:*):String {
			if (data == null) return "null";
			var ret:ByteArray = strArrE, c:String;
			ret.position = 0;
			if ("toJSON" in data) if (data.toJSON is Function) {
				c = tryToJSON(data);
				if (c != null) return handleStringE(c, false);
			}
			if (data is Function) return "null";
			if (data is String) {
				handleStringE2(data, ret, false);
			} else if (data is XML) {
				handleStringE2(data.toXMLString(), ret, false);
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
		private static function encode2(data:*):void {
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
			} else if (data is XML) {
				handleStringE2(data.toXMLString(), ret, false);
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
			} else if (data is Object) {
				ret.writeByte(0x7B); // {
				for (c in data) {
					handleStringE2(c, ret), encode2(data[c]), ret.writeByte(0x2C);
				}
				if (c != null) ret.position--;
				ret.writeByte(0x7D); // }
			} else ret.writeUTFBytes("null");
		}
		public static function get index():int {
			return i;
		}
		
		private static function isSpace(i:int):Boolean {
			return i == 0x20 || i == 0x09;
		}
		private static function isString(i:int):Boolean {
			return i == 0x22 || i == 0x27;
		}
		private static function isObject(i:int):Boolean {
			return i == 0x7B;
		}
		private static function isArray(i:int):Boolean {
			return i == 0x5B;
		}
		private static function isNumber(i:int):Boolean {
			return i == 0x2D || i == 0x2E || (i > 0x2F && i < 0x3A) || i == 0x2B;
		}
		private static function isNumeric(i:int):Boolean {
			return i > 0x2F && i < 0x3A;
		}
		private static function isLit(i:int):Boolean {
			i |= 0x20;
			return i == 0x74 || i == 0x66 || i == 0x6E;
		}
		private static function min(a:Number, b:Number):Number {
			return a < b ? a : b;
		}
		private static function handleStringE(data:String, colon:Boolean = true):String {
			var rtn:ByteArray = strArr, inx:int, c:int, i:int;
			var e:int = data.length, t:int;
			if (e == 0) return "";
			rtn.length = min(e * 5 + 3, 0xFFFFFF);
			rtn[inx++] = 0x22;
			while (i != e) {
				c = data.charCodeAt(i++);
				if (c < 32 || c > 127) {
					if (c > 0xFFFF) c = 0xFFFF;
					rtn[inx++] = 0x5C;
					rtn[inx++] = 0x75;
					t = ((c & 0xF000) >> 12) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					t = ((c & 0xF00) >> 8) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					t = ((c & 0xF0) >> 4) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					t = (c & 15) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					continue;
				} else if (c == 0x22 || c == 0x5C) {
					rtn[inx++] = 0x5C;
					rtn[inx++] = c;
					continue;
				}
				rtn[inx++] = c;
			}
			rtn[inx++] = 0x22;
			if (colon) rtn[inx++] = 0x3A;
			rtn.position = 0;
			data = rtn.readUTFBytes(inx);
			rtn.length = 0;
			return data;
		}
		private static function handleStringE2(data:String, rtn:ByteArray, colon:Boolean = true):void {
			if (!rtn) return;
			var inx:int = rtn.position, c:int, i:int;
			var e:int = data.length, t:int;
			if (e == 0) return;
			rtn.length = min(e * 5 + 3, 0xFFFFFF);
			rtn[inx++] = 0x22;
			while (i != e) {
				c = data.charCodeAt(i++);
				if (c < 32 || c > 127) {
					if (c > 0xFFFF) c = 0xFFFF;
					rtn[inx++] = 0x5C;
					rtn[inx++] = 0x75;
					t = ((c & 0xF000) >> 12) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					t = ((c & 0xF00) >> 8) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					t = ((c & 0xF0) >> 4) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					t = (c & 15) + 0x30;
					if (t > 0x39) t += 7;
					rtn[inx++] = t;
					continue;
				} else if (c == 0x22 || c == 0x5C) {
					rtn[inx++] = 0x5C;
					rtn[inx++] = c;
					continue;
				}
				rtn[inx++] = c;
			}
			rtn[inx++] = 0x22;
			if (colon) rtn[inx++] = 0x3A;
			rtn.position = inx;
		}
		private static function handleString(data:String, e:int):String {
			var rtn:ByteArray = strArr, inx:int, t:int, a:int = i;
			var iN:Boolean, c:int, end:int = data.charCodeAt(i), p:int;
			rtn.length = e;
			while (a != e) {
				c = data.charCodeAt(++a);
				if (c == 0x5C) {
					c = data.charCodeAt(++a);
					t = 0;
					switch (c) {
					case 0x72:
						c = 13;
						break;
					case 0x6E:
						c = 10;
						break;
					case 0x74:
						c = 9;
						break;
					case 0x66:
						c = 12;
						break;
					case 0x62:
						c = 8;
						break;
					case 0x75:
						p = data.charCodeAt(++a) - 0x30;
						if (p > 9) {
							p -= 7;
							if (p > 15) {
								p -= 0x20;
							}
						}
						if (p < 0 || p > 15) {
							error(data, a, "Expected 0-F");
						}
						t = p << 4;
					case 0x30:case 0x31:case 0x32:case 0x33:
					case 0x34:case 0x35:case 0x36:case 0x37:
						if (c == 0x75) {
							p = data.charCodeAt(++a) - 0x30;
						} else {
							t = (c == 0x30 ? data.charCodeAt(++a) : c) - 0x30;
							if (t > 7) {
								if (c != 0x30) {
									break;
								}
								c = 0;
								--a;
								break;
							}
							p = data.charCodeAt(++a) - 0x30;
							if (p > 7) {
								--a;
								if (c != 0x30) {
									break;
								}
								c = 0;
								--a;
								break;
							}
							c = (t << 3) | p;
							break;
						}
						if (p > 9) {
							p -= 7;
							if (p > 15) {
								p -= 0x20;
							}
						}
						if (p < 0 || p > 15) {
							error(data, a, "Expected 0-F");
						}
						t = (t | p) << 4;
					case 0x78:
						p = data.charCodeAt(++a) - 0x30;
						if (p > 9) {
							p -= 7;
							if (p > 15) {
								p -= 0x20;
							}
						}
						if (p < 0 || p > 15) {
							error(data, a, "Expected 0-F");
						}
						t = (t | p) << 4;
						p = data.charCodeAt(++a) - 0x30;
						if (p > 9) {
							p -= 7;
							if (p > 15) {
								p -= 0x20;
							}
						}
						if (p < 0 || p > 15) {
							error(data, a, "Expected 0-F");
						}
						c = t | p;
						break;
					}
					rtn[inx++] = c;
					continue;
				} else if (c == end) {
					break;
				}
				rtn[inx++] = c;
			}
			i = a;
			rtn.position = 0;
			return rtn.readUTFBytes(inx);
		}
		private static function handleNumber2(data:String, e:int):Number {
			var a:int = i, c:int = data.charCodeAt(a), r:Number = 0, t:int = 1;
			var n:Boolean;
			if (isSpace(c)) {
				do {
					c = data.charCodeAt(++a);
				} while (isSpace(c) && i != e);
			}
			if (c == 0x2D) {
				c = data.charCodeAt(++a);
				n = true;
			} else if (c == 0x2B) {
				c = data.charCodeAt(++a);
			}
			if (isNumeric(c)) {
				r = c - 0x30;
				while (a != e) {
					c = data.charCodeAt(++a);
					if (isNumeric(c)) {
						r = (r * 10) + (c - 0x30);
					}
				}
			}
			if (c == 0x2E) {
				while (a != e) {
					c = data.charCodeAt(++a);
					if (isNumeric(c)) {
						r += (c - 0x30) / (t *= 10);
					}
				}
			}
			if (a != e) {
				if (isSpace(c)) {
					do {
						c = data.charCodeAt(++i);
					} while (isSpace(c) && a < e);
				}
				if (a != e) {
					error(data, a, "Expected 0-9 or .");
				}
			}
			return n ? r * -1.0 : r;
		}
		private static function handleNumber(data:String, e:int):Number {
			var a:int = i, c:int = data.charCodeAt(a), r:Number = 0, t:int = 1;
			var n:Boolean;
			if (isSpace(c)) {
				do {
					c = data.charCodeAt(++a);
				} while (isSpace(c));
			}
			if (c == 0x2D) {
				c = data.charCodeAt(++a);
				n = true;
			} else if (c == 0x2B) {
				c = data.charCodeAt(++a);
			}
			if (isNumeric(c)) {
				r = c - 0x30;
				while (a != e) {
					c = data.charCodeAt(++a);
					if (isNumeric(c)) {
						r = (r * 10) + (c - 0x30);
						continue;
					} else if (isSpace(c) || c == 0x2C || c == 0x5D || c == 0x7D) {
						i = a - 1;
						return n ? r * -1.0 : r;
					}
					break;
				}
			}
			if (c == 0x2E) {
				while (a != e) {
					c = data.charCodeAt(++a);
					if (isNumeric(c)) {
						r += (c - 0x30) / (t *= 10);
						continue;
					} else if (isSpace(c) || c == 0x2C || c == 0x5D || c == 0x7D) {
						i = a - 1;
						return n ? r * -1.0 : r;
					}
					break;
				}
			}
			error(data, a, "Expected 0-9 or .");
			return NaN;
		}
		private static function handleLit(data:String, e:int):* {
			var a:int = data.charCodeAt(i++) | 0x20, b:int = data.charCodeAt(i++) | 0x20;
			var c:int = data.charCodeAt(i++) | 0x20, d:int = data.charCodeAt(i) | 0x20;
			if (a == 0x6E) {
				if (b == 0x75) {
					if (c == 0x6C) {
						if (d == 0x6C) {
							return null;
						}
					}
				}
			} else if (a == 0x74) {
				if (b == 0x72) {
					if (c == 0x75) {
						if (d == 0x65) {
							return true
						}
					}
				}
			} else if (a == 0x66) {
				if (b == 0x61) {
					if (c == 0x6C) {
						if (d == 0x73) {
							if ((data.charCodeAt(++i) | 0x20) == 0x65) {
								return false;
							}
							--i;
						}
					}
				}
			}
			error(data, i-3, "Expected true, false or null.");
		}
		private static function handleArray(data:String, e:int):Array {
			var rtn:Array = preArrs.pop(), c:int, inx:int, p:Boolean = true;
			while (i != e) {
				c = data.charCodeAt(++i);
				if (isSpace(c)) {
					continue;
				} else if (c == 0x5D) {
					break;
				} else if (p) {
					p = false;
					if (isObject(c)) {
						rtn[inx++] = handleObject(data, e);
						continue;
					} else if (isArray(c)) {
						rtn[inx++] = handleArray(data, e);
						continue;
					} else if (isString(c)) {
						rtn[inx++] = handleString(data, e);
						continue;
					} else if (isNumber(c)) {
						rtn[inx++] = handleNumber(data, e);
						continue;
					} else if (isLit(c)) {
						rtn[inx++] = handleLit(data, e);
						continue;
					}
					error(data, i);
				} else if (c == 0x2C) {
					p = true;
					continue;
				}
				error(data, i, "Expected , or ]");
			}
			rtn.length = inx;
			return rtn;
		}
		private static function handleObject(data:String, e:int):Object {
			var rtn:Object = preObjs.pop(), c:int, inx:String, p:Boolean = true;
			while (i != e) {
				c = data.charCodeAt(++i);
				if (isSpace(c)) {
					continue;
				} else if (c == 0x7D) {
					break;
				} else if (p) {
					p = false;
					if (isString(c)) {
						inx = handleString(data, e);
					} else {
						// handle number?
						error(data, i, "Expected \" or '");
					}
					c = data.charCodeAt(++i);
					if (isSpace(c)) {
						do {
							c = data.charCodeAt(++i);
						} while (isSpace(c) && i != e);
					}
					if (c == 0x3A) {
						c = data.charCodeAt(++i);
						if (isSpace(c)) {
							do {
								c = data.charCodeAt(++i);
							} while (isSpace(c) && i != e);
						}
						if (isString(c)) {
							rtn[inx] = handleString(data, e);
							continue;
						} else if (isNumber(c)) {
							rtn[inx] = handleNumber(data, e);
							continue;
						} else if (isArray(c)) {
							rtn[inx] = handleArray(data, e);
							continue;
						} else  if (isLit(c)) {
							rtn[inx] = handleLit(data, e);
							continue;
						} else if (isObject(c)) {
							rtn[inx] = handleObject(data, e);
							continue;
						}
						error(data, i);
					}
					error(data, i, "Expected :");
				} else if (c == 0x2C) {
					p = true;
					continue;
				}
				error(data, i, "Expected , or }");
			}
			return rtn;
		}
		private static function error(data:String, i:int, e:String = null):void {
			throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + (e ? ". " + e : '.'));
		}
	}
}
