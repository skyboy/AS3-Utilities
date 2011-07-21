package skyboy.interfaces.tabbar {
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author skyboy
	 */
	public interface ITab {
		function get x():Number;
		function set x(x:Number):void;
		function get y():Number;
		function set y(y:Number):void;
		function get width():Number;
		function set lastTab(y:ITab):void;
		function get lastTab():ITab; // a public var satisfies getter + setter requirements
		function select():void;
		function deselect():void;
		function close():void;
		function closed():Boolean;
		function closeable():Boolean;
		function pointCloses(x:Number, y:Number):Boolean;
	}
}
