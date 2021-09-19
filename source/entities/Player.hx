package entities;

import flixel.math.FlxPoint;
import states.PlayState;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import const.WorldConstants;
import flixel.effects.FlxFlicker;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using extensions.FlxObjectExt;

class Player extends FlxSpriteGroup {
	// amount of rope between each box
	private static inline var BOX_SPACING:Float = 4;

	public var balloon:ParentedSprite;

	var aimIndicator:FlxSprite;
	var aimDirection = 0;
	var aimOffsets = [
		0 => FlxPoint.get(-4, 20),
		1 => FlxPoint.get(0, 28),
		2 => FlxPoint.get(8, 28),
		3 => FlxPoint.get(12, 20),
	];

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

		buildBalloon();
		buildIndicator();
	}

	private function buildBalloon() {
		balloon = new ParentedSprite();
		balloon.parent = this;
		// TODO: rig up all the animation stuff
		balloon.loadGraphic(AssetPaths.balloon__png);

		add(balloon);

		balloon.maxVelocity.set(maxHorizontalSpeed, maxVerticalSpeed);
	}

	private function buildIndicator() {
		aimIndicator = new FlxSprite();
		aimIndicator.loadGraphic(AssetPaths.indicators__png, true, 8, 8);
		aimIndicator.animation.add("0", [0, 1], 2, true);
		aimIndicator.animation.add("1", [2, 3], 2, true);
		aimIndicator.animation.add("2", [2, 3], 2, true, true);
		aimIndicator.animation.add("3", [0, 1], 2, true, true);
		aimIndicator.animation.play('${aimDirection}');

		add(aimIndicator);
	}

	override public function update(delta:Float) {
		// Balloon burner
		if (SimpleController.pressed(Button.UP, playerNum)) {
			balloon.acceleration.y = riseAccel;
		} else {
			balloon.acceleration.y = fallAccel;
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

		if (SimpleController.just_pressed(Button.LEFT, playerNum)) {
			aimDirection = Std.int(Math.max(0, aimDirection - 1));
			aimIndicator.animation.play('${aimDirection}');
		}

		if (SimpleController.just_pressed(Button.RIGHT, playerNum)) {
			aimDirection = Std.int(Math.min(3, aimDirection + 1));
			aimIndicator.animation.play('${aimDirection}');
		}

		if (SimpleController.just_pressed(Button.A, playerNum)) {
			var pos = FlxPoint.get(balloon.x + balloon.width / 2 - 2, balloon.y + balloon.height - 8);
			var vel = FlxPoint.get();
			switch (aimDirection) {
				case 0:
					vel.set(-20, 0);
					pos.x -= 5;
				case 1:
					vel.set(-10, 10);
					pos.x -= 5;
				case 2:
					vel.set(10, 10);
					pos.x += 5;
				case 3:
					vel.set(20, 0);
					pos.x += 5;
			}
			vel.addPoint(balloon.velocity);

			var toss = new FlxSprite(pos.x, pos.y);
			toss.makeGraphic(4, 4, FlxColor.BLUE);
			toss.velocity.copyFrom(vel);
			toss.acceleration.y = WorldConstants.GRAVITY;

			// XXX: hacky. Probably better to pass in some function callback
			cast(FlxG.state, PlayState).addBomb(toss);
		}

		if (balloon.acceleration.x == 0) {
			// decay velocity x
			if (balloon.velocity.x != 0.0) {
				balloon.velocity.x -= (balloon.velocity.x * horizontalDecay) * delta;
				if (Math.abs(balloon.velocity.x) < 0.01) {
					balloon.velocity.x = 0;
				}
			}
		}

		// apply update
		super.update(delta);

		// Keep our indicator aligned
		aimIndicator.x = balloon.x + aimOffsets[aimDirection].x;
		aimIndicator.y = balloon.y + aimOffsets[aimDirection].y;


		// reset x-accel after each frame so wind can work properly
		balloon.acceleration.x = 0;

		// cap our falling speed to keep that floaty balloon feeling
		balloon.velocity.y = Math.min(maxFallSpeed, balloon.velocity.y);

		for (i in 0...boxes.length) {
			boxes[i].x = balloon.x + balloon.width / 2 - boxes[i].width / 2;
			boxes[i].y = balloon.y + balloon.height + BOX_SPACING + i * (boxes[i].height + BOX_SPACING);
			boxes[i].velocity.set(balloon.velocity.x, balloon.velocity.y);
		}
	}

	public function hitBy(b:PlayerDamager) {
		b.hitPlayer();
		balloon.y += 5;
		FlxFlicker.flicker(this, 0.3);
		// punishment of losing any upwards momentum
		// TODO: Is this really punishment?
		balloon.acceleration.y = 0;
		balloon.velocity.y = 0;
	}

	public function addBox(b:Box) {
		if (!boxes.contains(b)) {
			b.attached = true;
			boxes.push(b);
		}
	}
}
