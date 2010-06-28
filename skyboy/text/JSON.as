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
	 * files (the "Software"), to deal in the Software without
	 * restriction, including without limitation the rights to use,
	 * copy, modify, merge, publish, distribute, sublicense, and/or sell
	 * copies of the Software, and to permit persons to whom the
	 * Software is furnished to do so, subject to the following
	 * conditions:
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
			throw new Error("There are no instance methods, please use the static methods.");
		}
		public static function isSpace(i:int):Boolean {
			return i == 0x20 || i == 0xA0 || i == 0x09 || i == 0x0B;
		}
		public static function isString(i:int):Boolean {
			return i == 0x22 || i == 0x27;
		}
		public static function isObject(i:int):Boolean {
			return i == 0x7B;
		}
		public static function isArray(i:int):Boolean {
			return i == 0x5B;
		}
		public static function isNumber(i:int):Boolean {
			return i == 0x2D || i == 0x2E || isNumeric(i) || i == 0x2B;
		}
		public static function isNumeric(i:int):Boolean {
			return i > 0x2F && i < 0x3A;
		}
		public static function isLit(i:int):Boolean {
			return i == 0x54 || i == 0x74 || i == 0x46 || i == 0x66 || i == 0x4e || i == 0x6e;
		}
		public static function decode(data:String):* {
			try{
			if (data == null) {
				return null;
			}
			i = 0;
			var c:int;
			var e:int = int(data.length);
			var esc:int = 0x5c;
			while (i != e) {
				c = data.charCodeAt(i);
				if (isSpace(c)) {
					++i;
					continue;
				}
				if (isObject(c)) {
					return handleObject(data, e);
				}
				if (isArray(c)) {
					return handleArray(data, e);
				}
				if (isString(c)) {
					return handleString(data, e);
				}
				if (isNumber(c)) {
					return handleNumber2(data, e);
				}
				if (isLit(c)) {
					return handleLit(data, e);
				}
				throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
			}
			return null;
			}catch (e:Error) {
				trace("Error: Stopped at " + i + ", " + data.charAt(i) + " of " + data.length + ". Because:\n" + e.name + " #" + e.errorID + ": " + e.message + "\n\n" + e.getStackTrace());
			}
		}
		private static var i:int;
		private static function handleString(data:String, e:int):String {
			var rtn:Array = new Array(e - i - 1), inx:int = 0, t:int;
			var iN:Boolean = false, c:int = 0, end:int = data.charCodeAt(i);
			while (i != e) {
				c = data.charCodeAt(++i);
				if (iN) {
					iN = false;
					t = 0;
					switch (c) {
					case 0x72:
						c = 13
						break;
					case 0x6E:
						c = 10
						break;
					case 0x74:
						c = 9
						break;
					case 0x75:
						c = data.charCodeAt(++i) - 0x30;
						if (c > 9) {
							c -= 7;
							if ((c | 15) != 15) {
								c -= 0x20;
							}
						}
						if (c < 0 ||(c | 15) != 15) {
							throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
						}
						t = c << 4;
						c = data.charCodeAt(++i) - 0x30;
						if (c > 9) {
							c -= 7;
							if ((c | 15) != 15) {
								c -= 0x20;
							}
						}
						if (c < 0 || (c | 15) != 15) {
							throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
						}
						t = (t | c) << 4;
					case 0x78:
						c = data.charCodeAt(++i) - 0x30;
						if (c > 9) {
							c -= 7;
							if ((c | 15) != 15) {
								c -= 0x20;
							}
						}if (c < 0 || (c | 15) != 15) {
							throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
						}
						t = (t | c) << 4;
						c = data.charCodeAt(++i) - 0x30;
						if (c > 9) {
							c -= 7;
							if ((c | 15) != 15) {
								c -= 0x20;
							}
						}
						if (c < 0 || (c | 15) != 15) {
							throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
						}
						c = t | c;
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
			return inx?String.fromCharCode.apply(null, rtn):"";
		}
		private static function handleNumber2(data:String, e:int):Number {
			// TODO: parse with own code, throw error when not a number
			return Number(data);
		}
		private static function handleNumber(data:String, e:int):Number {
			var c:int = data.charCodeAt(i), n:Boolean = false, t:int = 10;
			var r:Number, p:Boolean = true;
			if (c == 0x2D) {
				c = data.charCodeAt(++i);
				n = true;
			} else if (c == 0x2B) {
				c = data.charCodeAt(++i);
			}
			if (isNumeric(c)) {
				r = c - 0x30;
				while (i != e) {
					c = data.charCodeAt(++i);
					if (p && isNumeric(c)) {
						r = (r * 10) + (c - 0x30);
					} else if (isSpace(c)) {
						p = false;
					} else if (c == 0x2C || c == 0x5D || c == 0x7D) {
						--i;
						return r;
					} else {
						break;
					}
				}
			}
			if (p && c == 0x2E) {
				while (i != e) {
					c = data.charCodeAt(++i);
					if (p && isNumeric(c)) {
						r += (c - 0x30) / t;
						t *= 10;
					} else if (isSpace(c)) {
						p = false;
					} else if (c == 0x2C || c == 0x5D || c == 0x7D) {
						--i;
						return r;
					} else {
						break;
					}
				}
			}
			throw new Error("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected 0-9 or .");
		}
		private static function handleLit(data:String, e:int):* {
			var a:int = data.charCodeAt(i++), b:int = data.charCodeAt(i++);
			var c:int = data.charCodeAt(i++), d:int = data.charCodeAt(i);
			if (a == 0x6E || a == 0x4E) {
				if (b == 0x75 || b == 0x55) {
					if (c == 0x6C || c == 0x4C) {
						if (d == 0x6C || d == 0x4C) {
							return null;
						}
					}
				}
			} else if (a == 0x74 || a == 0x54) {
				if (b == 0x72 || b == 0x52) {
					if (c == 0x75 || c == 0x55) {
						if (d == 0x65 || d == 0x45) {
							return true
						}
					}
				}
			} else if (a == 0x66 || a == 0x46) {
				if (b == 0x61 || b == 0x41) {
					if (c == 0x6C || c == 0x4C) {
						if (d == 0x73 || d == 0x53) {
							if ((d = data.charCodeAt(++i)) == 0x65 || d == 0x45) {
								return false;
							}
							--i;
						}
					}
				}
			}
			throw new Error ("Malformed JSON at char: " + (i -= 4) + ", " + data.charAt(i) + ".");
		}
		private static function handleArray(data:String, e:int):Array {
			var rtn:Array = [], c:int, p:Boolean = true;
			while (i != e) {
				c = data.charCodeAt(++i);
				if (c == 0x2C) {
					p = true;
				} else if (isSpace(c)) {
					continue;
				} else if (c == 0x5D) {
					break;
				} else if (p) {
					if (isObject(c)) {
						rtn.push(handleObject(data, e));
						p = false;
					} else if (isArray(c)) {
						rtn.push(handleArray(data, e));
						p = false;
					} else if (isString(c)) {
						rtn.push(handleString(data, e));
						p = false;
					} else if (isNumber(c)) {
						rtn.push(handleNumber(data, e));
						p = false;
					} else if (isLit(c)) {
						rtn.push(handleLit(data, e));
						p = false;
					} else {
						throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
					}
				} else {
					throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected , or ]");
				}
			}
			return rtn;
		}
		private static function handleObject(data:String, e:int):Object {
			var rtn:Object = { }, c:int, p:Boolean = true, s:Boolean = true;
			var inx:String;
			while (i != e) {
				c = data.charCodeAt(++i);
				if (c == 0x2C) {
					p = true;
				} else if (isSpace(c)) {
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
					do {
						c = data.charCodeAt(++i);
					} while(isSpace(c));
					if (c == 0x3A) {
						c = data.charCodeAt(++i);
						if (isObject(c)) {
							rtn[inx] = handleObject(data, e);
							p = false;
						} else if (isArray(c)) {
							rtn[inx] = handleArray(data, e);
							p = false;
						} else if (isString(c)) {
							rtn[inx] = handleString(data, e);
							p = false;
						} else if (isNumber(c)) {
							rtn[inx] = handleNumber(data, e);
							p = false;
						} else if (isLit(c)) {
							rtn[inx] = handleLit(data, e);
							p = false;
						} else {
							throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ".");
						}
					} else {
						throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected :");
					}
				} else {
					throw new Error ("Malformed JSON at char: " + i + ", " + data.charAt(i) + ". Expected , or }");
				}
			}
			return rtn;
		}
	}
}
