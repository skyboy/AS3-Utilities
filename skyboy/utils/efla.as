package skyboy.utils {
	import flash.display.BitmapData;

	/**
	 *	"Extremely Fast Line Algorithm"
	 *	@author 	Po-Han Lin (original version: http://www.edepot.com/algorithm.html)
	 *	@author 	Simo Santavirta (AS3 port: http://www.simppa.fi/blog/?p=521)
	 *	@author 	Jackson Dunstan (minor formatting: http://jacksondunstan.com/articles/506)
	 * 	@author 	skyboy (optimization for 10.1+)
	 *	@param  BitmapData: bmd	Bitmap to draw on
	 *	@param 	int: x			X component of the start point
	 *	@param 	int: y			Y component of the start point
	 *	@param 	int: x2			X component of the end point
	 *	@param 	int: y2			Y component of the end point
	 *	@param 	uint: color		Color of the line
	 */
	public function efla(bmd:BitmapData, x:int, y:int, x2:int, y2:int, color:uint):void {
		var shortLen:int = y2 - y;
		var longLen:int = x2 - x;
		if (!longLen) if (!shortLen) return;
		var i:int, id:int, inc:int;
		var multDiff:Number;

		bmd.lock();

		// TODO: check for this above, swap x/y/len and optimize loops to ++ and -- (operators twice as fast, still only 2 loops)
		if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31)) {
			if (shortLen < 0) {
				inc = -1;
				id = -shortLen % 4;
			} else {
				inc = 1;
				id = shortLen % 4;
			}
			multDiff = !shortLen ? longLen : longLen / shortLen;

			if (id) {
				bmd.setPixel32(x, y, color);
				i += inc;
				if (--id) {
					bmd.setPixel32(x + i * multDiff, y + i, color);
					i += inc;
					if (--id) {
						bmd.setPixel32(x + i * multDiff, y + i, color);
						i += inc;
					}
				}
			}
			while (i != shortLen) {
				bmd.setPixel32(x + i * multDiff, y + i, color);
				i += inc;
				bmd.setPixel32(x + i * multDiff, y + i, color);
				i += inc;
				bmd.setPixel32(x + i * multDiff, y + i, color);
				i += inc;
				bmd.setPixel32(x + i * multDiff, y + i, color);
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
			multDiff = !longLen ? shortLen : shortLen / longLen;

			if (id) {
				bmd.setPixel32(x, y, color);
				i += inc;
				if (--id) {
					bmd.setPixel32(x + i, y + i * multDiff, color);
					i += inc;
					if (--id) {
						bmd.setPixel32(x + i, y + i * multDiff, color);
						i += inc;
					}
				}
			}
			while (i != longLen) {
				bmd.setPixel32(x + i, y + i * multDiff, color);
				i += inc;
				bmd.setPixel32(x + i, y + i * multDiff, color);
				i += inc;
				bmd.setPixel32(x + i, y + i * multDiff, color);
				i += inc;
				bmd.setPixel32(x + i, y + i * multDiff, color);
				i += inc;
			}
		}

		bmd.unlock();
	}
}














