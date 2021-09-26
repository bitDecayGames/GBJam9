package entities;

import flixel.FlxSprite;

class Truck extends FlxSprite {

	public function new(x:Float, y:Float) {
		super(x, y);
		loadGfx();
	}

	public function loadGfx() {
		loadGraphic(AssetPaths.truck_combined__png, true, 24, 16);
		animation.add("alive", [0], 0);
		animation.add("dead", [1], 0);
		animation.play("alive");

		y += 5;
		height = 11;
		offset.y = 5;
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public function hit() {
		// TODO: SFX truck hit by player attack

		animation.play("dead");
	}
}
