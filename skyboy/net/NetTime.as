package skyboy.net {
	import flash.errors.*;
	import flash.events.*;
	import flash.net.*
	import flash.system.Security;
	import flash.utils.*;
	/**
	 * @author Rivaledsouls
	 * @author skyboy
	 */
	final public class NetTime {
		/**
		 * Public varaibles and constatns
		 */
		public static const TIME_UPDATED:String = "NetTime::Updated";
		/**
		 * Private variables and constants
		 */
		private static const request:URLRequest = new URLRequest("http://www.time.gov/widget/actualtime.cgi?");
		private static var loader:URLLoader = new URLLoader;
		private static const updateInterval:Timer = new Timer(60000);;
		{
			Security.loadPolicyFile("http://www.time.gov/crossdomain.xml");
			loader.addEventListener(Event.COMPLETE, timeLoaded);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, couldntConnect);
			loader.load(request);
			if (Security.sandboxType == Security.REMOTE) {
				updateInterval.addEventListener(TimerEvent.TIMER, onUpdate);
			} else  {
				updateInterval.addEventListener(TimerEvent.TIMER, onUpdateLocal);
			}
			updateInterval.start();
		}
		private static const dispatcher:EventDispatcher = new EventDispatcher;
		private static var date:Number = new Date().getTime();
		private static var lms:Number = 0;
		/**
		 * Public methods
		 */
		/**
		 * getDate
		 * @return Date: A Date object representing the current time.
		 */
		public static function getDate():Date {
			return new Date((getTimer() - lms) + date);
		}
		/**
		 * getTime
		 * @return Number: A Number representing the current time in milliseconds.
		 */
		public static function getTime():Number {
			return Math.floor((getTimer() - lms) + date);
		}
		/**
		 * getLastResult
		 * @return Number: The last time result retrived from the server, in milliseconds.
		 */
		public static function getLastResult():Number {
			return date;
		}
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public static function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		public static function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		/**
		 * Private methods
		 */
		private static function onUpdate(e:TimerEvent):void {
			loader.load(request);
		}
		private static function onUpdateLocal(e:TimerEvent):void {
			request.url += "?1";
			loader = new URLLoader;
			loader.addEventListener(Event.COMPLETE, timeLoaded);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, couldntConnect);
			loader.load(request);
		}
		private static function timeLoaded(e:Event):void {
			var result:String = loader.data;
			var leftIndex:int = result.indexOf(' time="') + 7;
			var rightIndex:int = result.indexOf('"', leftIndex);
			if (leftIndex < 0 || rightIndex < 0)
				throw new Error("NetTime: Invalid result received from Server");
			lms = getTimer();
			date = Number(result.substring(leftIndex, rightIndex)) * 0.001;
			if (dispatcher.willTrigger(TIME_UPDATED)) dispatcher.dispatchEvent(new Event(TIME_UPDATED));
		}
		private static function httpStatus(e:HTTPStatusEvent):void {
			if (e.status == 404) {
				throw new Error("NetTime: Couldn't connect to time server", 404);
			}
		}
		private static function couldntConnect(e:IOErrorEvent):void {
			throw new IOError("NetTime: " + e.text, e.errorID);
		}
		/**
		 * Dummy constructor
		 */
		public function NetTime():void {
			throw new IllegalOperationError("NetTime: Illegal Operation. NetTime has only static methods.");
		}
	}
}
