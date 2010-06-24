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
	 * files (the "Software"), to deal in the Software without
	 * restriction, including without limitation the rights to use,
	 * copy, modify, merge, publish, distribute, sublicense, and/or sell
	 * copies of the Software, and to permit persons to whom the
	 * Software is furnished to do so, subject to the following
	 * conditions:
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
	 */
	/**
	 * @editor	UnknownGuardian
	 * @editor
	 */
	public class SoundManager {
		/**
		 * protected variables
		**/
		protected var soundTypes:Vector.<int>, Sounds:Vector.<Sound>, soundNumber:int = 0, timeDelay:int = 50, channels:Vector.<DataStore>;
		protected var currentPlayingSounds:int = 0, maxPlayableSounds:int = 16, maxPlayableOfType:int = 4, soundTimers:Vector.<Boolean>;
		protected var soundLoops:Vector.<int>, Transforms:Vector.<SoundTransform>;
		/**
		 * public variables
		**/
		public function get soundsPlaying():int {
			return currentPlayingSounds;
		}
		public function set soundsPlaying(a:int):void {
		}
		/**
		 * constructor
		 * @param	maxSounds: the maximum number of sounds the SoundManager can store (4096)
		 * @param	maxPlayable: maxmum number sounds that can be playing at one time (16)
		 * @param	maxOfTypePlayable: maxmum number of sounds of a specific type(id) that can be playing at one time (4)
		 * @param	delayForPlays: the delay (in milliseconds) before another sound of type(id) X can be played again
		**/
		public function SoundManager(maxSounds:int = 4096, maxPlayable:int = 16, maxOfTypePlayable:int = 4, delayForPlays:int = 15) {
			soundTypes = new Vector.<int>(maxSounds, true);
			soundTimers = new Vector.<Boolean>(maxSounds, true);
			Sounds = new Vector.<Sound>(maxSounds, true);
			Transforms = new Vector.<SoundTransform>(maxSounds, true);
			channels = new Vector.<DataStore>(maxPlayable, true);
			soundLoops = new Vector.<int>(maxPlayable, true);
			maxPlayableSounds = maxPlayable;
			maxPlayableOfType = maxOfTypePlayable;
			timeDelay = Math.min(Math.abs(delayForPlays) + 1, int.MAX_VALUE);
		}
		/**
		 * public functions
		**/
		/**
		 * addSound
		 * @param	snd: the Sound object to add to the manager
		 * @return	int: the ID representing the sound you just pushed into the manager
		 */
		public function addSound(snd:Sound, sndTransform:SoundTransform = null):int {
			Sounds[soundNumber] = snd;
			Transforms[soundNumber] = sndTransform;
			soundTypes[soundNumber] = 0;
			soundTimers[soundNumber] = true;
			return soundNumber++;
		}
		/**
		 * soundsOfTypePlaying
		 * @param	id: the ID of a sound added to the manager
		 * @return	int: how many sounds with that ID are currently playing
		 */
		public function soundsOfTypePlaying(id:int):int {
			return soundTypes[id];
		}
		/**
		 * playSound
		 * @param	id: the ID of a sound added to the manager
		 * @param	loops: the number of times the sound will run (0)
		 * @param	sndTransform: a SoundTransform object for use with the sound (null)
		 * @param	startTime: the position to start playing the sound from (0.0)
		 * @param	callback: a function that will be called when the sound completes
		 * @return	Boolean: true if the sound was sucessfully started playing
		 */
		public function playSound(id:int, loops:int=0, sndTransform:SoundTransform=null, startTime:Number=0.0, callback:Function=null):Boolean {
			if (valid(id)) {
				if (canPlay(id)) {
					increment(id);
					sndTransform ||= Transforms[id];
					var a:DataStore = new DataStore(Sounds[id], loops, sndTransform);
					a.play(startTime);
					callback ||= function(e:Event):void{ };
					a.addEventListener(Event.SOUND_COMPLETE, function(e:Event):void { soundEnded(e, id, null); callback.call(null, e); } );
					return true;
				}
			} else {
				throw new Error("Sound #" + id + " does not exist.", 2068);
			}
			return false;
		}
		/**
		 * playMusic
		 * @param	id: the ID of a sound added to the manager
		 * @param	loops: the number of times the sound will run (0)
		 * @param	sndTransform: a SoundTransform object for use with the sound (null)
		 * @param	startTime: the position to start playing the sound from (0.0)
		 * @return	int: the ID of the now playing SoundChannel object
		 */
		public function playMusic(id:int, loops:int = 0, sndTransform:SoundTransform = null, startTime:Number = 0.0):int {
			if (valid(id)) {
				if (canPlay(id)) {
					increment(id);
					sndTransform ||= Transforms[id];
					var a:DataStore = new DataStore(Sounds[id], loops, sndTransform);
					a.play(startTime);
					a.addEventListener(Event.SOUND_COMPLETE, function(e:Event, func:Function = null):void { e.target.removeEventListener(e.type, arguments.callee); soundEnded(e, id, a); } );
					var b:int = channels.indexOf(null);
					channels[b] = a;
					return b;
				}
			} else {
				throw new Error("Sound #" + id + " does not exist.", 2068);
			}
			return -1;
		}
		/**
		 * stopMusic
		 * @param	id: an ID returned by playMusic
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
		 * changeSoundVolume
		 * @param	id: an ID returned by playMusic or playSound
		 * @param	volume: a number to set the volume to
		 * @return	Boolean: true if the sound volume was succssfully changed
		 */
		public function changeSoundVolume(id:int, volume:Number = 1):Boolean {
			if (valid(id)) {
				var sT:SoundTransform = getSoundTransform(id);
				sT.volume = volume;
				return setSoundTransform(id, sT);
			}
			return false;
		}
		/**
		 * setSoundTransform
		 * @param	id: an ID returned by playMusic
		 * @param	sndTransform: the transform to set
		 * @return	Boolean: true if the transform was applied sucessfully
		 */
		public function setSoundTransform(id:int, sndTransform:SoundTransform):Boolean {
			if (valid(id)) {
				Transforms[id] = sndTransform;
				return true;
			}
			return false;
		}
		/**
		 * getSoundTransform
		 * @param	id: an ID returned by playMusic
		 * @return	SoundTransform: the sound transfrom or null
		 */
		public function getSoundTransform(id:int):SoundTransform {
			if (valid(id)) {
				return Transforms[id] || new SoundTransform(1, 0);
			}
			return null;
		}
		/**
		 * changeVolume
		 * @author	UnknownGuardian
		 * @param	id: an ID returned by playMusic or playSound
		 * @return	Boolean: true if the sound volume was succssfully changed
		 * @update	15/6/2010(skyboy): added method, changed to use setTransform, and made it so other parts of the tasnform aren't changed
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
		 * @param	id: an ID returned by playMusic
		 * @param	sndTransform: the transform to apply
		 * @return	Boolean: true if the transform was applied sucessfully
		 */
		public function setTransform(id:int, sndTransform:SoundTransform):Boolean {
			if (validC(id)) {
				channels[id].setTransform(sndTransform);
				return true;
			}
			return false;
		}
		/**
		 * getTransform
		 * @param	id: an ID returned by playMusic
		 * @return	SoundTransform: the sound transfrom or null
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
			return id > -1 && id < Sounds.length && Sounds[id];
		}
		protected function validC(id:int):Boolean {
			return id > -1 && id < channels.length && channels[id];
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
				if (~b) {
					channels[b] = null;
				}
			}
			--soundTypes[id];
			--currentPlayingSounds;
		}
	}
}
internal class DataStore {
	private var sChannel:flash.media.SoundChannel, s:flash.media.Sound, loops:int, listner:Array, sT:flash.media.SoundTransform;
	public function DataStore(_s:flash.media.Sound, _loops:int, _sT:flash.media.SoundTransform = null) {
		s = _s;
		sT = _sT;
		loops = _loops;
		var a:DataStore = this;
		listner = [flash.events.Event.SOUND_COMPLETE, function(e:flash.events.Event):void { e.target.removeEventListener(e.type, arguments.callee); if (a.listner[1] == arguments.callee) loop(); else { e.target.addEventListener(e.type, a.listner[1]); e.target.dispatchEvent(e); } }, false, 0, false];
	}
	public function loop():Boolean {
		if (loops > 0) {
			play();
			return false;
		}
		return true;
	}
	public function play(startTime:Number = 0.0, _loops:Number = NaN):DataStore {
		if (!isNaN(_loops)) {
			loops = Math.max(0, int(_loops));
		}
		--loops;
		(sChannel = s.play(startTime, 0, sT)).addEventListener.apply(sChannel, listner);
		return this;
	}
	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
		var a:DataStore = this;
		listner = [type, function(e:flash.events.Event):void { e.target.removeEventListener(e.type, arguments.callee); var remove:Boolean = loop(); if (remove) { if (listener.length == 2) try { listener(e, a); return; } catch (er:*) { } e.target.addEventListener(e.type, listener, useCapture, priority, useWeakReference); e.target.dispatchEvent(e) } }, useCapture, priority, useWeakReference];
	}
	public function stop():void {
		loops = 0;
		sChannel.stop();
		sChannel.dispatchEvent(new flash.events.Event(flash.events.Event.SOUND_COMPLETE));
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
		if (!sChannel) return;
		sChannel.soundTransform = sT = t;
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
