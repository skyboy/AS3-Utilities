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
	import flash.utils.Timer;
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
	final public class SoundManager {
		/**
		 * private variables
		**/
		private var timeDelay:int, soundTypes:Vector.<int>, Sounds:Vector.<Sound>, channels:Vector.<DataStore>;
		private var currentPlayingSounds:int, maxPlayableSounds:int, maxPlayableOfType:int, soundTimers:Vector.<Boolean>;
		private var maximumSounds:int, soundLoops:Vector.<int>, Transforms:Vector.<SoundTransform>, tSoundsPlayed:uint;
		private var gSoundTransform:SoundTransform;
		/**
		 * public variables
		**/
		public function get soundsPlaying():int {
			return currentPlayingSounds;
		}
		public function get soundsPlayed():uint {
			return tSoundsPlayed;
		}
		/**
		 * constructor
		 * @param	int: maxSounds	 The maximum number of sounds the SoundManager can store (def: 4096)
		 * @param	int: maxPlayable	 Maxmum number sounds that can be playing at one time (def: 16)
		 * @param	int: maxOfTypePlayable	 Maxmum number of sounds of a specific type(id) that can be playing at one time (def: 4)
		 * @param	int: delayForPlays	 The delay (in milliseconds) before another sound of type(id) X can be played again (def: 15)
		 * @param	SoundTransform: defaultTransform	The default SoundTransform to apply to all sounds added to the manager (def: null)
		**/
		public function SoundManager(maxSounds:int = 4096, maxPlayable:int = 16, maxOfTypePlayable:int = 4, delayForPlays:int = 15, defaultTransform:SoundTransform = null):void {
			maxSounds = maximumSounds = min(maxSounds);
			maxPlayableSounds = min(maxPlayable);
			maxPlayableOfType = min(maxOfTypePlayable);
			timeDelay = min(delayForPlays);
			soundTypes = new Vector.<int>(maximumSounds, true);
			soundTimers = new Vector.<Boolean>(maximumSounds, true);
			Sounds = new Vector.<Sound>(maximumSounds, true);
			Transforms = new Vector.<SoundTransform>(maximumSounds, true);
			channels = new Vector.<DataStore>(maxPlayableSounds, true);
			soundLoops = new Vector.<int>(maxPlayableSounds, true);
			if ((gSoundTransform = defaultTransform)) while (maxSounds--) Transforms[maxSounds] = defaultTransform;
		}
		/**
		 * public functions
		**/
		/**
		 * addSound
		 * @param	Sound: snd	 The Sound object to add to the manager
		 * @param	SoundTransform: sndTransform	 The SoundTransform object to apply to all new instances of the sound (def: null)
		 * @return	int: The ID representing the sound type you just pushed into the manager
		 */
		public function addSound(snd:Sound, sndTransform:SoundTransform = null):int {
			var b:int = Sounds.indexOf(null);
			if (b == -1) throw new Error("There are no free slots left in the SoundManager."
									   + "  You must delete some sounds or increase the maximum number of sounds passed to the constructor.");
			Sounds[b] = snd;
			if (sndTransform) Transforms[b] = sndTransform;
			soundTypes[b] = 0;
			soundTimers[b] = true;
			return b;
		}
		/**
		 * addSoundAndPlay
		 * @param	Sound: snd	 The Sound object to add to the manager
		 * @param	int: loops	 The number of times the sound will run (def: 0)
		 * @param	SoundTransform: sndTransform	 A SoundTransform object for use with the sound (def: null)
		 * @param	Number: startTime	 The position to start playing the sound from (def: 0.0)
		 * @param	Function: callback	 A function that will be called when the sound completes (def: null)
		 * @param	SoundTransform: defaultSoundTransform	 The SoundTransform object to apply to all new instances of the sound (def: null)
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
		 * @param	int: loops	 The number of times the sound will run (def: 0)
		 * @param	SoundTransform: sndTransform	 A SoundTransform object for use with the sound (def: null)
		 * @param	Number: startTime	 The position to start playing the sound from (def: 0.0)
		 * @param	SoundTransform: defaultSoundTransform	 The SoundTransform object to apply to all new instances of the sound (def: null)
		 * @return	Object: An Object with the ID representing the sound type you just pushed into the manager as type and the ID of the now playing music as ID
		 */
		public function addMusicAndPlay(snd:Sound, loops:int = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0, defaultSoundTransform:SoundTransform = null):Object {
			var a:int = addSound(snd, defaultSoundTransform);
			var b:int = playMusic(a, loops, sndTransform, startTime);
			return new TempObject(a, b);
		}
		/**
		 * deleteSound
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	Boolean: stopPlayingAll	 Stop playing all sounds of type? (def: false)
		 * @return	Boolean: true if the sound was removed, false if an invalid type was given
		 */
		public function deleteSound(type:int, stopPlayingAll:Boolean = false):Boolean {
			if (valid(type)) {
				if (stopPlayingAll) stopAll(type);
				Sounds[type] = null;
				Transforms[type] = null;
				soundTypes[type] = 0;
				soundTimers[type] = false;
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
		 * @param	Number: loops	 the number of times the sound will run, the value Infinity will continuously run (def: 0)
		 * @param	SoundTransform: sndTransform	 A SoundTransform object for use with the sound (def: null)
		 * @param	Number: startTime	 The position to start playing the sound from (def: 0.0)
		 * @param	Function: callback	 A function that will be called when the sound completes (def: null)
		 * @return	int: The ID of the now playing SoundChannel object, -2 if an invalid type, or -3 if the type can't be played
		 */
		public function playSound(type:int, loops:Number = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0, callback:Function = null):int {
			if (valid(type)) {
				if (canPlay(type)) {
					increment(type);
					var b:int = channels.indexOf(null);
					(channels[b] = new DataStore(Sounds[type], type, loops, soundEnded, sndTransform || Transforms[type], callback)).play(startTime);
					return b;
				}
				return -3
			} else {
				throw new Error("Sound #" + type + " does not exist.", 2068);
			}
			return -2;
		}
		/**
		 * playMusic
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	Number: loops	 the number of times the sound will run, the value Infinity will continuously run (def: 0)
		 * @param	SoundTransform: sndTransform	 a SoundTransform object for use with the sound (def: null)
		 * @param	Number: startTime	 the position to start playing the sound from (def: 0.0)
		 * @return	int: The ID of the now playing SoundChannel object, -2 if an invalid type, or -3 if the type can't be played
		 */
		public function playMusic(type:int, loops:Number = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0):int {
			return playSound(type, loops, sndTransform, startTime, null);
		}
		/**
		 * stopMusic
		 * @param	int: id	 An ID returned by playMusic or playSound
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
		 * stopSound
		 * @param	int: id	 An ID returned by playMusic or playSound
		 * @return	Boolean: true if the sound was sucessfully stopped
		 */
		public function stopSound(id:int):Boolean {
			if (validC(id)) {
				channels[id].stop();
				return true;
			}
			return false;
		}
		/**
		 * stopAll
		 * @param	int: type	The ID of a sound added to the manager, or -1 for all (def: -1)
		 * @return	Boolean: true if all sounds were stopped.
		 */
		public function stopAll(type:int = -1):Boolean {
			var i:int = maxPlayableSounds, b:DataStore;
			if (type == -1) {
				while (i--) {
					if ((b = channels[i])) {
						b.stop();
					}
				}
				return true;
			} else if (valid(type)) {
				while (i--) {
					if ((b = channels[i]) && b.id == type) {
						b.stop();
					}
				}
				return true;
			}
			return false;
		}
		/**
		 * pause
		 * @param	int: id	 An ID returned by playMusic or playSound
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
		 * unpause
		 * @param	int: id	 An ID returned by playMusic or playSound
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
		 * pauseAll
		 * @param	int: type	The ID of a sound added to the manager or -1 for all sounds playing (def: -1)
		 * @return	Boolean: true if the type provided was valid, or if -1 was passed; false if the type is invalid
		 */
		public function pauseAll(type:int = -1):Boolean {
			var i:DataStore;
			if (type == -1) {
				for each(i in channels) {
					if (i) i.pause();
				}
				return true;
			} else if (valid(type)) {
				for each(i in channels) {
					if (i) if(i.id == type) i.pause();
				}
				return true
			}
			return false;
		}
		/**
		 * unpauseAll
		 * @param	int: type	The ID of a sound added to the manager or -1 for all sounds (def: -1)
		 * @return	Boolean: true if the type provded was valid, or if -1 was passed; false if the type is invalid
		 */
		public function unpauseAll(type:int = -1):Boolean {
			var i:DataStore;
			if (type == -1) {
				for each(i in channels) {
					if (i) i.unpause();
				}
				return true;
			} else if (valid(type)) {
				for each(i in channels) {
					if (i) if(i.id == type) i.unpause();
				}
				return true
			}
			return false;
		}
		/**
		 * isPaused
		 * @param	int: id	 An ID returned by playMusic or playSound
		 * @return	Boolean: true if paused, otherwise false
		 */
		public function isPaused(id:int):Boolean {
			if (validC(id)) {
				return channels[id].paused;
			}
			return false;
		}
		/**
		 * setSoundTransform
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	SoundTransform: sndTransform	 The transform to set (def: null)
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
		 * @return	SoundTransform: The SoundTransfrom currently applied to the sound type or null if an invalid type
		 */
		public function getSoundTransform(type:int):SoundTransform {
			if (valid(type)) {
				return Transforms[type] || new SoundTransform(1, 0);
			}
			return null;
		}
		/**
		 * setGlobalSoundTransform
		 * @param	SoundTransform: soundTransform	The sound transform to apply to all sounds
		 * @param	Boolean: _override	Override the SoundTransform a sound already has (def: false)
		 */
		public function setGlobalSoundTransform(soundTransform:SoundTransform, _override:Boolean = false):void {
			gSoundTransform = soundTransform;
			var i:int = maxPlayableSounds;
			if (_override) {
				while (i--) {
					Transforms[i] = soundTransform;
				}
			} else {
				while (i--) {
					if (!Transforms[i]) Transforms[i] = soundTransform;
				}
			}
		}
		/**
		 * getGlobalSoundTransform
		 * @return	SoundTransform: The current sound transform applied to all sounds that haven't overridden it.
		 */
		public function getGlobalSoundTransform():SoundTransform {
			return gSoundTransform;
		}
		/**
		 * changeVolume
		 * @author	UnknownGuardian
		 * @param	int: id	 An ID returned by playMusic or playSound or -1 for all currently playing or paused sounds (def: -1)
		 * @param	Number: volume	 The volume to set it to (def: 1)
		 * @return	Boolean: true if the sound volume was succssfully changed
		 * @update	15/6/2010(skyboy): Added method, changed to use setTransform, and made it so other parts of the tasnform aren't changed
		 */
		public function changeVolume(id:int = -1, volume:Number = 1):Boolean {
			if (validC(id)) {
				var sT:SoundTransform = getTransform(id) || new SoundTransform;
				sT.volume = volume;
				return setTransform(id, sT);
			} else if (id == -1) {
				var a:SoundTransform;
				for each (var channel:DataStore in channels) {
					if (channel) {
						a = channel.getTransform() || new SoundTransform;
						a.volume = volume;
						channel.setTransform(a);
					}
				}
				return true;
			}
			return false;
		}
		/**
		 * changeSoundVolume
		 * @param	int: type	 The ID of a sound added to the manager
		 * @param	Number: volume	 A Number to set the volume to (def: 1)
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
		 * changeGlobalVolume
		 * @param	Number: volume	The volume to set on all playing sounds and Sound objects in the manager.
		 */
		public function changeGlobalVolume(volume:Number):void {
			var i:int = maxPlayableSounds, a:SoundTransform;
			while (i--) {
				changeSoundVolume(i, volume);
			}
			for each (var channel:DataStore in channels) {
				if (channel) {
					a = channel.getTransform() || new SoundTransform;
					a.volume = volume;
					channel.setTransform(a);
				}
			}
		}
		/**
		 * setTransform
		 * @param	int: id	 An ID returned by playMusic or playSound
		 * @param	SoundTransform: sndTransform	 The transform to apply (def: null)
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
		 * @param	int: id	 An ID returned by playMusic or playSound
		 * @return	SoundTransform: The sound transfrom or null
		 */
		public function getTransform(id:int):SoundTransform {
			if (validC(id)) {
				return channels[id].getTransform();
			}
			return null;
		}
		/**
		 * private functions
		**/
		private function valid(id:uint):Boolean {
			return id < maximumSounds && Sounds[id];
		}
		private function validC(id:uint):Boolean {
			return id < maxPlayableSounds && channels[id];
		}
		private function increment(id:int):void {
			++tSoundsPlayed;
			++currentPlayingSounds;
			++soundTypes[id];
			switchTypeCanPlay(id);
			setTimeout(switchTypeCanPlay, timeDelay, id);
		}
		private function canPlay(id:int):Boolean {
			return soundTimers[id] && currentPlayingSounds < maxPlayableSounds && soundTypes[id] < maxPlayableOfType;
		}
		private function switchTypeCanPlay(id:int):void {
			soundTimers[id] = !soundTimers[id];
		}
		private function soundEnded(id:int, dStore:DataStore):void {
			if (dStore) {
				var b:int = channels.indexOf(dStore);
				if (~b && b < maxPlayableSounds) {
					channels[b] = null;
				}
			}
			--soundTypes[id];
			--currentPlayingSounds;
		}
		private function min(x:uint):int {
			return x > int.MAX_VALUE ? int.MAX_VALUE : x;
		}
	}
}
final internal class DataStore {
	private var sChannel:flash.media.SoundChannel, s:flash.media.Sound, loops:int, sT:flash.media.SoundTransform;
	private var pausePos:Number = 0, finitePlays:Boolean, listener:Function, _p:Boolean = false, _id:int, sE:Function;
	private function listenerRepeater(e:flash.events.Event):void {
		var b:flash.media.SoundChannel = e.target as flash.media.SoundChannel;
		b.removeEventListener(e.type, listenerRepeater);
		if (loop()) {
			sE(_id, this);
			if (listener != null) {
				b.addEventListener(e.type, listener);
				listener(e);
			}
		}
	}
	public function get id():int {
		return _id;
	}
	public function DataStore(_s:flash.media.Sound, id:int, _loops:Number, SE:Function, _sT:flash.media.SoundTransform = null, callback:Function = null) {
		s = _s;
		sT = _sT;
		_id = id;
		sE = SE;
		listener = callback;
		setLoops(_loops);
	}
	public function loop():Boolean {
		if (loops > 0) {
			play();
			if (finitePlays) --loops;
			return false;
		}
		return true;
	}
	public function play(startTime:Number = 0.0, _loops:Number = NaN):DataStore {
		setLoops(_loops);
		if (sChannel) sChannel.stop();
		(sChannel = s.play(startTime, 0, sT)).addEventListener(flash.events.Event.SOUND_COMPLETE, listenerRepeater, false, 0, false);
		return this;
	}
	public function setLoops(_loops:Number):void {
		if (_loops == _loops) { // this is to make sure it's not NaN (NaN == NaN is false, NaN != NaN is true)
			if ((finitePlays = _loops != Infinity)) {
				loops = _loops < 0 ? 0 : _loops < int.MAX_VALUE ? _loops : int.MAX_VALUE;
			} else {
				loops = 1;
			}
		}
	}
	public function stop():void {
		if (sChannel) {
			loops = 0;
			sChannel.stop();
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
			(sChannel = s.play(pausePos, 0, sT)).addEventListener(flash.events.Event.SOUND_COMPLETE, listenerRepeater, false, 0, false);
			pausePos = 0;
			_p = false;
		}
	}
	public function get paused():Boolean {
		return _p;
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
		if (sChannel) sChannel.soundTransform = t;
	}
	/**
	 * getTransform
	 * @return SoundTransform: the SoundTransform that gets applied to the playing sound
	 */
	public function getTransform():flash.media.SoundTransform {
		if (!sT) return sT = new flash.media.SoundTransform;
		return sT;
	}
}
final internal class TempObject extends Object {
	public var ID:int, id:int, type:int;
	public function TempObject(__type:int, _ID:int):void {
		type = __type;
		ID = id = _ID;
	}
}
