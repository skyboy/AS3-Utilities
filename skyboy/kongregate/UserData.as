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
		public function UserData(username:String = null, callback:Function = null) {
			if (username && callback != null) loadUser(username, callback);
			else setTimeout(thrower, 0, new Error("You must provide both a username and a callback to "+UserData+"."));
		}
		private var _callback:Function;
		public static const errorID:int = 0xA9C0;
		public static const ADMINISTRATOR:uint = 0x10;
		public static const MODERATOR:uint = 0x000008;
		public static const CURATOR:uint = 0x00000004;
		public static const FORUM_MOD:uint = 0x000002;
		public static const DEVELOPER:uint = 0x000001;
		public static const USER:uint = 0x00000000000;
		private var p:int;
		public function get progress():int {
			return p;
		}
		public function get friends():uint {
			return friendCount;
		}
		public function getFriend(username:String):Object {
			if (!_friends) return null;
			return _friends[username];
		}
		public function eachFriend(closure:Function, thisObj:* = null):void {
			var i:String;
			if (thisObj == this) {
				thisObj = null;
			}
			for(i in _friends) {
				try {
					closure.call(thisObj, i, _friends[i]);
				} catch (e:Error) {
					var a:Error = new Error("An Error occured for friend " + i + ".\n" + e.message);
					setTimeout(thrower, 0, a);
				}
			}
		}
		private function thrower(a:*):void { throw a }
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
		public function get gender():String {
			return _gender;
		}
		public function get game():String {
			return _game;
		}
		public function get gameTitle():String {
			return _gameTitle;
		}
		public function get kreds():uint {
			return _kreds;
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
		private var _age:int, _level:int, _points:uint, _avatar:String, _kreds:uint, _id:uint;
		private var _friends:Object, _friendlist:Array, friendCount:int, _username:String, _gender:String;
		private var _status:uint, _silenced:Boolean, _game:String, _gameTitle:String, inx:int;
		public function equals(o:UserData):Boolean {
			return o.id == _id;
		}
		public function loadUser(username:String, callback:Function):void {
			friendCount = _id = _age = _level = _points = _status =  _kreds = p = 0;
			_friends = { }, _username = _game = _gameTitle = _avatar = "", _silenced = false;
			_callback = callback;
			var b:URLRequest = new URLRequest("http://api.kongregate.com/api/user_info.json?friends=true&username=" + username);
			var c:URLLoader = new URLLoader();
			c.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			c.addEventListener(IOErrorEvent.IO_ERROR, onError);
			c.addEventListener(Event.COMPLETE, loadUserComplete);
			c.load(b);
			p = 1;
		}
		private function loadUserComplete(e:Event):void {
			var d:String = e.target.data, i:int;
			if (d.indexOf('"success":true') == -1) {
				p = 5;
				throw new Error(d.substring(i = d.indexOf('n":"') + 4, d.indexOf('"', i)), errorID);
			} else if (d.indexOf('"private":false') == -1) {
				p = 5;
				throw new Error("The Profile of " + d.substring(i = d.indexOf('"username":"') + 12, d.indexOf('"', i)) + " is private", errorID);
			}
			i = d.lastIndexOf('}');
			_id = parseInt(d.substring(i = d.indexOf('"user_id":') + 10, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			_username = d.substring(i = d.indexOf('"username":"') + 12, d.indexOf('"', i));
			_avatar = d.substring(i = d.indexOf('"avatar_url":"') + 14, d.indexOf('"', i));
			_gender = d.substring(i = d.indexOf('"gender":"') + 10, d.indexOf('"', i));
			if ((i = d.indexOf('"game_title":"')) != -1) {
				_gameTitle = d.substring(i += 14, d.indexOf('"', i));
				_game = d.substring(i = d.indexOf('"game_url":"') + 12, d.indexOf('"', i));
			}
			_silenced = d.indexOf('"silenced_until":') != -1;
			_status = int(d.indexOf('"admin":false') == -1) << 4 | int(d.indexOf('"curator":false') == -1) << 2 | int(d.indexOf('"moderator":false') == -1) << 3 | int(d.indexOf('"forum_moderator":false') == -1) << 1 | int(d.indexOf('"developer":false') == -1);
			_points = parseInt(d.substring(i = d.indexOf('"points":') + 9, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			_level = parseInt(d.substring(i = d.indexOf('"level":') + 8, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			_age = parseInt(d.substring(i = d.indexOf('"age":') + 6, (d.indexOf(',', i) + 1 || d.indexOf('}', i) + 1) - 1), 10);
			p = 2;
			var friendsA:Array = (_friendlist = d.substring(i = d.indexOf('"friends":[') + 11, d.indexOf(']', i)).replace(/"/g, "").split(',')).slice();
			friendCount = i = friendsA.length;
			if (i > 5) i = 5;
			inx = friendCount - i;
			while (i--) {
				d = friendsA.pop();
				_friends[d] = false;
				loadFriend(d);
			}
			p = 3;
		}
		private function loadFriend(a:String):void {
			var b:URLRequest = new URLRequest("http://api.kongregate.com/api/user_info.json?friends=trueusername=" + a);
			var c:URLLoader = new URLLoader();
			c.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFError);
			c.addEventListener(IOErrorEvent.IO_ERROR, onFError);
			c.addEventListener(Event.COMPLETE, loadFriendComplete);
			setTimeout(callLoad, 250, c, b);
		}
		private function callLoad(c:URLLoader, b:URLRequest):void {
			c.load(b);
		}
		private var l:uint;
		private function loadFriendComplete(e:Event):void {
			var d:String = e.target.data, i:int;
			doThing();
			if (d.indexOf('"success":true') == -1) {
				return;
			} else if (d.indexOf('"private":false') == -1) {
				return;
			}
			i = d.lastIndexOf('}');
			var u:String = d.substring(i = d.indexOf('"username":"') + 12, d.indexOf('"', i));
			var data:Object = _friends[u] = { game:null, title:null, avatar:null, mutual:null, username:u };
			data['avatar'] = d.substring(i = d.indexOf('"avatar_url":"') + 14, d.indexOf('"', i));
			data['mutual'] = d.substring(i = d.indexOf('"friends":[') + 11, d.indexOf(']', i)).indexOf('"'+_username+'"') !== -1
			if ((i = d.indexOf('"game_title":"')) != -1) {
				data['title'] = d.substring(i += 14, d.indexOf('"', i));
				data['game'] = d.substring(i = d.indexOf('"game_url":"') + 12, d.indexOf('"', i));
			}
		}
		private function doThing():void {
			++l;
			if (l == friendCount) {
				p = 4;
				setTimeout(_callback, 0, this);
			}
			if (inx > 0) loadFriend(_friendlist[--inx]);
		}
		private function onFError(e:Event):void {
			doThing();
			trace(e.toString());
			throw new Error("<" + e.type + "> has occured while trying to load a file.", errorID);
		}
		private function onError(e:Event):void {
			p = 5;
			trace(e.toString());
			throw new Error("<" + e.type + "> has occured while trying to load a file.", errorID);
		}
	}
}
