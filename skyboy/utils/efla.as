package skyboy.utils {
	import flash.display.BitmapData;

	/**
	*	"Extremely Fast Line Algorithm"
	*	@author Po-Han Lin (original version: http://www.edepot.com/algorithm.html)
	*	@author Simo Santavirta (AS3 port: http://www.simppa.fi/blog/?p=521)
	*	@author Jackson Dunstan (minor formatting: http://jacksondunstan.com/articles/506)
	* 	@author skyboy (optimization for 10.1+)
	*	@param bmd Bitmap to draw on
	*	@param x X component of the start point
	*	@param y Y component of the start point
	*	@param x2 X component of the end point
	*	@param y2 Y component of the end point
	*	@param color Color of the line
	*/
	public function efla(bmd:BitmapData, x:int, y:int, x2:int, y2:int, color:uint):void {
		if (y2 == y) if (x2 == x) return;
		var shortLen:int = y2 - y;
		var longLen:int = x2 - x;
		var i:int, id:int, inc:int;
		var multDiff:Number;

		bmd.lock();
		bmd.setPixel(x, y, color);

		if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31)) {
			if (shortLen < 0) {
				inc = -1;
				id = -shortLen % 3;
			} else {
				inc = 1;
				id = shortLen % 3;
			}
			multDiff = shortLen == 0 ? longLen : longLen / shortLen;

			if (id) {
				i += inc;
				if (--id) {
					bmd.setPixel(x + i * multDiff, y + i, color);
					i += inc;
					if (--id) {
						bmd.setPixel(x + i * multDiff, y + i, color);
						i += inc;
					}
				}
			}
			while (i != shortLen) {
				bmd.setPixel(x + i * multDiff, y + i, color);
				i += inc;
				bmd.setPixel(x + i * multDiff, y + i, color);
				i += inc;
				bmd.setPixel(x + i * multDiff, y + i, color);
				i += inc;
				bmd.setPixel(x + i * multDiff, y + i, color);
				i += inc;
			}
		} else {
			if (longLen < 0) {
				inc = -1;
				id = -longLen % 4;
			} else {
				inc = 1;
				id = longLen % 4;
			}
			multDiff = longLen == 0 ? shortLen : shortLen / longLen;

			if (id) {
				i += inc;
				if (--id) {
					bmd.setPixel(x + i, y + i * multDiff, color);
					i += inc;
					if (--id) {
						bmd.setPixel(x + i, y + i * multDiff, color);
						i += inc;
					}
				}
			}
			while (i != longLen) {
				bmd.setPixel(x + i, y + i * multDiff, color);
				i += inc;
				bmd.setPixel(x + i, y + i * multDiff, color);
				i += inc;
				bmd.setPixel(x + i, y + i * multDiff, color);
				i += inc;
				bmd.setPixel(x + i, y + i * multDiff, color);
				i += inc;
			}
		}

		bmd.unlock();
	}
}














