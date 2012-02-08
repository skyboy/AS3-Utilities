package skyboy.components {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.*;
	import skyboy.interfaces.tabbar.*;
	
	/**
	 * ...
	 * @author skyboy
	 */
	public class TabBar extends Sprite {
		protected var leftScrollButton:IButton;
		protected var rightScrollButton:IButton;
		protected var newTabButton:ITabButton;
		protected var tabContainer:DisplayObjectContainer;
		protected var scrollCapture:TextField;
		protected var tabs:Vector.<ITab> = new Vector.<ITab>();
		protected var sRect:Rectangle;
		protected var selectedTab:ITab, hovering:IHover;
		protected var scrollSpeed:Number = 75, scrollStop:Number = 0;
		protected var scrollTimer:Timer = new Timer(20);
		protected var tWidths:Number = 0;
		public override function set scrollRect(a:Rectangle):void {};
		public override function get scrollRect():Rectangle {return new Rectangle};
		public function TabBar(lSB:IButton, rSB:IButton, nTB:ITabButton, tC:DisplayObjectContainer, tab:ITab = null):void {
			tabChildren = false;
			var cap:TextField = scrollCapture = new TextField();
			cap.selectable = false;
			cap.text = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"; // 36
			cap.appendText(cap.text); // 72
			cap.appendText(cap.text); // 144
			cap.scrollV = 72;
			cap.alpha = 0;
			addChild(DisplayObject(leftScrollButton = lSB)).y = 0;
			addChild(tabContainer = tC).y = 0;
			addChild(DisplayObject(newTabButton = nTB)).y = 0;
			addChild(DisplayObject(rightScrollButton = rSB)).y = 0;
			addChild(cap).y = 0;
			sRect = new Rectangle();
			super.scrollRect = new Rectangle();
			var w:Number = lSB.width + rSB.width + nTB.width;
			if (tab) {
				w += tab.width;
			}
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
			cap.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
			addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			scrollTimer.addEventListener(TimerEvent.TIMER, tick);
			if (w != w) w = 150;
			width = w;
			cap.width = w;
			w = Math.max(lSB.height, tC.height, nTB.height, rSB.height)
			if (w != w) w = 20;
			height = w;
			cap.height = w;
			lSB.disable();
			rSB.disable();
			addTab(tab);
		}
		public override function set width(x:Number):void {
			var a:Rectangle = super.scrollRect;
			a.width = x;
			scrollCapture.width = x;
			super.scrollRect = a;
			x -= rightScrollButton.width;
			rightScrollButton.x = x;
			x -= newTabButton.width;
			newTabButton.x = x;
			x -= leftScrollButton.width;
			tabContainer.x = leftScrollButton.width;
			sRect.width = x;
			tabContainer.scrollRect = sRect;
			if (selectedTab) if (sRect.x + x < selectedTab.x + selectedTab.width) scrollBy((selectedTab.x + selectedTab.width) - (sRect.x + x));
		}
		public override function set height(y:Number):void {
			leftScrollButton.height = y;
			sRect.height = y;
			newTabButton.height = y;
			rightScrollButton.height = y;
			scrollCapture.height = y;
			tabContainer.scrollRect = sRect;
			var a:Rectangle = super.scrollRect;
			a.height = y;
			super.scrollRect = a;
		}
		protected function onMove(e:MouseEvent):void {
			var items:Array = getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			var len:int = items.length - 1;
			if (len < 1) return;
			var over:IHover;
			while (!over && len--) over = items[len] as IHover;
			if (hovering) hovering.hover(false);
			if (over) over.hover(true);
			hovering = over;
		}
		protected function onScroll(e:MouseEvent):void {
			var s:int = -e.delta;
			e.preventDefault();
			e.stopPropagation();
			e.stopImmediatePropagation();
			scrollCapture.scrollV = 72;
			var end:Number = sRect.x + (scrollSpeed * s);
			if (s > 0) end += sRect.width;
			scrollTo(end);
		}
		protected function onClick(e:MouseEvent):void {
			var items:Array = getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			var len:int = items.length - 1;
			if (len < 1) return;
			var button:IButton = items[0] as IButton;
			var tab:ITab;
			if (button) {
				if (button.enabled()) {
					if (button is ITabButton) {
						tab = (button as ITabButton).newTab();
						addTab(tab);
					} else {
						if (button.x == 0) {
							scrollBy(-scrollSpeed);
						} else {
							scrollBy(scrollSpeed);
						}
					}
				}
			} else {
				while (!tab && len--) tab = items[len] as ITab;
				if (tab) {
					if (tab.closeable()) {
						if (tab.pointCloses(tabContainer.mouseX, tabContainer.mouseY)) {
							removeTab(tab);
							return;
						}
					}
					if (tab != selectedTab) {
						focusTab(tab);
						scroll(tab);
					}
				}
			}
		}
		public function addTab(tab:ITab):void {
			if (!tab) return;
			var tabs:Vector.<ITab> = this.tabs;
			var x:Number = 0;
			if (tabs.length) {
				tabs.sort(srt);
				var lTab:ITab = tabs[tabs.length - 1];
				x = lTab.x + lTab.width;
			} else {
				tWidths = 0;
			}
			tabContainer.addChild(DisplayObject(tab));
			tWidths += tab.width;
			tab.x = x;
			focusTab(tab);
			tabs.push(tab);
			scrollTo(x + tab.width);
		}
		public function addTabs(tablist:Vector.<ITab>):void {
			for each (var tab:ITab in tablist) {
				addTab(tab);
			}
		}
		public function focusTab(tab:ITab):void {
			if (tab && tabContainer.contains(DisplayObject(tab))) {
				tab.lastTab = selectedTab;
				tab.select();
				if (selectedTab) selectedTab.deselect();
				selectedTab = tab;
			}
		}
		public function newTab():void {
			addTab(newTabButton.newTab());
		}
		public function nextTab():Boolean {
			tabs.sort(srt);
			var i:int = tabs.indexOf(selectedTab) + 1;
			if (uint(i) < uint(tabs.length)) {
				focusTab(tabs[i]);
				return true;
			}
			return false;
		}
		public function prevTab():Boolean {
			tabs.sort(srt);
			var i:int = tabs.indexOf(selectedTab) - 1;
			if (uint(i) < uint(tabs.length)) {
				focusTab(tabs[i]);
				return true;
			}
			return false;
		}
		public function removeTab(tab:ITab):void {
			if (tab && tabContainer.contains(DisplayObject(tab))) {
				tabs.sort(srt);
				var i:int = tabs.indexOf(tab);
				tabContainer.removeChild(DisplayObject(tab));
				tWidths -= tab.width;
				tab.close();
				if (i >= 0) {
					tabs.splice(i, 1);
					if (tab == selectedTab) {
						selectedTab = tab.lastTab;
						if (selectedTab && !selectedTab.closed()) selectedTab.select();
						else {
							if (i in tabs) selectedTab = tabs[i];
							else {
								if (--i in tabs) selectedTab = tabs[i];
								++i;
							}
							if (selectedTab) selectedTab.select();
							if (i < 0) i = 0;
						}
						scroll(selectedTab);
					}
				}
				var len:int = tabs.length;
				var pW:Number = tab.width;
				while (i < len) {
					tab = tabs[i++];
					tab.x -= pW;
					pW = tab.width;
				}
				if (tab.x + pW <= sRect.x + sRect.width) scrollBy((tab.x + pW) - (sRect.x + sRect.width));
			}
		}
		public function removeAll():Vector.<ITab> {
			tWidths = 0;
			scrollBy(0);
			return tabs.splice(0, tabs.length);
		}
		public function scrollTo(x:Number):void {
			var max:Number = tWidths;
			if (max < sRect.width) {
				leftScrollButton.disable();
				rightScrollButton.disable();
			} else {
				if (x < 0) x = 0;
				if (x > max) x = max;
				scrollStop = x;
				var xW:Number = sRect.x + sRect.width;
				if (x > xW) {
					if (xW + scrollSpeed < x) {
						scrollBy(scrollSpeed);
						scrollTimer.start();
					} else scrollBy(x - xW);
				} else if (x < sRect.x) {
					if (sRect.x - scrollSpeed > x) {
						scrollBy(-scrollSpeed);
						scrollTimer.start();
					} else scrollBy(x - sRect.x);
				}
			}
		}
		public function scrollBy(n:Number):void {
			var max:Number = tWidths;
			if (max > sRect.width) {
				n = (sRect.x += n);
				if (n <= 0) {
					sRect.x = 0;
					leftScrollButton.disable();
					rightScrollButton.enable();
				} else if (n >= max - sRect.width) {
					sRect.x = max - sRect.width;
					leftScrollButton.enable();
					rightScrollButton.disable();
				} else {
					leftScrollButton.enable();
					rightScrollButton.enable();
				}
			} else {
				sRect.x = 0;
				leftScrollButton.disable();
				rightScrollButton.disable();
			}
			tabContainer.scrollRect = sRect;
		}
		public function scroll(item:ITab):void {
			if (item && tabs.indexOf(item) >= 0) {
				var x:Number = item.x + item.width;
				if (x < sRect.x + item.width) x -= item.width;
				scrollTo(x);
			}
		}
		public function setScrollSpeed(distance:Number):void {
			if ((distance * 0) != 0) return;
			scrollSpeed = Math.max(Math.abs(distance), 5);
		}
		public function updateTabPositions():void {
			tabs.sort(srt);
			var x:Number = 0;
			for each(var tab:ITab in tabs) {
				tab.x = x;
				x += tab.width;
			}
		}
		protected function tick(e:TimerEvent):void {
			scrollTimer.stop();
			scrollTimer.reset();
			scrollTo(scrollStop);
		}
		private function srt(a:ITab, b:ITab):Number {
			return a.x - b.x;
		}
	}
}
