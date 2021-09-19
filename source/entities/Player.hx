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

	public var aimIndicator:FlxSprite;

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
		aimIndicator.loadGraphic(AssetPaths.indicator__png, true, 32, 32);
		aimIndicator.animation.add("direction", [0, 1, 2, 3], 0, false);
		aimIndicator.animation.play("direction", 0);

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
			var curFrame = aimIndicator.animation.frameIndex;
			var nextFrame = Std.int(Math.max(0, curFrame - 1));
			aimIndicator.animation.frameIndex = nextFrame;
		}

		if (SimpleController.just_pressed(Button.RIGHT, playerNum)) {
			var curFrame = aimIndicator.animation.frameIndex;
			var nextFrame = Std.int(Math.min(3, curFrame + 1));
			aimIndicator.animation.frameIndex = nextFrame;
		}

		if (SimpleController.just_pressed(Button.A, playerNum)) {
			var pos = FlxPoint.get(balloon.x + balloon.width / 2 - 2, balloon.y + balloon.height - 8);
			var vel = FlxPoint.get();
			switch (aimIndicator.animation.frameIndex) {
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
		aimIndicator.x = balloon.x + balloon.width / 2 - aimIndicator.width / 2;
		aimIndicator.y = balloon.y + balloon.height / 2 - aimIndicator.height / 2;

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
