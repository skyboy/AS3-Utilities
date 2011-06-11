/**
Title:			Perlin noise
Version:		1.2
Author:			Ron Valstar
Author URI:		http://www.sjeiti.com/
Original code port from http://mrl.nyu.edu/~perlin/noise/
and some help from http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
AS3 optimizations by Mario Klingemann http://www.quasimondo.com
further AS3 optimizations by skyboy http://skyript.com/
*/
package skyboy.math { /*nl.ronvalstar.math*/
	import flash.display.BitmapData;
	
	final public class OptimizedPerlin {
		//{
		private static const p:Vector.<int> = new <int>[
					151,160,137,91,90,15,131,13,201,95,
					96,53,194,233,7,225,140,36,103,30,69,
					142,8,99,37,240,21,10,23,190,6,148,
					247,120,234,75,0,26,197,62,94,252,
					219,203,117,35,11,32,57,177,33,88,
					237,149,56,87,174,20,125,136,171,
					168,68,175,74,165,71,134,139,48,27,
					166,77,146,158,231,83,111,229,122,
					60,211,133,230,220,105,92,41,55,46,
					245,40,244,102,143,54,65,25,63,161,
					1,216,80,73,209,76,132,187,208,89,
					18,169,200,196,135,130,116,188,159,
					86,164,100,109,198,173,186,3,64,52,
					217,226,250,124,123,5,202,38,147,118,
					126,255,82,85,212,207,206,59,227,47,
					16,58,17,182,189,28,42,223,183,170,
					213,119,248,152,2,44,154,163,70,221,
					153,101,155,167,43,172,9,129,22,39,
					253,19,98,108,110,79,113,224,232,
					178,185,112,104,218,246,97,228,251,
					34,242,193,238,210,144,12,191,179,
					162,241,81,51,145,235,249,14,239,
					107,49,192,214,31,181,199,106,157,
					184,84,204,176,115,121,50,45,127,4,
					150,254,138,236,205,93,222,114,67,29,
					24,72,243,141,128,195,78,66,215,61,
					156,180,151,160,137,91,90,15,131,13,
					201,95,96,53,194,233,7,225,140,36,
					103,30,69,142,8,99,37,240,21,10,23,
					190,6,148,247,120,234,75,0,26,197,
					62,94,252,219,203,117,35,11,32,57,
					177,33,88,237,149,56,87,174,20,125,
					136,171,168,68,175,74,165,71,134,139,
					48,27,166,77,146,158,231,83,111,229,
					122,60,211,133,230,220,105,92,41,55,
					46,245,40,244,102,143,54,65,25,63,
					161,1,216,80,73,209,76,132,187,208,
					89,18,169,200,196,135,130,116,188,
					159,86,164,100,109,198,173,186,3,64,
					52,217,226,250,124,123,5,202,38,147,
					118,126,255,82,85,212,207,206,59,
					227,47,16,58,17,182,189,28,42,223,
					183,170,213,119,248,152,2,44,154,
					163,70,221,153,101,155,167,43,172,9,
					129,22,39,253,19,98,108,110,79,113,
					224,232,178,185,112,104,218,246,97,
					228,251,34,242,193,238,210,144,12,
					191,179,162,241,81,51,145,235,249,
					14,239,107,49,192,214,31,181,199,
					106,157,184,84,204,176,115,121,50,
					45,127,4,150,254,138,236,205,93,
					222,114,67,29,24,72,243,141,128,
					195,78,66,215,61,156,180];
		//}
		private const p:Vector.<int> = OptimizedPerlin.p;
		private var iOctaves:int = 4;
		private var fPersistence:Number = .5;
		//
		private var aOctFreq:Vector.<Number>; // frequency per octave
		private var aOctPers:Vector.<Number>; // persistence per octave
		private var fPersMax:Number;// 1 / max persistence
		//
		private var iSeed:int = 123;
		
		private var iXoffset:Number;
		private var iYoffset:Number;
		private var iZoffset:Number;
		
		private const baseFactor:Number = 1 / 64;
		
		//
		// PUBLIC
		public static function noise(x:Number, y:Number = 1, z:Number = 1):Number {
			return oNoise.noise(x, y, z);
		}
		public function noise($x:Number, $y:Number = 1, $z:Number = 1):Number {
			
			var s:Number = 0;
			var fFreq:Number, fPers:Number, x:Number, y:Number, z:Number;
			var xf:Number, yf:Number, zf:Number, u:Number, v:Number, w:Number;
			var x1:Number, y1:Number, z1:Number;
			var X:int, Y:int, Z:int, A:int, B:int, AA:int, AB:int, BA:int, BB:int, hash:int;
			var g1:Number, g2:Number, g3:Number, g4:Number, g5:Number, g6:Number, g7:Number, g8:Number;
			var t:int, t2:int;
			
			$x += iXoffset;
			$y += iYoffset;
			$z += iZoffset;
			
			for (var i:int;i<iOctaves;i++)
			{
				fFreq = aOctFreq[i];
				fPers = aOctPers[i];
				
				x = $x * fFreq;
				y = $y * fFreq;
				z = $z * fFreq;
				
				xf = x - (x % 1);//Math.floor(x);
				yf = y - (y % 1);//Math.floor(y);
			 	zf = z - (z % 1);//Math.floor(z);
			
				X = xf & 255;
			 	Y = yf & 255;
			 	Z = zf & 255;
			
				x -= xf;
				y -= yf;
				z -= zf;
			
			 	u = x * x * x * (x * (x*6 - 15) + 10);
			 	v = y * y * y * (y * (y*6 - 15) + 10);
			 	w = z * z * z * (z * (z*6 - 15) + 10);
			
			 	A  = p[X] + Y;
			 	AA = p[A] + Z;
			 	AB = p[A+1] + Z;
			 	B  = p[X+1] + Y
			 	BA = p[B] + Z;
			 	BB = p[B+1] + Z;
			
			 	x1 = x-1;
			 	y1 = y-1;
			 	z1 = z-1;
			
			 	hash = p[BB + 1] & 15;
				t = int(hash < 8);
				g1 = ((-(hash & 1) | 1)* (t * x1 + (1 - t) * y1));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g1 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x1 + (1 - t) * z1 ));
			
				hash = p[AB + 1] & 15;
				t = int(hash < 8);
				g2 = ((-(hash & 1) | 1)* (t * x + (1 - t) * y1));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g2 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x + (1 - t) * z1 ));
			
				hash = p[BA + 1] & 15;
				t = int(hash < 8);
				g3 = ((-(hash & 1) | 1)* (t * x1 + (1 - t) * y));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g3 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x1 + (1 - t) * z1 ));
			
				hash = p[AA + 1] & 15;
				t = int(hash < 8);
				g4 = ((-(hash & 1) | 1)* (t * x + (1 - t) * y));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g4 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x + (1 - t) * z1 ));
			
				hash = p[BB] & 15;
				t = int(hash < 8);
				g5 = ((-(hash & 1) | 1)* (t * x1 + (1 - t) * y1));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g5 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x1 + (1 - t) * z ));
			
				hash = p[AB] & 15;
				t = int(hash < 8);
				g6 = ((-(hash & 1) | 1)* (t * x + (1 - t) * y1));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g6 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x + (1 - t) * z ));
			
				hash = p[BA] & 15;
				t = int(hash < 8);
				g7 = ((-(hash & 1) | 1)* (t * x1 + (1 - t) * y));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g7 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x1 + (1 - t) * z ));
			
				hash = p[AA] & 15;
				t = int(hash < 8);
				g8 = ((-(hash & 1) | 1)* (t * x + (1 - t) * y));
				t = int(hash == (12 | (hash & 2)));
				t2 = int(hash < 4);
				g8 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x + (1 - t) * z ));
				
				g2 += u * (g1 - g2);
				g4 += u * (g3 - g4);
				g6 += u * (g5 - g6);
				g8 += u * (g7 - g8);
				
				g4 += v * (g2 - g4);
				g8 += v * (g6 - g8);
			
				s += ( g8 + w * (g4 - g8)) * fPers;
			}
			
			return ( s * fPersMax + 1 ) * .5;
		}
		
		
		public static function fill(bmp:BitmapData, x:Number = 0, y:Number = 0, z:Number = 0):void {
			oNoise.fill(bmp, x, y, z);
		}
		public function fill(bitmap:BitmapData, $x:Number = 0, $y:Number = 0, $z:Number = 0):void {
			var s:Number = 0, baseX:Number;
			var x1:Number, y1:Number, z1:Number;
			var fFreq:Number, fPers:Number, x:Number, y:Number, z:Number;
			var xf:Number, yf:Number, zf:Number, u:Number, v:Number, w:Number;
			var g1:Number, g2:Number, g3:Number, g4:Number, g5:Number, g6:Number, g7:Number, g8:Number;
			var i:int, px:int, pw:int, py:int, color:int, t:int, t2:int;
			var  X:int, Y:int, Z:int, A:int, B:int, AA:int, AB:int, BA:int, BB:int, hash:int;
			
			baseX = $x * baseFactor + iXoffset;
			$y = $y * baseFactor + iYoffset;
			$z = $z * baseFactor + iZoffset;
			
			var width:int = bitmap.width;
			var height:int = bitmap.height;
			
			var data:Vector.<uint> = bitmap.getVector(bitmap.rect);
			
			for ( py = height; py--; ) {
				$x = baseX;
				pw = py * width;
				for ( px = width; px--; ) {
					s = 0;
					
					for ( i = iOctaves ; i--; ) {
						fFreq = aOctFreq[i];
						fPers = aOctPers[i];
						
						x = $x * fFreq;
						y = $y * fFreq;
						z = $z * fFreq;
						
						xf = x - (x % 1);//Math.floor(x);
						yf = y - (y % 1);//Math.floor(y);
					 	zf = z - (z % 1);//Math.floor(z);
					
						X = xf & 255;
					 	Y = yf & 255;
					 	Z = zf & 255;
					
						x -= xf;
						y -= yf;
						z -= zf;
					
					 	u = x * x * x * (x * (x * 6 - 15) + 10);
					 	v = y * y * y * (y * (y * 6 - 15) + 10);
					 	w = z * z * z * (z * (z * 6 - 15) + 10);
					
					 	A  = p[X] + Y;
					 	AA = p[A] + Z;
					 	AB = p[A + 1] + Z;
					 	B  = p[X + 1] + Y;
					 	BA = p[B] + Z
					 	BB = p[B + 1] + Z;
					
					 	x1 = x - 1;
					 	y1 = y - 1;
					 	z1 = z - 1;
					
						hash = p[BB + 1] & 15;
						t = int(hash < 8);
						g1 = (( -(hash & 1) | 1) * (t * x1 + (1 - t) * y1));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g1 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x1 + (1 - t) * z1 ));
					
						hash = p[AB + 1] & 15;
						t = int(hash < 8);
						g2 = (( -(hash & 1) | 1) * (t * x + (1 - t) * y1));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g2 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x + (1 - t) * z1 ));
					
						hash = p[BA + 1] & 15;
						t = int(hash < 8);
						g3 = (( -(hash & 1) | 1) * (t * x1 + (1 - t) * y));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g3 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x1 + (1 - t) * z1 ));
					
						hash = p[AA + 1] & 15;
						t = int(hash < 8);
						g4 = ((-(hash & 1) | 1)* (t * x + (1 - t) * y));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g4 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x + (1 - t) * z1 ));
					
						hash = p[BB] & 15;
						t = int(hash < 8);
						g5 = (( -(hash & 1) | 1) * (t * x1 + (1 - t) * y1));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g5 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x1 + (1 - t) * z ));
					
						hash = p[AB] & 15;
						t = int(hash < 8);
						g6 = (( -(hash & 1) | 1) * (t * x + (1 - t) * y1));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g6 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y1 + (1 - t2) * (t * x + (1 - t) * z ));
					
						hash = p[BA] & 15;
						t = int(hash < 8);
						g7 = (( -(hash & 1) | 1) * (t * x1 + (1 - t) * y));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g7 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x1 + (1 - t) * z ));
					
						hash = p[AA] & 15;
						t = int(hash < 8);
						g8 = (( -(hash & 1) | 1) * (t * x + (1 - t) * y));
						t = int(hash == (12 | (hash & 2)));
						t2 = int(hash < 4);
						g8 += ((int(!(hash & 2)) << 1) - 1) * (t2 * y + (1 - t2) * (t * x + (1 - t) * z ));
				
						g2 += u * (g1 - g2);
						g4 += u * (g3 - g4);
						g6 += u * (g5 - g6);
						g8 += u * (g7 - g8);
						
						g4 += v * (g2 - g4);
						g8 += v * (g6 - g8);
					
						s += (g8 + w * (g4 - g8)) * fPers;
					}
					
					color = (s * fPersMax + 1) * 128;
					data[pw + px] = 0xff000000 | color << 16 | color << 8 | color;
					
					$x += baseFactor;
				}
				
				$y += baseFactor;
			}
			bitmap.setVector(bitmap.rect, data);
		}
		
		
		// GETTER / SETTER
		//
		// get octaves
		public static function get octaves():int {
			return oNoise.iOctaves;
		}
		// set octaves
		public static function set octaves(_iOctaves:int):void {
			oNoise.iOctaves = _iOctaves;
			oNoise.octFreqPers();
		}
		//
		// get falloff
		public static function get falloff():Number {
			return oNoise.fPersistence;
		}
		// set falloff
		public static function set falloff(_fPersistence:Number):void {
			oNoise.fPersistence = _fPersistence;
			oNoise.octFreqPers();
		}
		//
		// get seed
		public static function get seed():Number {
			return oNoise.iSeed;
		}
		// set seed
		public static function set seed(_iSeed:Number):void {
			oNoise.iSeed = _iSeed;
			oNoise.seedOffset();
		}
		public function get octaves():int {
			return iOctaves;
		}
		// set octaves
		public function set octaves(_iOctaves:int):void {
			iOctaves = _iOctaves;
			octFreqPers();
		}
		//
		// get falloff
		public function get falloff():Number {
			return fPersistence;
		}
		// set falloff
		public function set falloff(_fPersistence:Number):void {
			fPersistence = _fPersistence;
			octFreqPers();
		}
		//
		// get seed
		public function get seed():Number {
			return iSeed;
		}
		// set seed
		public function set seed(_iSeed:Number):void {
			iSeed = _iSeed;
			seedOffset();
		}
		
		public function OptimizedPerlin():void {
			seedOffset();
			octFreqPers();
		}
		
		
		private function octFreqPers():void {
			var fFreq:Number, fPers:Number;
			
			aOctFreq = new Vector.<Number>(iOctaves);
			aOctPers = new Vector.<Number>(iOctaves);
			fPersMax = 0;
			
			for (var i:int; i < iOctaves; i++) {
				fFreq = Math.pow(2,i);
				fPers = Math.pow(fPersistence,i);
				fPersMax += fPers;
				aOctFreq[i] = fFreq;
				aOctPers[i] = fPers;
			}
			
			fPersMax = 1 / fPersMax;
		}
		
		private function seedOffset():void {
			iXoffset = iSeed = (iSeed * 16807) % 2147483647;
			iYoffset = iSeed = (iSeed * 16807) % 2147483647;
			iZoffset = iSeed = (iSeed * 16807) % 2147483647;
		}
	}
}
import skyboy.math.OptimizedPerlin
internal const oNoise:OptimizedPerlin = new OptimizedPerlin;
