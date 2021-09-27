package entities;

import flixel.FlxG;
import flixel.FlxSprite;

class Shadow extends FlxSprite {
	var tracking:FlxSprite;
	var xOff:Float;
	var yOff:Float;
	var renderMod:Float;

	public function new(track:FlxSprite, xOffset:Float, yOffset:Float, renderDepthMod:Float) {
		super();
		loadGraphic(AssetPaths.shadow__png, true, 8, 8);
		animation.add("shadow", [5, 4, 3, 2, 1, 0], 0);
		animation.play("shadow", true, false, 0);

		tracking = track;
		xOff = xOffset;
		yOff = yOffset;
		renderMod = renderDepthMod;
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (!tracking.alive) {
			kill();
			return;
		}

		x = tracking.x + xOff;
		y = Player.PLAYER_LOWEST_ALTITUDE + renderMod;

		var frame = Player.PLAYER_LOWEST_ALTITUDE - (tracking.y + yOff);
		frame = frame / 4;
		frame = Math.min(5, frame);
		animation.play("shadow", true, false, Std.int(frame));
	}
}