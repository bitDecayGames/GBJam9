package entities.particle;

import flixel.FlxSprite;

class Explosion extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);

		loadGraphic(AssetPaths.explosion__png, true, 32, 24);
		animation.add("do", [for (i in 0...3) i], 10, false);
		animation.play("do");
		animation.finishCallback = (name) -> {
			kill();
		};
	}
}
