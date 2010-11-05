package skyboy.text {
	import flash.utils.getQualifiedClassName;
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
		private static const strArr:Array = new Array();
		private static const qRepl:RegExp = /"|\\/g;
		public static function decode(data:String):* {
			if (data == null) {
				return null;
			}
			data = data.valueOf();
			var temp:int, objs:int;
			var e:int = data.length;
			if (e == 0) return null;
			while ((temp = data.indexOf("}", temp + 1)) !== -1) ++objs;
			preObjs.length = objs;
			while (objs-- > 0) preObjs[objs] = new Object;
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
			if (isObject(c)) {
				return handleObject(data, e);
			} else if (isArray(c)) {
				return handleArray(data, e);
			} else if (isString(c)) {
				return handleString(data, e);
			} else if (isNumber(c)) {
				return handleNumber2(data, e);
			} else if (isLit(c)) {
				return handleLit(data, e);
			}
			error(data, i);
		}
		public static function encode(data:*, advStringH:Boolean = true):String {
			var ret:String = "";
			if (data === null || data === undefined || data is Function) return "null";
			if (data is String) {
				return '"' + (advStringH ? handleStringE(data) : data.replace(qRepl, '\\$&')) + '"';
			} else if (data is Number) {
				if (data != data || data == Infinity || data == -Infinity) return "0";
				return data.toString(10);
			} else if (data is Boolean) {
				return data.toString();
			} else if (data is Date) {
				return data.getTime();
			} else if (data is Array || getQualifiedClassName(data).indexOf("AS3.vec:") === 0) {
				for each(var i:* in data) {
					ret += encode(i) + ",";
				}
				return "[" + ret.substr(0, -1) + "]";
			} else if (data is Object) {
				for (var b:* in data) {
					if (b is String || b is Number) {
						ret += '"' + (advStringH ? handleStringE(b) : b.replace(qRepl, '\\$&')) + '":' + encode(data[b]) + ",";
					}
				}
				return "{" + ret.substr(0, -1) + "}";
			}
			return "null";
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
		private static function handleStringE(data:String):String {
			var rtn:Array = strArr, inx:int, c:int, i:int;
			var e:int = data.length, t:int;
			if (e == 0) return "";
			rtn.length = min(e * 5, String.length);
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
			return ((rtn.length = inx), String.fromCharCode.apply(0, rtn));
		}
		private static function handleString(data:String, e:int):String {
			var rtn:Array = strArr, inx:int, t:int, a:int = i;
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
			return inx ? ((rtn.length = inx), String.fromCharCode.apply(0, rtn)) : "";
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
			error(data, i, "Expected true, false or null.");
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
