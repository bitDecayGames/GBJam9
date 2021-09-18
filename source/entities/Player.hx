package entities;

import flixel.FlxG;
import const.WorldConstants;
import flixel.effects.FlxFlicker;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Player extends FlxSprite {
	// amount of rope between each box
	private static inline var BOX_SPACING:Float = 4;

	var speed:Float = 30;
	var playerNum = 0;

	// roughly a scalar for percent decay per second
	var horizontalDecay:Float = 0.30;

	// All in units/second
	var fallAccel:Float = WorldConstants.GRAVITY / 4;
	var riseAccel:Float = -WorldConstants.GRAVITY / 3;

	var maxHorizontalSpeed:Float = 10;
	var maxVerticalSpeed:Float = 25;
	var maxFallSpeed:Float = 10;

	var boxes:Array<Box> = new Array();

	public function new() {
		super();

		// TODO: rig up all the animation stuff
		loadGraphic(AssetPaths.balloon__png);

		maxVelocity.set(maxHorizontalSpeed, maxVerticalSpeed);
	}

	override public function update(delta:Float) {
		// Balloon burner
		if (SimpleController.pressed(Button.UP, playerNum)) {
			acceleration.y = riseAccel;
		} else {
			acceleration.y = fallAccel;
		}

		// Box dropping
		if (SimpleController.just_pressed(Button.B, playerNum)) {
			var box = boxes.pop();
			if (box == null) {
				// no box to cut
			} else {
				// drop the box!
				box.attached = false;
				box.dropped = true;
			}
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

		// reset x-accel after each frame so wind can work properly
		acceleration.x = 0;

		// cap our falling speed to keep that floaty balloon feeling
		velocity.y = Math.min(maxFallSpeed, velocity.y);

		for (i in 0...boxes.length) {
			boxes[i].x = this.x + width / 2 - boxes[i].width / 2;
			boxes[i].y = y + height + BOX_SPACING + i * (boxes[i].height + BOX_SPACING);
			boxes[i].velocity.set(velocity.x, velocity.y);
		}
	}

	public function hitBy(b:PlayerDamager) {
		b.hitPlayer();
		y += 5;
		FlxFlicker.flicker(this, 0.3);
		// punishment of losing any upwards momentum
		// TODO: Is this really punishment?
		acceleration.y = 0;
		velocity.y = 0;
	}

	public function addBox(b:Box) {
		if (!boxes.contains(b)) {
			b.attached = true;
			boxes.push(b);
		}
	}
}
