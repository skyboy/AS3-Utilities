package skyboy.kongregate {
	/**
	 * UserData by skyboy. November 5th 2010.
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
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	public class UserData {
		public static const errorID:uint = 0xA9C0;
		public static const NOT_STARTED:uint = 0;
		public static const LOADING_USER:uint = 1;
		public static const LOADED_USER:uint = 2;
		public static const LOADING_FRIENDS:uint = 3;
		public static const COMPLETE:uint = 4;
		public static const ERROR:uint = 5;
		private static const ADMINISTRATOR:uint = 0x10;
		private static const MODERATOR:uint = 0x000008;
		private static const CURATOR:uint = 0x00000004;
		private static const FORUM_MOD:uint = 0x000002;
		private static const DEVELOPER:uint = 0x000001;
		private static const USER:uint = 0x00000000000;
		public function UserData(username:String = null, callback:Function = null):void {
			if (username && callback != null) loadUser(username, callback);
		}
		protected var _silenced:Boolean, _mutual:Boolean;
		protected var _friends:Object, _friendlist:Array, _callback:Function;
		protected var _age:int, _level:int, inx:int, p:int, friendCount:int, _points:uint, _kreds:uint, _status:uint, _id:uint;
		protected var _username:String, _gender:String, _game:String, _gameTitle:String, _friendOf:String, _avatar:String, _chatAvatar:String;
		public function getFriend(username:String):UserData {
			if (!_friends) return null;
			return _friends[username];
		}
		public function eachFriend(closure:Function):void {
			for(var i:String in _friends) {
				try {
					closure(i, _friends[i]);
				} catch (e:Error) {
					var a:Error = new Error("An Error occured for friend " + i + ".\n" + e.message);
					delayedError(a);
				}
			}
		}
		protected function delayedError(a:*, Throw:Boolean = false):void {
			if (Throw) throw a;
			else setTimeout(delayedError, 0, a, true);
		}
		public function get progress():int {
			return p;
		}
		public function get friends():uint {
			return friendCount;
		}
		public function get friendsList():Array {
			if (!_friendlist) return [];
			return _friendlist.slice();
		}
		public function get username():String {
			return _username;
		}
		public function get avatar():String {
			return _avatar;
		}
		public function get chatAvatar():String {
			return _chatAvatar;
		}
		public function get gender():String {
			return _gender;
		}
		public function get id():uint {
			return _id;
		}
		public function get points():uint {
			return _points;
		}
		public function get status():uint {
			return _status;
		}
		public function get silenced():Boolean {
			return _silenced;
		}
		public function get age():uint {
			return _age;
		}
		public function get level():uint {
			return _level;
		}
		public function isMod():Boolean {
			return (_status & MODERATOR) != 0;
		}
		public function isAdmin():Boolean {
			return (_status & ADMINISTRATOR) != 0;
		}
		public function isDev():Boolean {
			return (_status & DEVELOPER) != 0;
		}
		public function isCurator():Boolean {
			return (_status & CURATOR) != 0;
		}
		public function isForumMod():Boolean {
			return (_status & FORUM_MOD) != 0;
		}
		public function get mutual():Boolean {
			return false;
		}
		public function equals(o:UserData):Boolean {
			return o._id == _id;
		}
		public function toString():String {
			return _username;
		}
		public function loadFriends(reload:Boolean = false):void {
			if (p == 4 && reload) {
				var i:int = friendCount;
				inx = i;
				l = 0;
				i = 5;
				while (i--) {
					 doThing();
				}
			}
		}
		public function loadUser(username:String, callback:Function):void {
			if (!username || callback == null) throw new Error("You must provide both a username and a callback to "+UserData+".");
			friendCount = _id = _age = _level = _points = _status = _kreds = p = 0;
			_friends = { };
			_friendOf = _username = _game = _gameTitle = _avatar = "";
			_mutual = _silenced = false;
			_username = username;
			_callback = callback;
			var b:URLRequest = new URLRequest("http://api.kongregate.com/api/user_info.json?friends=true&username=" + username);
			var c:URLLoader = new URLLoader();
			c.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			c.addEventListener(IOErrorEvent.IO_ERROR, onError);
			c.addEventListener(Event.COMPLETE, loadUserComplete);
			c.load(b);
			p = 1;
		}
		protected function loadUserComplete(e:Event):void {
			var d:String = e.target.data, i:int;
			if (d.indexOf('"success":true') == -1) {
				p = 5;
				d = "(" + _username + ") " + d.substring(i = d.indexOf('n":"') + 4, d.indexOf('"', i));
				_username = null;
				delayedError(new Error(d, errorID), true);
			} else if (d.indexOf('"private":false') == -1) {
				p = 5;
				d = "The Profile of " + d.substring(i = d.indexOf('"username":"') + 12, d.indexOf('"', i)) + " is private";
				_username = null;
				delayedError(new Error(d, errorID), true);
			}
			_status = int(d.indexOf('"admin":false') == -1) << 4 | int(d.indexOf('"curator":false') == -1) << 2 | int(d.indexOf('"moderator":false') == -1) << 3 | int(d.indexOf('"forum_moderator":false') == -1) << 1 | int(d.indexOf('"developer":false') == -1);
			_points = parseInt(d.substring(i = d.indexOf('"points":') + 9, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			_level = parseInt(d.substring(i = d.indexOf('"level":') + 8, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			_id = parseInt(d.substring(i = d.indexOf('"user_id":') + 10, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			_age = parseInt(d.substring(i = d.indexOf('"age":') + 6, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			_chatAvatar = d.substring(i = d.indexOf('"chat_avatar_url":"') + 19, d.indexOf('"', i));
			_avatar = d.substring(i = d.indexOf('"avatar_url":"') + 14, d.indexOf('"', i));
			_username = d.substring(i = d.indexOf('"username":"') + 12, d.indexOf('"', i));
			_gender = d.substring(i = d.indexOf('"gender":"') + 10, d.indexOf('"', i));
			p = 2;
			var friendsA:Array = d.substring(i = d.indexOf('"friends":[') + 11, d.indexOf(']', i)).replace(/"/g, "").split(',');
			_friendlist = friendsA;
			i = friendsA.length;
			inx = i;
			friendCount = i;
			i = 5;
			while (i--) {
				if (inx > 0) loadFriend(_friendlist[--inx]);
			}
			p = 3;
		}
		protected function loadFriend(a:String):void {
			_friends[a] = new FriendData(a, _username, doThing);
		}
		protected var l:uint;
		protected function doThing():void {
			if (p == 3) {
				++l;
				if (l >= friendCount) {
					setTimeout(_callback, 0, this);
					p = 4;
				}
			}
			if (inx > 0) loadFriend(_friendlist[--inx]);
		}
		protected function onError(e:Event):void {
			p = 5;
			delayedError(new Error("<" + e.type + "> has occured while trying to load a file.", errorID), true);
		}
	}
}
import flash.events.Event;
internal class FriendData extends skyboy.kongregate.UserData {
	private var _loadFriends:Boolean, calledback:Boolean;
	public function set constructor(a:*):void { }
	public function get constructor():Class {
		return skyboy.kongregate.UserData;
	}
	public function FriendData(username:String, friendOf:String, callback:Function):void {
		super(username, callback);
		_friendOf = friendOf
	}
	public override function get mutual():Boolean {
		return _mutual;
	}
	protected override function loadUserComplete(e:Event):void {
		try {
			super.loadUserComplete(e);
			_mutual = _friendlist.indexOf(_friendOf) != -1;
		} catch (a:Error) {
			delayedError(a);
		}
		if (!calledback) {
			_callback();
			calledback = true;
			_callback = equals;
			p = 4;
		}
	}
	protected override function loadFriend(a:String):void {
		if (_loadFriends) super.loadFriend(a);
		else if (!calledback) {
			_callback();
			calledback = true;
			_callback = equals;
			p = 4;
		}
	}
	public override function loadFriends(reload:Boolean = false):void {
		if (!_loadFriends || (p == 4 && reload)) {
			_loadFriends = true;
			var i:int = friendCount;
			inx = i;
			if (i > 5) i = 5;
			l = 0;
			while (i--) {
				 doThing();
			}
		}
	}
	protected override function onError(e:Event):void {
		if (!calledback) {
			_callback();
			calledback = true;
			_callback = equals;
			p = 4;
		}
		super.onError(e);
	}
}
