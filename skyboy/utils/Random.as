package skyboy.utils {
	import flash.utils.getTimer;
	public class Random {
		private static const r:Random = new Random((new Date().getTime() & 0xFFFFFFFF) ^ getTimer());
		/**
		 * randomNumber
		 * @return Number: A number that is less than or equal to zero and less than one
		 */
		public static function randomNumber():Number {
			return r.extractNumber();
		}
		private const MT:Vector.<int> = new Vector.<int>(624);
		private var index:int;
		/**
		 * @param	int: seed	The seed number to use, using the same seed will get you the same results each time
		 */
		public function Random(seed:int):void {
			var i:int, b:int = MT[0] = seed;
			while (++i < 624) b = (MT[i] = (1812433253 * b ^ ((b >>> 30) + i)) & 0xFFFFFFFF);
		}
		/**
		 * extractNumber
		 * @return Number: A number that is greater than or equal to zero and less than one
		 */
		public function extractNumber():Number {
			if (index == 0) generateNumbers();
			var y:int = MT[index];
			index = (index + 1) % 624;
			y ^= y >>> 11;
			y ^= (y << 7) & 2636928640;
			y ^= (y << 15) & 4022730752;
			return uint(y ^ (y >>> 18)) / (uint.MAX_VALUE + Number.MIN_VALUE);
		}
		/**
		 * extractNumber2
		 * @return Number: A number that is greater than negative one and less than one
		 */
		public function extractNumber2():Number {
			if (index == 0) generateNumbers();
			var y:int = MT[index];
			index = (index + 1) % 624;
			y ^= y >>> 11;
			y ^= (y << 7) & 2636928640;
			y ^= (y << 15) & 4022730752;
			return (y ^ (y >>> 18)) / (int.MAX_VALUE + Number.MIN_VALUE);
		}
		/**
		 * extractNumber3
		 * @return Number: A number that is greater than negative 0.5 and less than 0.5
		 */
		public function extractNumber3():Number {
			if (index == 0) generateNumbers();
			var y:int = MT[index];
			index = (index + 1) % 624;
			y ^= y >>> 11;
			y ^= (y << 7) & 2636928640;
			y ^= (y << 15) & 4022730752;
			return (y ^ (y >>> 18)) / (uint.MAX_VALUE + Number.MIN_VALUE);
		}
		/**
		 * extractUint
		 * @return uint: An unsigned integer between 0 and uint.MAX_VALUE
		 */
		public function extractUint():uint {
			if (index == 0) generateNumbers();
			var y:int = MT[index];
			index = (index + 1) % 624;
			y ^= y >>> 11;
			y ^= (y << 7) & 2636928640;
			y ^= (y << 15) & 4022730752;
			return (y ^ (y >>> 18));
		}
		/**
		 * extractInt
		 * @return int: An integer between int.MIN_VALUE and int.MAX_VALUE
		 */
		public function extractInt():int {
			if (index == 0) generateNumbers();
			var y:int = MT[index];
			index = (index + 1) % 624;
			y ^= y >>> 11;
			y ^= (y << 7) & 2636928640;
			y ^= (y << 15) & 4022730752;
			return (y ^ (y >>> 18));
		}
		private function generateNumbers():void {
			var i:int, y:int;
			while (i < 623) {
				if ((y = (MT[i] & 2147483648) | (MT[(++i) % 624] & 2147483647)) & 1) {
					MT[i] = (MT[(i + 396) % 624] ^ (y >>> 1)) ^ 2567483615;
				} else {
					MT[i] = MT[(i + 396) % 624] ^ (y >>> 1);
				}
			}
		}
	}
}
