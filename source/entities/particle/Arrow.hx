package entities.particle;

import flixel.FlxG;
import flixel.FlxSprite;

class Arrow extends FlxSprite {
	var tracking:FlxSprite;
	var xOff:Float;
	var yOff:Float;
	var renderMod:Float;

	var doneCheck:()->Bool;

	public function new(track:FlxSprite, xOffset:Float, yOffset:Float, done:()->Bool) {
		super();
		loadGraphic(AssetPaths.arrow__png, true, 12, 12);
		animation.add("do", [0, 1], 2);
		animation.play("do");

		tracking = track;
		xOff = xOffset;
		yOff = yOffset;
		doneCheck = done;
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (!tracking.alive) {
			kill();
			return;
		}

		x = tracking.x + xOff;
		y = tracking.y + yOff;

		if (doneCheck()) {
			kill();
		}
	}
}