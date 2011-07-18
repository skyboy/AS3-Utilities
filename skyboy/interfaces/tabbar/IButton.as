package skyboy.interfaces.tabbar {
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author skyboy
	 */
	public interface IButton {
		function get x():Number;
		function set x(x:Number):void;
		function get y():Number;
		function set y(y:Number):void;
		function get width():Number;
		function set height(y:Number):void;
		function get height():Number;
		function disable():void;
		function enable():void;
		function enabled():Boolean;
	}
}
