package skyboy.managers {
	import flash.events.Event;
	import flash.display.Stage;

	public class BulletManager {
		private namespace intern = "http://skyboy/internal";
		private var s:Stage, bullet:Class;
		intern var bullets:Vector.<Object>;
		private var bulletCount:int;
	
		public function get bullets():int {
			return bulletCount;
		}

		public function BulletManager(stage:Stage, bulletClass:Class, limit:int = 1024) {
			s = stage;
			bullet = bulletClass;
			intern::bullets = new Vector.<Object>(limit, true); // 1024 should be plenty
			stage.addEventListener(bullet.REMOVE, removeBullet)
			stage.addEventListener(bullet.FIRE, addBullet);
		}
		private function addBullet(e:Event):void {
			var i:Object = e.target, bullets:Vector.<Object> = intern::bullets;
			if (i == null || ~bullets.indexOf(i)) return;
			var dex:int = bullets.indexOf(null);
			if (dex == -1) throw new Error("Too many bullets");
			bullets[dex] = i;
			++bulletCount;
		}
		private function removeBullet(e:Event):void {
			var i:Object = e.target, bullets:Vector.<Object> = intern::bullets;
			var dex:int = bullets.indexOf(i);
			if (dex == -1) return;
			bullets[dex] = null;
			--bulletCount;
		}
		public function update(...Void):void {
			var bullets:Vector.<Object> = intern::bullets;
			for each(var i:Object in bullets) {
				if (i == null) continue;
				if (i.parent == null) continue;
				i.enterFrame();
			}
		}
		public function deconstruct(...Void):void {
			s.removeEventListener(bullet.FIRE, addBullet);
			s.removeEventListener(bullet.REMOVE, removeBullet);
			var bullets:Vector.<Object> = intern::bullets;
			for (var i:String in bullets) {
				bullets[i] = null;
			}
		}
	}
}
