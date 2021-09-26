package entities;

import flixel.FlxSprite;

class RedTruck extends Truck {

	public function new(x:Float, y:Float) {
		super(x, y);

	}

	override public function loadGfx() {
		loadGraphic(AssetPaths.bigTruck_combined__png, true, 24, 16);
		animation.add("alive", [0], 0);
		animation.add("dead", [1], 0);
		animation.play("alive");
	}

	override public function hit() {
		super.hit();

		// TODO: Drop package
	}
}
