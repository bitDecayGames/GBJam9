package entities;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import states.PlayState;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import const.WorldConstants;
import flixel.effects.FlxFlicker;
import input.SimpleController;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using extensions.FlxObjectExt;

class Player extends FlxSpriteGroup {
	// amount of rope between each box
	private static inline var BOX_SPACING:Float = 4;

	private static inline var RISE_ANIM = "rise";
	private static inline var IDLE_ANIM = "idle";
	private static inline var PLUMMET_ANIM = "plummet";
	private static inline var BLOW_LEFT = "_left";
	private static inline var BLOW_RIGHT = "_right";

	public var nextAnim:String = IDLE_ANIM;

	// SFX handles
	public var sfxBalloonFire:String = "BalloonFire";
	public var sfxBalloonDeflate:String = "BalloonDeflate";


	var controllable = false;

	var balloon:ParentedSprite;

	var aimIndicator:FlxSprite;
	var aimDirection = 3;
	var aimOffsets = [
		0 => FlxPoint.get(-8, 17),
		1 => FlxPoint.get(-4, 25),
		2 => FlxPoint.get(4, 25),
		3 => FlxPoint.get(8, 17),
	];

	var speed:Float = 30;
	var playerNum = 0;

	// roughly a scalar for percent decay per second
	var horizontalDecay:Float = 0.30;

	// All in units/second
	var fallAccel:Float = WorldConstants.GRAVITY / 8;
	var riseAccel:Float = -WorldConstants.GRAVITY / 3;
	var forceFallAccel:Float = WorldConstants.GRAVITY / 3;

	var maxHorizontalSpeed:Float = 10;
	var maxVerticalSpeed:Float = 25;
	var maxFallSpeed:Float = 5;
	var maxForceFallSpeed:Float = 10;

	var boxes:Array<Box> = new Array();

	public var collisionWidth = 10;
	public var collisionHeight = 24;

	public function new(x:Float, y:Float) {
		super();

		buildBalloon();
		buildIndicator();

		setPosition(x, y - height);
	}

	private function buildBalloon() {
		balloon = new ParentedSprite();
		balloon.parent = this;
		balloon.loadGraphic(AssetPaths.player__png, true, 16, 32);

		balloon.height = collisionHeight;
		balloon.width = collisionWidth;
		balloon.offset.set(4, 3);

		balloon.animation.add(IDLE_ANIM, [0]);
		balloon.animation.add(IDLE_ANIM + BLOW_RIGHT, [5, 6, 7], 2);
		balloon.animation.add(IDLE_ANIM + BLOW_LEFT, [3, 2, 1], 2);
		balloon.animation.add(RISE_ANIM, [8, 16], 4);
		balloon.animation.add(RISE_ANIM + BLOW_RIGHT, [13, 21, 14, 22, 15, 23], 4);
		balloon.animation.add(RISE_ANIM + BLOW_LEFT, [9, 17, 10, 18, 11, 19], 4);
		balloon.animation.add(PLUMMET_ANIM, [24]);
		balloon.animation.add(PLUMMET_ANIM + BLOW_RIGHT, [29, 30, 31], 2);
		balloon.animation.add(PLUMMET_ANIM + BLOW_LEFT, [25, 26, 27], 2);
		balloon.animation.play(IDLE_ANIM);

		add(balloon);

		maxVelocity.set(maxHorizontalSpeed, maxVerticalSpeed);
	}

	private function buildIndicator() {
		aimIndicator = new FlxSprite();
		aimIndicator.loadGraphic(AssetPaths.indicators__png, true, 8, 8);
		aimIndicator.animation.add("0", [0, 1], 2, true);
		aimIndicator.animation.add("1", [2, 3], 2, true);
		aimIndicator.animation.add("2", [2, 3], 2, true, true);
		aimIndicator.animation.add("3", [0, 1], 2, true, true);
		aimIndicator.animation.play('${aimDirection}');
		aimIndicator.allowCollisions = FlxObject.NONE;
		add(aimIndicator);
	}

	public function takeControl() {
		controllable = true;
	}

	override public function update(delta:Float) {
		nextAnim = IDLE_ANIM;

		// by default we fall unless something in controls tells us otherwise
		acceleration.y = fallAccel;

		checkControls();

		if (acceleration.x != 0) {
			// update animation accordingly
			if (acceleration.x > 0) {
				nextAnim += BLOW_RIGHT;
			} else {
				nextAnim += BLOW_LEFT;
			}
		} else {
			// decay velocity x
			if (velocity.x != 0.0) {
				velocity.x -= (velocity.x * horizontalDecay) * delta;
				if (Math.abs(velocity.x) < 0.01) {
					velocity.x = 0;
				}
			}
		}

		// TODO: Try to line up frames so the basket doesn't reset when changing between animations
		balloon.animation.play(nextAnim);

		// apply update
		super.update(delta);

		// Keep our indicator aligned
		aimIndicator.x = balloon.x + aimOffsets[aimDirection].x;
		aimIndicator.y = balloon.y + aimOffsets[aimDirection].y;

		// reset x-accel after each frame so wind can work properly
		acceleration.x = 0;

		// cap our falling speed to keep that floaty balloon feeling

		if (SimpleController.pressed(Button.DOWN)) {
			velocity.y = Math.min(maxForceFallSpeed, velocity.y);
		} else {
			// TODO: Do we want to have acceleration to get to this speed if the player lets go of down?
			//       Right now, if the player is holding down and then lets go, they instantly slow down
			//       to this speed
			velocity.y = Math.min(maxFallSpeed, velocity.y);
		}

		for (i in 0...boxes.length) {
			boxes[i].alignTo(balloon.x + balloon.width / 2, balloon.y + balloon.height + BOX_SPACING + i * (8 + BOX_SPACING));
			boxes[i].velocity.set(velocity.x, velocity.y);
		}
	}

	function checkControls() {
		if (controllable) {
			// Balloon burner
			if (SimpleController.pressed(Button.UP, playerNum)) {
				nextAnim = RISE_ANIM;
				acceleration.y = riseAccel;
				
				// TODO: SFX (done) Play ascending (burner) sound (happens every frame)
				if (!FmodManager.IsSoundPlaying(sfxBalloonFire)){
					FmodManager.PlaySoundAndAssignId(FmodSFX.BalloonFire, sfxBalloonFire);
				}
				nextAnim = RISE_ANIM;
				acceleration.y = riseAccel;
			} else {
				FmodManager.StopSoundImmediately(sfxBalloonFire);
			}

			if (SimpleController.pressed(Button.DOWN, playerNum)) {
				nextAnim = PLUMMET_ANIM;
				acceleration.y = forceFallAccel;

				// TODO: SFX (done) play deflating sound (happens every frame)
				if (!FmodManager.IsSoundPlaying(sfxBalloonDeflate)){
					FmodManager.PlaySoundAndAssignId(FmodSFX.BalloonDeflate, sfxBalloonDeflate);
					FmodManager.SetEventParameterOnSound(sfxBalloonDeflate, "EndDeflateSound", 0);
				} else {
					if (FmodManager.GetEventParameterOnSound(sfxBalloonDeflate, "EndDeflateSound") == 1){
						FmodManager.StopSoundImmediately(sfxBalloonDeflate);
						FmodManager.PlaySoundAndAssignId(FmodSFX.BalloonDeflate, sfxBalloonDeflate);
					}
				}
			} else {
				if (FmodManager.GetEventParameterOnSound(sfxBalloonDeflate, "EndDeflateSound") == 0){
					FmodManager.PlaySoundOneShot(FmodSFX.BalloonDeflateEndClick);
				}
				FmodManager.SetEventParameterOnSound(sfxBalloonDeflate, "EndDeflateSound", 1);
			}

			// Box dropping
			if (SimpleController.just_pressed(Button.B, playerNum)) {
				var box = boxes.pop();
				if (box == null) {
					// no box to cut
					// TODO: SFX play error noise
				} else {
					// drop the box!
					// TODO: SFX play release sound
					box.attached = false;
					box.dropped = true;
					box.released();
				}
			}

			if (SimpleController.just_pressed(Button.LEFT, playerNum)) {
				// TODO: SFX (done) Play selector sound
				FmodManager.PlaySoundOneShot(FmodSFX.ShootDirection);
				aimDirection = Std.int(Math.max(0, aimDirection - 1));
				aimIndicator.animation.play('${aimDirection}');
			}

			if (SimpleController.just_pressed(Button.RIGHT, playerNum)) {
				// TODO: SFX (done) Play selector sound
				FmodManager.PlaySoundOneShot(FmodSFX.ShootDirection);
				aimDirection = Std.int(Math.min(3, aimDirection + 1));
				aimIndicator.animation.play('${aimDirection}');
			}

			if (SimpleController.just_pressed(Button.A, playerNum)) {
				var pos = FlxPoint.get(balloon.x + balloon.width / 2 - 2, balloon.y + balloon.height - 8);
				var vel = FlxPoint.get();
				switch (aimDirection) {
					case 0:
						vel.set(-20, 0);
						pos.x -= 8;
					case 1:
						vel.set(-10, 10);
						pos.x -= 8;
					case 2:
						vel.set(10, 10);
						pos.x += 2;
					case 3:
						vel.set(20, 0);
						pos.x += 2;
				}
				vel.addPoint(velocity);

				var toss = new FlxSprite(pos.x, pos.y);
				toss.loadGraphic(AssetPaths.bomb__png);
				toss.velocity.copyFrom(vel);
				toss.acceleration.y = WorldConstants.GRAVITY;

				// XXX: hacky. Probably better to pass in some function callback
				cast(FlxG.state, PlayState).addBomb(toss);

				// TODO: SFX (done) play drop rock/bomb sound
				FmodManager.PlaySoundOneShot(FmodSFX.Shoot);
			}
		}
	}

	public function hitBy(b:PlayerDamager) {
		b.hitPlayer();
		y += 5;
		FlxFlicker.flicker(this, 0.3);
		// punishment of losing any upwards momentum
		// TODO: Is this really punishment?
		acceleration.y = 0;
		velocity.y = maxFallSpeed;

		// TODO: Do we want to impact how the player can throw rock/bombs?
		// potentially add cooldown
	}

	public function addBox(b:Box) {
		if (!boxes.contains(b)) {
			b.closeChute(true);
			b.attached = true;
			b.grabbable = false;
			boxes.push(b);
		}
	}
}
