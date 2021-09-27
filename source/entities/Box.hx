package entities;

import entities.particle.Dust;
import states.PlayState;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import const.WorldConstants;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Box extends FlxSpriteGroup {
	public static var BOX_ID = 0;

	public static var MAX_HORIZONTAL_SPEED = PlayState.SCROLL_SPEED * 2;

	// TODO: this state is quite messy. We should find a way to simplify it
	public var attached = false;
	public var dropped = false;
	public var grabbable = true;
	public var colliding = true;

	public var boxId = 0;

	var openY:Float;
	var openStarted = false;

	// public so we can properly do collisions/separation
	public var box:ParentedSprite;

	var callback:Dynamic->Void;

	var chute:ParentedSprite;

	public function new(x:Float, y:Float, openAltitude:Float) {
		super(x, y);

		boxId = BOX_ID++;

		openY = openAltitude;

		chute = new ParentedSprite(-12, -8);
		chute.setParent(this);
		chute.loadGraphic(AssetPaths.parachute__png, true, 24, 16);
		chute.animation.add("open", [1, 2, 3], 10, false);
		chute.animation.add("close", [4, 5, 0], 5, false);
		chute.animation.add("hidden", [0], 10);
		chute.animation.play("hidden");
		chute.animation.finishCallback = (name) -> {
			switch (name) {
				case "open":
					// parachute opened, slow decent
					maxVelocity.y = 10;
				default:
					// nothing to do
			}
		}
		// not sure we need this one as open willstop on the open frame
		// chute.animation.add("float", [3], 10);
		add(chute);

		box = new ParentedSprite(AssetPaths.box__png);
		box.offset.set(0, -4);
		box.setParent(this);
		add(box);

		maxVelocity.x = Box.MAX_HORIZONTAL_SPEED;
		acceleration.y = WorldConstants.GRAVITY;
	}

	public function isChuteOpen():Bool {
		return chute.animation.name == "open";
	}

	public function boxMiddleX() {
		return box.x + box.width / 2;
	}

	override public function update(delta:Float) {
		if (acceleration.x == 0) {
			// decay velocity x
			if (velocity.x != 0.0) {
				velocity.x -= (velocity.x * Player.horizontalDecay) * delta;
				if (Math.abs(velocity.x) < 0.01) {
					velocity.x = 0;
				}
			}
		}

		super.update(delta);

		// reset x-accel so wind can do its thing
		acceleration.x = 0;

		if (attached) {
			// the player grabbed us too quickly, no need to open chute
			openStarted = true;
		}

		if (!openStarted && y >= openY && velocity.y > 0) {
			openStarted = true;
			chute.animation.play("open");
		}
	}

	public function closeChute(immediate:Bool = false) {
		if (immediate) {
			chute.animation.play("hidden");
		} else if (chute.animation.name == "open") {
			chute.animation.play("close");
		}
	}

	public function released(?_callback:Dynamic->Void) {

		callback = _callback;

		acceleration.y = WorldConstants.GRAVITY;
		maxVelocity.set();
		// give us a delay so we don't instantly re-grab the box
		new FlxTimer().start(1, (t) -> {
			grabbable = true;
		});
		colliding = true;
	}

	public function hitLevel(o:FlxObject) {
		if (colliding) {
			// This is so the boxes track nicely with the ground
			x = Math.floor(x);
			colliding = false;
			y = o.y - box.height;
			acceleration.set();
			velocity.set(0, 0);

			if (chute.animation.name == "open") {
				chute.animation.play("close");
			}

			if (callback != null) {
				callback(null);
			}

			FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);
			cast(FlxG.state, PlayState).addParticle(new Dust(box.x + box.width / 2, y - box.offset.y, true));
		}
	}

	public function alignTo(alignX:Float, alignY:Float) {
		x = alignX - box.width / 2 - 1;
		y = alignY;
	}

	override public function kill():Void {

		if (callback != null) {
			callback(null);
		}

		super.kill();
	}
}
