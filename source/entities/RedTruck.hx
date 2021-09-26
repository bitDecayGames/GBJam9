package entities;

import states.PlayState;
import flixel.FlxG;

class RedTruck extends Truck {
	public static var LAUNCH_SPEED = -30;

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

		var box = new Box(x + 4, y - 12, 0);
		box.velocity.set(FlxG.random.bool() ? 5 : -5, LAUNCH_SPEED);
		cast(FlxG.state, PlayState).addBox(box);
	}
}
