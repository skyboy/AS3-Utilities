package skyboy.serialization {
	/**
	 * Base64Helper by skyboy. June 29th 2011.
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
	/**
	 * ...
	 * @author skyboy
	 */
	public class Base64Helper {
		static internal const Base64Std:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47,61];
		static internal const Base64FileName:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,45,61];
		static internal const Base64URL:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,45,95,61];
		static internal const Base64XMLTok:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,46,45,61];
		static internal const Base64XMLIdn:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,95,58,61];
		static internal const Base64ProgID1:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,95,45,61];
		static internal const Base64ProgID2:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,46,95,61];
		static internal const Base64RegExp:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,33,45,61];
		//static internal const Base64Std:Vector.<uint> = new <uint>[65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47,61];
		
		static internal const Base64Stdr:Vector.<uint> = new Vector.<uint>(256, true);
		static internal const Base64FileNamer:Vector.<uint> = new Vector.<uint>(256, true);
		static internal const Base64URLr:Vector.<uint> = new Vector.<uint>(256, true);
		static internal const Base64XMLTokr:Vector.<uint> = new Vector.<uint>(256, true);
		static internal const Base64XMLIdnr:Vector.<uint> = new Vector.<uint>(256, true);
		static internal const Base64ProgID1r:Vector.<uint> = new Vector.<uint>(256, true);
		static internal const Base64ProgID2r:Vector.<uint> = new Vector.<uint>(256, true);
		static internal const Base64RegExpr:Vector.<uint> = new Vector.<uint>(256, true);
		
		private static function init():void {
			var i:uint = 256, c:uint = uint(-1);
			while (i--) {
				Base64Stdr[i] = c;
				Base64FileNamer[i] = c;
				Base64URLr[i] = c;
				Base64XMLTokr[i] = c;
				Base64XMLIdnr[i] = c;
				Base64ProgID1r[i] = c;
				Base64ProgID2r[i] = c;
				Base64RegExpr[i] = c;
			}
			c = 128;
			i = 0x09;
			Base64Stdr[i] = c;
			Base64FileNamer[i] = c;
			Base64URLr[i] = c;
			Base64XMLTokr[i] = c;
			Base64XMLIdnr[i] = c;
			Base64ProgID1r[i] = c;
			Base64ProgID2r[i] = c;
			Base64RegExpr[i] = c;
			i = 0x0A;
			Base64Stdr[i] = c;
			Base64FileNamer[i] = c;
			Base64URLr[i] = c;
			Base64XMLTokr[i] = c;
			Base64XMLIdnr[i] = c;
			Base64ProgID1r[i] = c;
			Base64ProgID2r[i] = c;
			Base64RegExpr[i] = c;
			i = 0x0D;
			Base64Stdr[i] = c;
			Base64FileNamer[i] = c;
			Base64URLr[i] = c;
			Base64XMLTokr[i] = c;
			Base64XMLIdnr[i] = c;
			Base64ProgID1r[i] = c;
			Base64ProgID2r[i] = c;
			Base64RegExpr[i] = c;
			i = 0x20;
			Base64Stdr[i] = c;
			Base64FileNamer[i] = c;
			Base64URLr[i] = c;
			Base64XMLTokr[i] = c;
			Base64XMLIdnr[i] = c;
			Base64ProgID1r[i] = c;
			Base64ProgID2r[i] = c;
			Base64RegExpr[i] = c;
			for (i = 65; i--; ) {
				Base64Stdr[Base64Std[i]] = i;
			}
			for (i = 65; i--; ) {
				Base64FileNamer[Base64FileName[i]] = i;
			}
			for (i = 65; i--; ) {
				Base64URLr[Base64URL[i]] = i;
			}
			for (i = 65; i--; ) {
				Base64XMLTokr[Base64XMLTok[i]] = i;
			}
			for (i = 65; i--; ) {
				Base64XMLIdnr[Base64XMLIdn[i]] = i;
			}
			for (i = 65; i--; ) {
				Base64ProgID1r[Base64ProgID1[i]] = i;
			}
			for (i = 65; i--; ) {
				Base64ProgID2r[Base64ProgID2[i]] = i;
			}
			for (i = 65; i--; ) {
				Base64RegExpr[Base64RegExp[i]] = i;
			}
			Base64Std.fixed = true;
			Base64FileName.fixed = true;
			Base64URL.fixed = true;
			Base64XMLTok.fixed = true;
			Base64XMLIdn.fixed = true;
			Base64ProgID1.fixed = true;
			Base64ProgID2.fixed = true;
			Base64RegExp.fixed = true;
		}
		init();
		
		private static const string:Function = {}.toString;
		static internal function PString(obj:*):String {
			return (obj == null ? (obj === undefined ? "[object void]" : "[object Null]") : string.call(obj));
		}
		
		public static function encode(input:*, options:uint = 0, breakAt:uint = 64):* {
			return encodeBase64(input, options, breakAt);
		}
		public function decode(input:*, options:uint = 0):* {
			return decodeBase64(input, options);
		}
		
		/**
		 * Return types
		 */
		public static const RETURN_STRING:uint =	 	0;
		public static const RETURN_BYTEARRAY:uint = 	1;
		public static const RETURN_INTVECTOR:uint = 	2;
		public static const RETURN_ARRAY:uint = 		3; // two bits (2)
		
		/**
		 * Padding
		 */
		public static const PAD:uint = 					0 << 2;
		public static const NO_PAD:uint = 				1 << 2; // 1 bit (3)
		
		/**
		 * Encoding types
		 */
		public static const STANDARD:uint = 			0 << 3;
		public static const FILE_NAME:uint = 			1 << 3;
		public static const URL:uint = 					2 << 3;
		public static const XML_TOKEN:uint = 			3 << 3;
		public static const XML_IDENTIFIER:uint = 		4 << 3;
		public static const PROGRAM_IDENTIFIER_1:uint = 5 << 3;
		public static const PROGRAM_IDENTIFIER_2:uint = 6 << 3;
		public static const REGULAR_EXPRESSION:uint = 	7 << 3;
		//public static const name:uint = val;
		//public static const CUSTOM_ENCODING:uint =	15 << 3; // 4 bits (7)
		
		/**
		 * New line options
		 */
		public static const BREAK_AT_64:uint = 			0 << 7;
		public static const BREAK_AT_VAL:uint = 		1 << 7;
		public static const NO_BREAK:uint = 			2 << 7;
		public static const BREAK_AT_76:uint = 			3 << 7; // two bits (9)
		
		/**
		 * Validation options
		 */
		public static const ERROR_ON_UNKNOWN:uint = 	0 << 9;
		public static const IGNORE_UNKNOWN:uint = 		1 << 9; // 1 bit (10)
		
		public static const IGNORE_WHITESPACE:uint = 	0 << 10;
		public static const ERROR_ON_WHITESPACE:uint = 	1 << 10; // 1 bit (11)
		
		public static const NO_CHECKSUM:uint = 			0 << 11;
		public static const CRC18_CHECKSUM:uint =		1 << 11; // 1 bit so far.
	}
}
