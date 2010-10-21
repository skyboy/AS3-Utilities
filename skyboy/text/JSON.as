package skyboy.text {
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
		private static function isSpace(i:int):Boolean {
			return i == 0x20 || i == 0xA0 || i == 0x09 || i == 0x0B;
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
			return i == 0x2D || i == 0x2E || isNumeric(i) || i == 0x2B;
		}
		private static function isNumeric(i:int):Boolean {
			return i > 0x2F && i < 0x3A;
		}
		private static function isLit(i:int):Boolean {
			i |= 0x20;
			return i == 0x74 || i == 0x66 || i == 0x6E;
		}
		private static function reset():void {
			preObjs.length = i = 0;
		}
		private static const preObjs:Vector.<Object> = new Vector.<Object>();
		public static function decode(data:String):* {
			if (data == null) {
				return null;
			}
			reset();
			var e:int = data.length, c:int;
			//if (e > 20000) trace("It is recommended that you do not attempt to parse more than twenty thousand characters inline.  Use the class constructor instead.");
			var temp:int, objs:int;
			while (~(temp = data.indexOf("}", temp + 1))) ++objs;
			preObjs.length = objs;
			while (objs--) preObjs[objs] = new Object;
			while (i != e) {
				c = data.charCodeAt(i);
				switch(true) {
				case isSpace(c):
					++i;
					break;
				case isObject(c):
					return handleObject(data, e);
				case isArray(c):
					return handleArray(data, e);
				case isString(c):
					return handleString(data, e);
				case isNumber(c):
					return handleNumber2(data, e);
				case isLit(c):
					return handleLit(data, e);
				default:
					throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
				}
			}
			return null;
		}
		public static function get index():int {
			return i;
		}
		private static var i:int, strArr:Array = new Array();
		private static function handleString(data:String, e:int):String {
			var rtn:Array = strArr, inx:int, t:int, a:int = i;
			var iN:Boolean = false, c:int, end:int = data.charCodeAt(i), p:int;
			rtn.length = 0;
			rtn.length = e - a;
			while (a != e) {
				c = data.charCodeAt(++a);
				if (iN) {
					iN = false;
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
							throw new Error("Malformed JSON at char: " + a + ", " + data.charAt(a) + ".");
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
							throw new Error("Malformed JSON at char: " + a + ", " + data.charAt(a) + ".");
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
							throw new Error("Malformed JSON at char: " + a + ", " + data.charAt(a) + ".");
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
							throw new Error("Malformed JSON at char: " + a + ", " + data.charAt(a) + ".");
						}
						c = t | p;
						break;
					}
				} else if (c == 0x5c) {
					iN = true;
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
			var a:int = i, c:int = data.charCodeAt(a), n:Boolean = false, t:int = 10;
			var r:Number = 0, p:Boolean = true;
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
					} else if (isSpace(c)) {
						p = false;
						break;
					} else {
						break;
					}
				}
			}
			if (p && c == 0x2E) {
				while (a != e) {
					c = data.charCodeAt(++a);
					if (isNumeric(c)) {
						r += (c - 0x30) / t;
						t *= 10;
					} else {
						break;
					}
				}
			}
			breaker: if (a != e) {
				if (isSpace(c)) {
					do {
						c = data.charCodeAt(++i);
					} while (isSpace(c) && a < e);
				}
				if (a != e) {
					throw new Error("Malformed JSON at char: " + a + ", " + data.charAt(a) + ". Expected 0-9" + (p ? '' : "or ."));
				}
			}
			return r;
		}
		private static function handleNumber(data:String, e:int):Number {
			var a:int = i, c:int = data.charCodeAt(a), n:Boolean = false, t:int = 10;
			var r:Number = 0, p:Boolean = true;
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
					} else if (isSpace(c)) {
						p = false;
						break;
					} else if (c == 0x2C || c == 0x5D || c == 0x7D) {
						--a;
						i = a;
						return r;
					} else {
						break;
					}
				}
			}
			if (p && c == 0x2E) {
				while (a != e) {
					c = data.charCodeAt(++a);
					if (isNumeric(c)) {
						r += (c - 0x30) / t;
						t *= 10;
					} else if (c == 0x2C || c == 0x5D || c == 0x7D) {
						--a;
						i = a;
						return r;
					} else {
						break;
					}
				}
			}
			throw new Error("Malformed JSON at char: " + a + ", " + data.charAt(a) + ". Expected 0-9" + (p ? '' : "or ."));
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
			throw new Error ("Malformed JSON at char: " + (i -= 4) + ", " + data.charAt(i) + ". Expected literal value.");
		}
		private static function handleArray(data:String, e:int):Array {
			var rtn:Array = new Array(int((e - i) / 2)), c:int, p:Boolean = true;
			var inx:int;
			while (i != e) {
				c = data.charCodeAt(++i);
				if (isSpace(c)) {
					do {
						c = data.charCodeAt(++i);
					} while (isSpace(c));
				}
				if (c == 0x5D) {
					break;
				} else if (p) {
					if (isObject(c)) {
						rtn[inx] = (handleObject(data, e));
						p = false;
					} else if (isArray(c)) {
						rtn[inx] = (handleArray(data, e));
						p = false;
					} else if (isString(c)) {
						rtn[inx] = (handleString(data, e));
						p = false;
					} else if (isNumber(c)) {
						rtn[inx] = (handleNumber(data, e));
						p = false;
					} else if (isLit(c)) {
						rtn[inx] = (handleLit(data, e));
						p = false;
					} else {
						throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
					}
					++inx;
				} else if (c == 0x2C) {
					p = true;
				} else {
					throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected , or ]");
				}
			}
			rtn.length = inx;
			return rtn;
		}
		private static function handleObject(data:String, e:int):Object {
			var rtn:Object = preObjs.pop(), c:int, p:Boolean = true, s:Boolean = true;
			var inx:String;
			while (i != e) {
				c = data.charCodeAt(++i);
				if (isSpace(c)) {
					continue;
				} else if (c == 0x7D) {
					break;
				} else if (p) {
					if (isString(c)) {
						inx = handleString(data, e);
					} else {
						// handle number?
						throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected \" or '");
					}
					c = data.charCodeAt(++i);
					if (isSpace(c)) {
						do {
							c = data.charCodeAt(++i);
						} while (isSpace(c));
					}
					if (c == 0x3A) {
						c = data.charCodeAt(++i);
						if (isSpace(c)) {
							do {
								c = data.charCodeAt(++i);
							} while (isSpace(c));
						}
						if (isString(c)) {
							rtn[inx] = handleString(data, e);
							p = false;
						} else if (isNumber(c)) {
							rtn[inx] = handleNumber(data, e);
							p = false;
						} else if (isArray(c)) {
							rtn[inx] = handleArray(data, e);
							p = false;
						} else  if (isLit(c)) {
							rtn[inx] = handleLit(data, e);
							p = false;
						} else if (isObject(c)) {
							rtn[inx] = handleObject(data, e);
							p = false;
						} else{
							throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
						}
					} else {
						throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected :");
					}
				} else if (c == 0x2C) {
					p = true;
				} else {
					throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected , or }");
				}
			}
			return rtn;
		}
	}
}
