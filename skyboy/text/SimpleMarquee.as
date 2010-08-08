package skyboy.text {
	/**
	 * SimpleMarquee by skyboy. August 5th 2010.
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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author skyboy
	 */
	public class SimpleMarquee extends Sprite {
		public static const CHARACTER:String = "CHARACTER";
		public static const PIXEL:String = "PIXEL";
		public static const FRAME_MODE:String = "FRAME";
		public static const TIMER_MODE:String = "TIMER";
		
		private var delay:uint, amount:Number, pos:uint;
		private var _text:String = '  ', field:TextField;
		private var timer:Timer, stopped:Boolean = false;
		private var _tick:Function, tick:Function;
		
		public function SimpleMarquee(scrollDelay:uint = 3, scrollType:String = "CHARACTER", scrollAmount:Number = 1, scrollMode:String = "FRAME") {
			addChild(field = new TextField());
			_tick = new Function();
			amount = scrollAmount || 1;
			delay = scrollDelay;
			scrollRect = new Rectangle(0, 0, field.width, field.height);
			if (scrollType == CHARACTER) {
				tick = function():void { text = _text.substr(this.amount) + _text.substr(0, this.amount) };
			} else if (scrollType == PIXEL) {
				field.width += 150;
				tick = function():void { var x:Number = field.x -= this.amount, i:int; var a:Function = field.getCharBoundaries, b:Rectangle = a(0), c:Number = b.width; while (++i, x + c < -this.amount) { x += c; this._text = this._text.substr(1) + this._text.charAt(0); c = (( a(0 + i)).width); }; field.text = _text; field.x = x; };
			} else {
				throw new Error("Invalid scroll type <" + scrollType + ">");
			}
			if (scrollMode == FRAME_MODE) {
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				delay ||= 1;
			} else if (scrollMode == TIMER_MODE) {
				timer = new Timer(scrollDelay);
				timer.addEventListener(TimerEvent.TIMER, onTick);
				timer.start();
			} else {
				throw new Error("Invalid scroll mode <" + scrollMode + ">");
			}
		}
		
		private function onEnterFrame(e:Event):void {
			if ((pos = ((pos + 1) % delay)) == 0) {
				tick();
			}
		}
		private function onTick(e:TimerEvent):void {
			tick();
		}
		
		public function stop():void {
			if (!stopped) {
				var a:Function = _tick;
				_tick = tick; tick = a;
			}
		}
		public function start():void {
			if (stopped) {
				var a:Function = _tick;
				_tick = tick; tick = a;
			}
		}
		override public function get height():Number {
			return super.height;
		}
		override public function set height(w:Number):void {
			field.width = (super.height = scrollRect.height = w) + 150;
		}
		override public function get width():Number {
			return super.width;
		}
		override public function set width(w:Number):void {
			super.width = scrollRect.width = w;
		}
		public function set text(str:String):void {
			field.text = _text =  str;
		}
		public function get text():String {
			return _text;
		}
		public function appendText(newText:String):void {
			_text = _text + newText
			field.appendText(newText);
		}
		public function prependText(newText:String):void {
			field.text = _text = newText + _text;
		}
	}
	
}
