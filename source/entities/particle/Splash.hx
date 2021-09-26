package entities.particle;

import flixel.FlxSprite;

class Splash extends FlxSprite {
	public function new(x:Float, y:Float, big:Bool) {
		super(x, y);

		if (big) {
			loadGraphic(AssetPaths.largeSplash__png, true, 32, 24);
			this.x -= 12;
			this.y -= 12;
		} else {
			loadGraphic(AssetPaths.smallSplash__png, true, 8, 8);
			this.x -= 4;
			this.y -= 4;
		}
		animation.add("do", [for (i in 0...8) i], 8, false);
		animation.play("do");
		animation.finishCallback = (n) -> { kill(); };
	}
}