package skyboy.media {
	/**
	 * SoundManager by skyboy. April 20th 2010.
	 * Visit http://github.com/skyboy for documentation, updates
	 * and more free code.
	 *
	 *
	 * Copyright (c) 2010, skyboy
	 *    All rights reserved.
	 *
	 * Permission is hereby granted, free of charge, to any person
	 * obtaining a copy of this software and associated documentation
	 * files (the "Software"), to deal in the Software with
	 * restriction, with limitation the rights to use, copy, modify,
	 * merge, publish, distribute, sublicense copies of the Software,
	 * and to permit persons to whom the Software is furnished to do so,
	 * subject to the following conditions and limitations:
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
	/**
	 * imports
	 */
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.setTimeout;
	/**
	 * @author	skyboy
	 * @update	15/6/2010: add methods from UnknownGuardian
	 * @editor	UnknownGuardian
	 * @editor
	 */
	public class SoundManager {
		/**
		 * protected variables
		**/
		protected var timeDelay:int = 50, soundTypes:Vector.<int>, Sounds:Vector.<Sound>, channels:Vector.<DataStore>;
		protected var currentPlayingSounds:int, maxPlayableSounds:int = 16, maxPlayableOfType:int = 4, soundTimers:Vector.<Boolean>;
		protected var maximumSounds:int, soundLoops:Vector.<int>, Transforms:Vector.<SoundTransform>;
		/**
		 * public variables
		**/
		public function get soundsPlaying():int {
			return currentPlayingSounds;
		}
		/**
		 * constructor
		 * @param	int: maxSounds	 The maximum number of sounds the SoundManager can store (4096)
		 * @param	int: maxPlayable	 Maxmum number sounds that can be playing at one time (16)
		 * @param	int: maxOfTypePlayable	 Maxmum number of sounds of a specific type(id) that can be playing at one time (4)
		 * @param	int: delayForPlays	 The delay (in milliseconds) before another sound of type(id) X can be played again (15)
		**/
		public function SoundManager(maxSounds:int = 4096, maxPlayable:int = 16, maxOfTypePlayable:int = 4, delayForPlays:int = 15) {
			maximumSounds = min(maxSounds);
			maxPlayableSounds = min(maxPlayable);
			maxPlayableOfType = min(maxOfTypePlayable);
			timeDelay = min(delayForPlays);
			soundTypes = new Vector.<int>(maximumSounds, true);
			soundTimers = new Vector.<Boolean>(maximumSounds, true);
			Sounds = new Vector.<Sound>(maximumSounds, true);
			Transforms = new Vector.<SoundTransform>(maximumSounds, true);
			channels = new Vector.<DataStore>(maxPlayableSounds, true);
			soundLoops = new Vector.<int>(maxPlayableSounds, true);
		}
		/**
		 * public functions
		**/
		/**
		 * addSound
		 * @param	Sound: snd	 The Sound object to add to the manager
		 * @param	SoundTransform: sndTransform	 The SoundTransform object to apply to all new instances of the sound (null)
		 * @return	int: The ID representing the sound type you just pushed into the manager
		 */
		public function addSound(snd:Sound, sndTransform:SoundTransform = null):int {
			var b:int = Sounds.indexOf(null);
			Sounds[b] = snd;
			Transforms[b] = sndTransform;
			soundTypes[b] = 0;
			soundTimers[b] = true;
			return b;
		}
		/**
		 * addSoundAndPlay
		 * @param	Sound: snd	 The Sound object to add to the manager
		 * @param	int: loops	 The number of times the sound will run (0)
		 * @param	SoundTransform: sndTransform	 A SoundTransform object for use with the sound (null)
		 * @param	Number: startTime	 The position to start playing the sound from (0.0)
		 * @param	Function: callback	 A function that will be called when the sound completes (null)
		 * @param	SoundTransform: defaultSoundTransform	 The SoundTransform object to apply to all new instances of the sound (null)
		 * @return	int: The ID representing the sound type you just pushed into the manager
		 */
		public function addSoundAndPlay(snd:Sound, loops:int = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0, callback:Function = null, defaultSoundTransform:SoundTransform = null):int {
			var a:int = addSound(snd, defaultSoundTransform);
			playSound(a, loops, sndTransform, startTime, callback);
			return a;
		}
		/**
		 * addMusicAndPlay
		 * @param	Sound: snd	 The Sound object to add to the manager
		 * @param	int: loops	 The number of times the sound will run (0)
		 * @param	SoundTransform: sndTransform	 A SoundTransform object for use with the sound (null)
		 * @param	Number: startTime	 The position to start playing the sound from (0.0)
		 * @param	SoundTransform: defaultSoundTransform	 The SoundTransform object to apply to all new instances of the sound (null)
		 * @return	Array: An array with the ID representing the sound type you just pushed into the manager as element 0 and the ID of the now playing music as element 2
		 */
		public function addMusicAndPlay(snd:Sound, loops:int = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0, defaultSoundTransform:SoundTransform = null):Array {
			var a:int = addSound(snd, defaultSoundTransform);
			var b:int = playMusic(a, loops, sndTransform, startTime);
			return [a, b];
		}
		/**
		 * deleteSound
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	Boolean: stopPlayingAll	 Stop playing all sounds of type? (false)
		 * @return	Boolean: true if the sound was removed, false if an invalid type was given
		 */
		public function deleteSound(type:int, stopPlayingAll:Boolean = false):Boolean {
			if (valid(type)) {
				if (stopPlayingAll) stopAll(type);
				Sounds[b] = null;
				Transforms[b] = null;
				soundTypes[b] = 0;
				soundTimers[b] = false;
				return true;
			}
			return false;
		}
		/**
		 * soundsOfTypePlaying
		 * @param	int: id	 The ID of a sound added to the manager
		 * @return	int: The number of sounds of type are currently playing
		 */
		public function soundsOfTypePlaying(type:int):int {
			return soundTypes[type];
		}
		/**
		 * playSound
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	int: loops	 The number of times the sound will run (0)
		 * @param	SoundTransform: sndTransform	 A SoundTransform object for use with the sound (null)
		 * @param	Number: startTime	 The position to start playing the sound from (0.0)
		 * @param	Function: callback	 A function that will be called when the sound completes (null)
		 * @return	Boolean: true if the sound was sucessfully started playing
		 */
		public function playSound(type:int, loops:int = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0, callback:Function = null):Boolean {
			if (valid(type)) {
				if (canPlay(type)) {
					increment(type);
					sndTransform ||= Transforms[type];
					var b:int = channels.indexOf(null);
					var a:DataStore = channels[b] = new DataStore(Sounds[type], b, loops, sndTransform);
					a.play(startTime);
					callback ||= VOID;
					a.addEventListener(Event.SOUND_COMPLETE, function(e:Event):void { e.target.removeEventListener(e.type, arguments.callee); soundEnded(e, type, null); callback.call(null, e); } );
					return true;
				}
			} else {
				throw new Error("Sound #" + type + " does not exist.", 2068);
			}
			return false;
		}
		/**
		 * playMusic
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	Number: loops	 the number of times the sound will run, Infinity will continuously run (0)
		 * @param	SoundTransform: sndTransform	 a SoundTransform object for use with the sound (null)
		 * @param	Number: startTime	 the position to start playing the sound from (0.0)
		 * @return	int: the ID of the now playing SoundChannel object
		 */
		public function playMusic(type:int, loops:Number = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0):int {
			if (valid(type)) {
				if (canPlay(type)) {
					increment(type);
					sndTransform ||= Transforms[type];
					var b:int = channels.indexOf(null);
					var a:DataStore = channels[b] = new DataStore(Sounds[type], b, loops, sndTransform);
					a.addEventListener(Event.SOUND_COMPLETE, function(e:Event, func:Function = null):void { e.target.removeEventListener(e.type, arguments.callee); soundEnded(e, type, a); } );
					a.play(startTime);
					return b;
				}
			} else {
				throw new Error("Sound #" + type + " does not exist.", 2068);
			}
			return -1;
		}
		/**
		 * stopMusic
		 * @param	int: id	 An ID returned by playMusic
		 * @return	Boolean: true if the sound was sucessfully stopped
		 */
		public function stopMusic(id:int):Boolean {
			if (validC(id)) {
				channels[id].stop();
				return true;
			}
			return false;
		}
		/**
		 * stopAll
		 * @param	int: type	The ID of a sound added to the manager, or -1 for all (-1)
		 * @return	Boolean: true if all sounds were stopped.
		 */
		public function stopAll(type:int = -1):Boolean {
			var i:int = maxPlayableSounds, b:DataStore;
			if (type == -1) {
				while (~--i) {
					if ((b = channels[i])) {
						b.stop();
					}
				}
				return true;
			} else if (valid(type)) {
				while (~--i) {
					if ((b = channels[i]) && b.id == type) {
						b.stop();
					}
				}
				return true;
			}
			return false;
		}
		/**
		 * pauseMusic
		 * @param	int: id	 An ID returned by playMusic
		 * @return	Boolean: true if the sound was sucessfully stopped
		 */
		public function pause(id:int):Boolean {
			if (validC(id)) {
				channels[id].pause();
				return true;
			}
			return false
		}
		/**
		 * unpauseMusic
		 * @param	int: id	 An ID returned by playMusic
		 * @return	Boolean: true if the sound was sucessfully started
		 */
		public function unpause(id:int):Boolean {
			if (validC(id)) {
				channels[id].unpause();
				return true;
			}
			return false;
		}
		/**
		 * isPaused
		 * @param	int: id	 An ID returned by playMusic
		 * @return	Boolean: true if paused, otherwise false
		 */
		public function isPaused(id:int):Boolean {
			if (validC(id)) {
				return channels[id].paused;
			}
			return false;
		}
		/**
		 * changeSoundVolume
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	Number: volume	 A Number to set the volume to (1)
		 * @return	Boolean: true if the sound volume was succssfully changed
		 */
		public function changeSoundVolume(type:int, volume:Number = 1):Boolean {
			if (valid(type)) {
				var sT:SoundTransform = getSoundTransform(type);
				sT.volume = volume;
				return setSoundTransform(type, sT);
			}
			return false;
		}
		/**
		 * setSoundTransform
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	SoundTransform: sndTransform	 The transform to set (null)
		 * @return	Boolean: true if the transform was applied sucessfully
		 */
		public function setSoundTransform(type:int, sndTransform:SoundTransform = null):Boolean {
			if (valid(type)) {
				Transforms[type] = sndTransform;
				return true;
			}
			return false;
		}
		/**
		 * getSoundTransform
		 * @param	int: type	 The ID of a sound added to the manager
		 * @return	SoundTransform: The sound transfrom or null
		 */
		public function getSoundTransform(type:int):SoundTransform {
			if (valid(type)) {
				return Transforms[type] || new SoundTransform(1, 0);
			}
			return null;
		}
		/**
		 * changeVolume
		 * @author	UnknownGuardian
		 * @param	int: id	 An ID returned by playMusic
		 * @param	Number: volume	 The volume to set it to (1)
		 * @return	Boolean: true if the sound volume was succssfully changed
		 * @update	15/6/2010(skyboy): Added method, changed to use setTransform, and made it so other parts of the tasnform aren't changed
		 */
		public function changeVolume(id:int, volume:Number = 1):Boolean {
			if (validC(id)) {
				var sT:SoundTransform = getTransform(id);
				sT.volume = volume; // let flash throw it's own error here
				return setTransform(id, sT);
			}
			return false;
		}
		/**
		 * setTransform
		 * @param	int: id	 An ID returned by playMusic
		 * @param	SoundTransform: sndTransform	 The transform to apply (null)
		 * @return	Boolean: true if the transform was applied sucessfully
		 */
		public function setTransform(id:int, sndTransform:SoundTransform = null):Boolean {
			if (validC(id)) {
				channels[id].setTransform(sndTransform);
				return true;
			}
			return false;
		}
		/**
		 * getTransform
		 * @param	int: id	 An ID returned by playMusic
		 * @return	SoundTransform: The sound transfrom or null
		 */
		public function getTransform(id:int):SoundTransform {
			if (validC(id)) {
				return channels[id].getTransform();
			}
			return null;
		}
		/**
		 * protected functions
		**/
		protected function valid(id:int):Boolean {
			return id > -1 && id < maximumSounds && Sounds[id];
		}
		protected function validC(id:int):Boolean {
			return id > -1 && id < maxPlayableSounds && channels[id];
		}
		protected function increment(id:int):void {
			++currentPlayingSounds;
			++soundTypes[id];
			switchTypeCanPlay(id);
			setTimeout(switchTypeCanPlay, timeDelay, id);
		}
		protected function canPlay(id:int):Boolean {
			return soundTimers[id] && currentPlayingSounds < maxPlayableSounds && soundTypes[id] < maxPlayableOfType;
		}
		protected function switchTypeCanPlay(id:int):void {
			soundTimers[id] = !soundTimers[id];
		}
		protected function soundEnded(e:Event, id:int, dStore:DataStore = null):void {
			if (dStore) {
				var b:int = channels.indexOf(dStore);
				if (~b && b < maxPlayableSounds) {
					channels[b] = null;
				}
			}
			--soundTypes[id];
			--currentPlayingSounds;
		}
		protected function min(x:int):int {
			x = (x ^ x >> 31) + (x >>> 31);
			return x < 2147483647 ? x : 2147483647;
		}
		/**
		 * private functions
		**/
		private function VOID(...Void):void {
			return;
		}
	}
}
internal class DataStore {
	private var sChannel:flash.media.SoundChannel, s:flash.media.Sound, loops:int, listner:Array, sT:flash.media.SoundTransform;
	private var pausePos:Number = 0, finitePlays:Boolean, listener:Function, _p:Boolean = false, _id:int;
	private function listenerHelper(e:flash.events.Event):void {
		var b:flash.media.SoundChannel = e.target as flash.media.SoundChannel;
		b.removeEventListener(e.type, arguments.callee);
		var a:Array = listner;
		if (a[1] == arguments.callee) {
			loop();
		} else {
			b.addEventListener(e.type, a[1]);
			b.dispatchEvent(e);
		}
	}
	private function listenerRepeater(e:flash.events.Event):void {
		var b:flash.media.SoundChannel = e.target as flash.media.SoundChannel;
		b.removeEventListener(e.type, arguments.callee);
		var remove:Boolean = loop();
		if (remove) {
			if (listener.length == 2) try { listener(e, a); return; } catch (er:*) { }
			var a:Array = listner;
			a[2] = listener;
			b.addEventListener.apply(b, a);
			b.dispatchEvent(e)
		}
	}
	public function get id():int {
		return _id
	}
	public function DataStore(_s:flash.media.Sound, id:int, _loops:Number, _sT:flash.media.SoundTransform = null) {
		s = _s;
		sT = _sT;
		_id = id;
		setLoops(_loops);
		listner = [flash.events.Event.SOUND_COMPLETE, listenerHelper, false, 0, false];
	}
	public function loop():Boolean {
		if (loops > 0) {
			play();
			return false;
		}
		return true;
	}
	public function play(startTime:Number = 0.0, _loops:Number = NaN):DataStore {
		setLoops(_loops);
		if (finitePlays) --loops;
		if (sChannel) sChannel.stop();
		(sChannel = s.play(startTime, 0, sT)).addEventListener.apply(sChannel, listner);
		return this;
	}
	public function setLoops(_loops:Number):void {
		if (_loops == _loops) { // this is to make sure it's not NaN (NaN == NaN is false, NaN != NaN is true)
			if ((finitePlays = _loops != Infinity)) {
				loops = 1;
			} else {
				loops = _loops < 0 ? 0 : _loops < int.MAX_VALUE ? _loops : int.MAX_VALUE;
			}
		}
	}
	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
		var a:DataStore = this;
		this.listener = listener;
		listner = [type, listenerRepeater, useCapture, priority, useWeakReference];
	}
	public function stop():void {
		if (sChannel) {
			loops = 0;
			sChannel.stop();
			sChannel.dispatchEvent(new flash.events.Event(flash.events.Event.SOUND_COMPLETE));
			_p = false;
			pausePos = 0;
		}
	}
	public function pause():void {
		if (!_p) {
			pausePos = sChannel.position;
			sChannel.stop();
			_p = true;
		}
	}
	public function unpause():void {
		if (_p) {
			(sChannel = s.play(pausePos, 0, sT)).addEventListener.apply(sChannel, listner);
			pausePos = 0;
			_p = false;
		}
	}
	public function get paused():Boolean {
		return _p;
	}
	public function dispatchEvent(...Void):void {
	}
	/**
	 * Change soundTransform
	 * @author  UnknownGuardian
	 * @param   New soundTransform data to be applied
	 * @return  Void
	 * @update  15/6/2010(skyboy) also apply transform immediately instead of at next loop
	 */
	public function setTransform(t:flash.media.SoundTransform):void {
		sT = t;
		if (!sChannel) return;
		sChannel.soundTransform = t;
	}
	/**
	 * getTransform
	 * @return SoundTransform: the current sound transform of the SoundChannel
	 */
	public function getTransform():flash.media.SoundTransform {
		if (!sChannel) return null;
		return sChannel.soundTransform;
	}
}
