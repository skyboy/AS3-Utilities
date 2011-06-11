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
		
		private var iXoffset1:Number;
		private var iYoffset1:Number;
		private var iZoffset1:Number;
		
		private var iXoffset2:Number;
		private var iYoffset2:Number;
		private var iZoffset2:Number;
		
		private var iXoffset3:Number;
		private var iYoffset3:Number;
		private var iZoffset3:Number;
		
		private var iXoffset4:Number;
		private var iYoffset4:Number;
		private var iZoffset4:Number;
		
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
			
			$x += iXoffset1;
			$y += iYoffset1;
			$z += iZoffset1;
			
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
			var s:Number, x1:Number, y1:Number, z1:Number, baseX:Number;
			var fFreq:Number, fPers:Number, x:Number, y:Number, z:Number;
			var xf:Number, yf:Number, zf:Number, u:Number, v:Number, w:Number;
			var g1:Number, g2:Number, g3:Number, g4:Number, g5:Number, g6:Number, g7:Number, g8:Number;;
			var X:int, Y:int, Z:int, A:int, B:int, AA:int, AB:int, BA:int, BB:int, hash:int, io:int = iOctaves;
			var i:int, px:int, pw:int, py:int, t:int, t2:int, color:int;

			baseX = $x * baseFactor + iXoffset1;
			$y = $y * baseFactor + iYoffset1;
			$z = $z * baseFactor + iZoffset1;
			
			var width:int = bitmap.width;
			var height:int = bitmap.height;
			
			var data:Vector.<uint> = bitmap.getVector(bitmap.rect);
			
			for ( py = height; py--; ) {
				$x = baseX;
				pw = py * width;
				for ( px = width; px--; ) {
					s = 0e0;
					for ( i = io ; i--; ) {
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
		
		public static function fillColor(bmp:BitmapData, chans:int, x:Number = 0, y:Number = 0, z:Number = 0):void {
			oNoise.fillColor(bmp, chans, x, y, z);
		}
		public function fillColor(bitmap:BitmapData, channels:int = 7, $x:Number = 0, $y:Number = 0, $z:Number = 0):void {
			var grey:Boolean = (channels & 15) == 0;
			var temp:Number = -(1/fPersMax);
			var s1:Number, s2:Number, s3:Number, s4:Number, color4:int;
			var fFreq:Number, fPers:Number, x:Number, y:Number, z:Number;
			var baseX1:Number, baseX2:Number, baseX3:Number, baseX4:Number;
			var xf:Number, yf:Number, zf:Number, u:Number, v:Number, w:Number;
			var x1:Number, y1:Number, z1:Number, $x4:Number, $y4:Number, $z4:Number;
			var $x2:Number, $x3:Number, $y2:Number, $y3:Number, $z2:Number, $z3:Number;
			var i:int, px:int, pw:int, py:int, t:int, t2:int, color1:int, color2:int, color3:int;
			var g1:Number, g2:Number, g3:Number, g4:Number, g5:Number, g6:Number, g7:Number, g8:Number;
			var X:int, Y:int, Z:int, A:int, B:int, AA:int, AB:int, BA:int, BB:int, hash:int, io:int = iOctaves;
			var blue:Boolean = (channels & 4) != 0, red:Boolean = (channels & 1) != 0, alpha:Boolean = (channels & 8) != 0;
			var green:Boolean = ((channels & 2) | int(grey)) != 0;
			var s01:Number = int(!green) * temp, s02:Number = int(!blue) * temp, s03:Number = int(!red) * temp, s04:Number = int(!alpha) * -temp;

			baseX2 = $x * baseFactor + iXoffset2;
			$y2 = $y * baseFactor + iYoffset2;
			$z2 = $z * baseFactor + iZoffset2;
			
			baseX3 = $x * baseFactor + iXoffset3;
			$y3 = $y * baseFactor + iYoffset3;
			$z3 = $z * baseFactor + iZoffset3;
			
			baseX4 = $x * baseFactor + iXoffset4;
			$y4 = $y * baseFactor + iYoffset4;
			$z4 = $z * baseFactor + iZoffset4;
			
			baseX1 = $x * baseFactor + iXoffset1;
			$y = $y * baseFactor + iYoffset1;
			$z = $z * baseFactor + iZoffset1;
			
			var width:int = bitmap.width;
			var height:int = bitmap.height;
			
			var data:Vector.<uint> = bitmap.getVector(bitmap.rect);
			
			for ( py = height; py--; ) {
				$x = baseX1;
				$x2 = baseX2;
				$x3 = baseX3;
				$x4 = baseX4;
				pw = py * width;
				for ( px = width; px--; ) {
					s1 = s01;
					s2 = s02;
					s3 = s03;
					s4 = s04;
					for ( i = io ; i--; ) {
						fFreq = aOctFreq[i];
						fPers = aOctPers[i];

						if (green) {
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
							
							s1 += (g8 + w * (g4 - g8)) * fPers;
						}

						if (blue) {
							x = $x2 * fFreq;
							y = $y2 * fFreq;
							z = $z2 * fFreq;
							
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
						
							s2 += (g8 + w * (g4 - g8)) * fPers;
						}

						if (red) {
							x = $x3 * fFreq;
							y = $y3 * fFreq;
							z = $z3 * fFreq;
							
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
							
							s3 += (g8 + w * (g4 - g8)) * fPers;
						}

						if (alpha) {
							x = $x4 * fFreq;
							y = $y4 * fFreq;
							z = $z4 * fFreq;
							
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
							
							s4 += (g8 + w * (g4 - g8)) * fPers;
						}
					}
					
					if (grey) {
						s2 = s1;
						s3 = s1;
					}
					color1 = ((s1 * fPersMax + 1) * 127) + 1;
					color2 = ((s2 * fPersMax + 1) * 127) + 1;
					color3 = ((s3 * fPersMax + 1) * 127) + 1;
					color4 = ((s4 * fPersMax + 1) * 127) + 1;
					data[pw + px] = (color4 << 24) | (color3 << 16) | (color1 << 8) | color2;
					
					$x += baseFactor;
					$x2 += baseFactor;
					$x3 += baseFactor;
					$x4 += baseFactor;
				}
				
				$y += baseFactor;
				$y2 += baseFactor;
				$y3 += baseFactor;
				$y4 += baseFactor;
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
			iXoffset1 = iSeed = (iSeed * 16807) % 2147483647;
			iYoffset1 = iSeed = (iSeed * 16807) % 2147483647;
			iZoffset1 = iSeed = (iSeed * 16807) % 2147483647;
			
			iXoffset2 = iSeed = (iSeed * 16807) % 2147483647;
			iYoffset2 = iSeed = (iSeed * 16807) % 2147483647;
			iZoffset2 = iSeed = (iSeed * 16807) % 2147483647;
			
			iXoffset3 = iSeed = (iSeed * 16807) % 2147483647;
			iYoffset3 = iSeed = (iSeed * 16807) % 2147483647;
			iZoffset3 = iSeed = (iSeed * 16807) % 2147483647;
			
			iXoffset4 = iSeed = (iSeed * 16807) % 2147483647;
			iYoffset4 = iSeed = (iSeed * 16807) % 2147483647;
			iZoffset4 = iSeed = (iSeed * 16807) % 2147483647;
		}
	}
}
import skyboy.math.OptimizedPerlin
internal const oNoise:OptimizedPerlin = new OptimizedPerlin;
