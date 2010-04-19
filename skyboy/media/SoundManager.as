package skyboy.media {
	/**
	 * imports
	 */
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	/**
	 * @author skyboy
	 */
	public class SoundManager {
		/**
		 * protected variables
		**/
		protected var soundTypes:Vector.<int>, Sounds:Vector.<Sound>, soundNumber:int = 0, timeDelay:int = 50, channels:Vector.<DataStore>;
		protected var currentPlayingSounds:int = 0, maxPlayableSounds:int = 16, maxPlayableOfType:int = 4, soundTimers:Vector.<Boolean>;
		protected var soundLoops:Vector.<int>;
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
			channels = new Vector.<DataStore>(maxPlayable, true);
			soundLoops = new Vector.<int>(maxPlayable, true);
			maxPlayableSounds = maxPlayable;
			maxPlayableOfType = maxOfTypePlayable;
			timeDelay = Math.abs(delayForPlays) + 1;
		}
		/**
		 * public functions
		**/
		/**
		 * addSound
		 * @param	snd: the Sound object to add to the manager
		 * @return	int: the ID representing the sound you just pushed into the manager
		 */
		public function addSound(snd:Sound):int {
			Sounds[soundNumber] = snd;
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
			if (Sounds[id]) {
				if (canPlay(id)) {
					increment(id);
					var a:DataStore = new DataStore(Sounds[id], loops, sndTransform);
					a.play(startTime);
					callback ||= function(e:Event):void{ };
					a.addEventListener(Event.SOUND_COMPLETE, function(e:Event):void { soundEnded(e, id, arguments.callee); callback.call(null, e); } );
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
			if (id < Sounds.length && Sounds[id]) {
				if (canPlay(id)) {
					increment(id);
					var a:DataStore = new DataStore(Sounds[id], loops, sndTransform);
					a.play(startTime);
					a.addEventListener(Event.SOUND_COMPLETE, function(e:Event, func:Function = null):void { soundEnded(e, id, a); } );
					var b:int = channels.indexOf(null);
					channels[b] = a;
					return b;
				}
			} else {
				throw new Error("Sound #" + id + " does not exist.", 2068);
			}
			return NaN;
		}
		/**
		 * stopMusic
		 * @param	id: an ID returned by playMusic
		 * @return	Boolean: true if the sound was sucessfully stopped
		 */
		public function stopMusic(id:int):Boolean {
			if (channels[id]) {
				try {
					channels[id].stop();
					channels[id].dispatchEvent(new Event(Event.SOUND_COMPLETE));
					return true;
				}catch(e:*) {
					trace("Error >>", e);
				}
			}
			return false;
		}
		/**
		 * protected functions
		**/
		protected function increment(id:int):void {
			++currentPlayingSounds;
			++soundTypes[id];
			switchTypeCanPlay(id);
			var a:Timer = new Timer(timeDelay);
			a.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void { switchTypeCanPlay(id); e.target.removeEventListener(TimerEvent.TIMER, arguments.callee); e.target.stop(); } );
			a.start();
		}
		protected function canPlay(id:int):Boolean {
			return soundTimers[id] && currentPlayingSounds < maxPlayableSounds && soundTypes[id] < maxPlayableOfType;
		}
		protected function switchTypeCanPlay(id:int):void {
			soundTimers[id] = !soundTimers[id];
		}
		protected function soundEnded(e:Event, id:int, dStore:DataStore):void {
			var b:int = channels.indexOf(dStore);
			if (~b) {
				channels[b] = null;
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
		listner = [flash.events.Event.SOUND_COMPLETE, function(e:flash.events.Event):void { loop(); }, false, 0, false];
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
		listner = [type, function(e:flash.events.Event):void { e.target.removeEventListener(e.type, arguments.callee); var remove:Boolean = loop(); if (remove) { if (listener.length == 2) try { listener(e, a); return; } catch (er:*) { } e.target.addEventListener(e.type, listener, useCapture, priority, useWeakReference); e.target.dispatchEvent( new flash.events.Event(e.type) ) } }, useCapture, priority, useWeakReference];
	}
	public function stop():void {
		loops = 0;
		sChannel.stop();
		sChannel.dispatchEvent(new flash.events.Event(flash.events.Event.SOUND_COMPLETE));
	}
	public function dispatchEvent(...Void):void {
	}
}
