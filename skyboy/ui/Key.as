package skyboy.ui {
	/**
	 * Key by skyboy. October 23rd 2010.
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
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author skyboy
	 */
	public class Key {
		/**
		 * Private constants
		**/
		private static const KeyMap:Object = { 91:"Left Windows Key", 92:"Right Windows Key", 93:"Menu Key", 9:"Tab", 16:"Shift", 33:"Page up", 34:"Page down", 144:"Num Lock",
											   45:"Insert", 36:"Home", 112:"F1", 113:"F2", 114:"F3", 115:"F4", 116:"F5", 117:"F6", 118:"F7", 119:"F8", 120:"F9", 121:"F10",
											   122:"F11", 123:"F12", 27:"Escape", 31:"Enter", 35:"End", 46:"Delete", 17:"Control", 20:"Caps Lock", 8:"Backspace", 44:"Print Screen",
											   145:"Scroll Lock", 19:"Pause", 37:"Left", 38:"Up", 39:"Right", 40:"Down", 18:"Alt", 96:"Num 0", 97:"Num 1", 98:"Num 2", 99:"Num 3",
											   100:"Num 4", 101:"Num 5", 102:"Num 6", 103:"Num 7", 104:"Num 8", 105:"Num 9", 106:"Num *", 107:"Num +", 109:"Num -", 110:"Num .",
											   111:"Num /", 32:"Space", 192:"Tilde", 48:"0", 49:"1", 50:"2", 51:"3", 52:"4", 53:"5", 54:"6", 55:"7", 56:"8", 57:"9", 220:"Slash",
											   65:"A", 66:"B", 67:"C", 68:"D", 69:"E", 70:"F", 71:"G", 72:"H", 73:"I", 74:"J", 75:"K", 76:"L", 77:"M", 78:"N", 79:"O", 80:"P",
											   81:"Q", 82:"R", 83:"S", 84:"T", 85:"U", 86:"V", 87:"W", 88:"X", 89:"Y", 90:"Z", 219:"Left Brace", 221:"Right Brace", 59:"Colon",
											   222:"Apostrophe", 188:"Comma", 190:"Peirod", 191:"Backslash", 187:"Equals", 189:"Hyphen", 13:"Enter", 186:"Semicolon" };
		// a map of key->name. Object is the only struct that lets me declare it inline in a reasonable amount of space
		private static const listenTo:Vector.<DisplayObject> = new Vector.<DisplayObject>(1024 * 1024, true);
		// allow as many objects as is unresonably reasonable, and keep the vector inside a single block of memory
		private static const Keys:Vector.<Boolean> = new Vector.<Boolean>(1024 * 1024, true);
		// faster than Object and Array. one million elements to avoid ever having misses (which throw an error) and it's a single block of memory
		private static var stage:Stage;
		/**
		 * Public constants
		**/
		public static const ALL:DisplayObject = null;
		// helper for the stopListening function ( Key.stopListening(Key.ALL) )
		public static const BACKSPACE:int = 8;
		public static const TAB:int = 9;
		public static const ENTER:int = 13;
		public static const SHIFT:int = 16;
		public static const CONTROL:int = 17;
		public static const ALT:int = 18;
		public static const PAUSE:int = 19;
		public static const CAPS_LOCK:int = 20;
		public static const ESCAPE:int = 27;
		public static const SPACE:int = 32;
		public static const PAGE_UP:int = 33;
		public static const PAGE_DOWN:int = 34;
		public static const END:int = 35;
		public static const HOME:int = 36;
		public static const LEFT:int = 37;
		public static const UP:int = 38;
		public static const RIGHT:int = 39;
		public static const DOWN:int = 40;
		public static const PRINT_SCREEN:int = 44;
		public static const INSERT:int = 45;
		public static const DELETE:int = 46;
		public static const ZERO:int = 48;
		public static const ONE:int = 49;
		public static const TWO:int = 50;
		public static const THREE:int = 51;
		public static const FOUR:int = 52;
		public static const FIVE:int = 53;
		public static const SIX:int = 54;
		public static const SEVEN:int = 55;
		public static const EIGHT:int = 56;
		public static const NINE:int = 57;
		public static const COLON:int = 59;
		public static const A:int = 65;
		public static const B:int = 66;
		public static const C:int = 67;
		public static const D:int = 68;
		public static const E:int = 69;
		public static const F:int = 70;
		public static const G:int = 71;
		public static const H:int = 72;
		public static const I:int = 73;
		public static const J:int = 74;
		public static const K:int = 75;
		public static const L:int = 76;
		public static const M:int = 77;
		public static const N:int = 78;
		public static const O:int = 79;
		public static const P:int = 80;
		public static const Q:int = 81;
		public static const R:int = 82;
		public static const S:int = 83;
		public static const T:int = 84;
		public static const U:int = 85;
		public static const V:int = 86;
		public static const W:int = 87;
		public static const X:int = 88;
		public static const Y:int = 89;
		public static const Z:int = 90;
		public static const LEFT_WINDOWS_KEY:int = 91;
		public static const RIGHT_WINDOWS_KEY:int = 92;
		public static const MENU_KEY:int = 93;
		public static const NUM_0:int = 96;
		public static const NUM_1:int = 97;
		public static const NUM_2:int = 98;
		public static const NUM_3:int = 99;
		public static const NUM_4:int = 100;
		public static const NUM_5:int = 101;
		public static const NUM_6:int = 102;
		public static const NUM_7:int = 103;
		public static const NUM_8:int = 104;
		public static const NUM_9:int = 105;
		public static const NUM_ASTERISK:int = 106;
		public static const NUM_PLUS:int = 107;
		public static const NUM_HYPHON:int = 109;
		public static const NUM_PERIOD:int = 110;
		public static const NUM_BLACKSLASH:int = 111;
		public static const F1:int = 112;
		public static const F2:int = 113;
		public static const F3:int = 114;
		public static const F4:int = 115;
		public static const F5:int = 116;
		public static const F6:int = 117;
		public static const F7:int = 118;
		public static const F8:int = 119;
		public static const F9:int = 120;
		public static const F10:int = 121;
		public static const F11:int = 122;
		public static const F12:int = 123;
		public static const NUM_LOCK:int = 144;
		public static const SCROLL_LOCK:int = 145;
		public static const SEMICOLON:int = 186;
		public static const EQUALS:int = 187;
		public static const COMMA:int = 188;
		public static const HYPHEN:int = 189;
		public static const PEIROD:int = 190;
		public static const BACKSLASH:int = 191;
		public static const TILDE:int = 192;
		public static const LEFT_BRACE:int = 219;
		public static const SLASH:int = 220;
		public static const RIGHT_BRACE:int = 221;
		public static const APOSTROPHE:int = 222;
		/**
		 * Public functions
		**/
		/**
		 * nameForCode
		 * @param	int: code	The keyCode to retrive the name for.
		 * @return	String: 	The name of of the key represented by the keyCode.
		 */
		public static function nameForCode(code:int):String {
			return KeyMap[code];
		}
		/**
		 * isDown
		 * @param	int: code	The keyCode to check if it is down.
		 * @return	Boolean:	true if the key is down, false if not.
		 */
		public static function isDown(code:int):Boolean {
			if (code < 0 || code > 1048575) return false;
			return Keys[code] === true;
			// inital values in vector object are null instead of false
		}
		/**
		 * areDown2
		 * @param	int: code1	First keyCode to check if it is down.
		 * @param	int: code2	Second keyCode to check if it is down.
		 * @return	Boolean:	true if both keys are down, false if not.
		 */
		public static function areDown2(code1:int, code2:int):Boolean {
			if (code1 < 0 || code1 > 1048575 || code2 < 0 || code2 > 1048575) return false;
			return Keys[code1] && Keys[code2];
		}
		/**
		 * areDown
		 * @param	int: code1		First keyCode to check if it is down.
		 * @param	int: code2		Second keyCode to check if it is down.
		 * @param	int: ...codes	Other keyCodes to check if they are down.
		 * @return	Boolean:		true if all keys are down, false if not.
		 */
		public static function areDown(code1:int, code2:int, ...codes):Boolean {
			if (code1 < 0 || code1 > 1048575 || code2 < 0 || code2 > 1048575) return false;
			var ret:Boolean = Keys[code1] && Keys[code2];
			if (ret) {
				for each (var code:int in codes) {
					if (code < 0 || code > 1048575) return false;
					if (!(ret = ret && Keys[code])) return false;
				}
			}
			return ret;
		}
		/**
		 * anyDown
		 * @param	int: code1		First keyCode to check if it is down.
		 * @param	int: ...codes	Other keyCodes to check if they are down.
		 * @return	Boolean:		true if at least one of the keys is down, false if none are.
		 */
		public static function anyDown(code1:int, ...codes):Boolean {
			if (code1 >= 0 && code1 <= 1048575) {
				if (Keys[code1]) return true;
			}
			for each (var code:int in codes) {
				if (code >= 0 && code <= 1048575) {
					if (Keys[code]) return true;
				}
			}
			return false;
		}
		/**
		 * listen
		 * @param	DisplayObject: object	the object to listen for keypresses on.
		 */
		public static function listen(object:DisplayObject):void {
			if (object) {
				if (listenTo.indexOf(object) == -1) {
					// check that it's not null and is not already being listened too
					var b:int = listenTo.indexOf(null);
					// find the first avaiable spot
					if (b == -1) throw new Error("Attempting to listen for key presses on more than the maximum limit of 1,048,576 objects.\nStop listening to some objects before listening to more objects.");
					// throw an error if they somehow manage to use more than a million spots. a million.
					if (!stage) if (object is Stage) {
						stage = Stage(object);
						for each (var a:DisplayObject in listenTo) {
							a && a.removeEventListener(Event.ADDED_TO_STAGE, stageListener);
						}
						gotStage();
					} else {
						if (object.stage) {
							stage = object.stage;
							for each (a in listenTo) {
								a && a.removeEventListener(Event.ADDED_TO_STAGE, stageListener);
							}
							gotStage();
						} else object.addEventListener(Event.ADDED_TO_STAGE, stageListener, false, 15, true);
					}
					// get a reference to the stage to clear the keys when flash loses focus
					listenTo[b] = object;
					// push into the vector
					object.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					object.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					// add key listeners
				}
			} else {
				throw new Error("Can not listen for key presses on null.");
			}
		}
		/**
		 * stopListening
		 * @param	DisplayObject: object	An object passed to listen or Key.ALL that you want to stop listening for.
		 */
		public static function stopListening(object:DisplayObject):void {
			var a:DisplayObject
			// current object
			if (object == null) {
				// if null ( Key.ALL ) then remove all liteners and objects
				for (var i:int = listenTo.length; i > 0 && (a = listenTo[--i]); listenTo[i] = null) {
					a.removeEventListener(Event.ADDED_TO_STAGE, stageListener);
					a.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					a.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				}
				resetKeys();
				// and reset the keys to false
				return;
			}
			var b:int = listenTo.indexOf(object);
			// else get the index of the object
			if (~b) return;
			// ignore if it's not being listened to
			a = listenTo[b];
			a.removeEventListener(Event.ADDED_TO_STAGE, stageListener);
			a.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			a.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			listenTo[b] = null;
			// remove the objects and remove it from the vector
		}
		/**
		 * resetKeys
		 * Reset the pressed keys to all false.
		 */
		public static function resetKeys(...VOID):void {
			for (var i:int = listenTo.length; i-- > 0; ) {
				Keys[i] = false;
			}
			// reset all keys to null
		}
		/**
		 * Private functions
		**/
		private static function onKeyDown(e:KeyboardEvent):void {
			Keys[e.keyCode] = true;
		}
		private static function onKeyUp(e:KeyboardEvent):void {
			Keys[e.keyCode] = false;
		}
		private static function gotStage():void {
			stage.addEventListener(Event.ACTIVATE, resetKeys);
			stage.addEventListener(Event.DEACTIVATE, resetKeys);
			// reset the keys when the stage gains or loses focus
		}
		private static function stageListener(e:Event):void {
			if ((stage = Stage(e.target.stage))) {
				gotStage();
				e.target.removeEventListener(e.type, stageListener);
				for each (var a:DisplayObject in listenTo) {
					a && a.removeEventListener(e.type, stageListener);
				}
			}
			// when an we have a reference to the stage from an object being added, remove all listeners. no other listeners for it will be added to any object
		}
	}
}
