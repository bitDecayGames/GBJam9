package entities;

import flixel.effects.FlxFlicker;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Player extends FlxSprite {
	var speed:Float = 30;
	var playerNum = 0;

	// roughly a scalar for percent decay per second
	var horizontalDecay:Float = 0.30;

	// All in units/second
	var fallRate:Float = 30;
	var riseRate:Float = 60;
	var maxFallRate:Float = 5;
	var maxRiseRate:Float = -5;

	// TODO: Implement max velocities, including minimum speeds for the scrolling effect

	public function new() {
		super();

		// TODO: rig up all the animation stuff
		loadGraphic(AssetPaths.balloon__png);
	}

	override public function update(delta:Float) {
		// TODO: Leaving this here just as a reminder of how to handle input
		// var inputDir = InputCalcuator.getInputCardinal(playerNum);
		// if (inputDir != NONE) {
		// 	inputDir.asVector(velocity).scale(speed);
		// } else {
		// 	velocity.set();
		// }

		if (SimpleController.pressed(Button.A, playerNum)) {
			acceleration.y = Math.max(maxRiseRate, acceleration.y - riseRate * delta);
		} else if (acceleration.y < maxFallRate) {
			acceleration.y += fallRate * delta;
		}

		if (acceleration.x == 0) {
			// decay velocity x
			if (velocity.x != 0.0) {
				velocity.x -= (velocity.x * horizontalDecay) * delta;
				if (Math.abs(velocity.x) < 0.01) {
					velocity.x = 0;
				}
			}
		}

		// apply update
		super.update(delta);

		// reset accel after each frame
		acceleration.x = 0;
	}

	public function hitBy(b:Bird) {
		b.crash();
		y += 5;
		FlxFlicker.flicker(this, 0.3);
		// punishment of losing any upwards momentum
		// TODO: Is this really punishment?
		acceleration.y = 0;
		velocity.y = 0;
	}
}
