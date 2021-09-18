package entities;

import states.PlayState;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

class Rocket extends FlxSprite {
	// These are in distance from center
	var altitude:Float = 64;
	var speed:Float = 50;

	var triggered:Bool = false;

	public function new(x:Float, y:Float) {
		// XXX: This is a hardcoded value based on the known height of the rocket sprite
		// given y is assumed to be the 'horizon line'. Adjust rocket to look correct
		super(x, y - 4);
		loadGraphic(AssetPaths.rocket__png);
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (!triggered && FlxG.keys.justPressed.R) {
			FlxTween.linearMotion(this, x, y, x, y - altitude, speed, false, {
				onComplete: (t) -> {
					trace("rocket goes pop");
					kill();

					// TODO: SFX

					// XXX: hacky. Probably better to pass in some function callback
					cast(FlxG.state, PlayState).addBoom(new RocketBoom(x, y));
				}
			});
		}
	}
}
