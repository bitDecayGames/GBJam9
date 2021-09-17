package entities;

import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Player extends FlxSprite {
	var speed:Float = 30;
	var playerNum = 0;

	var horizontalDecay:Float = 0.99;

	var fallRate:Float = 0.5;
	var riseRate:Float = 1;
	var maxFall:Float = 5;
	var maxRise:Float = -5;

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
			acceleration.y = Math.max(maxRise, acceleration.y - riseRate);
		} else if (acceleration.y < maxFall) {
			acceleration.y += fallRate;
		}

		if (acceleration.x == 0) {
			// decay velocity x
			if (velocity.x != 0.0) {
				velocity.x *= horizontalDecay;
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
}
