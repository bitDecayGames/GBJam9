package entities;

import const.WorldConstants;
import flixel.FlxG;
import flixel.FlxSprite;
import spacial.Cardinal;

class Bird extends FlxSprite implements PlayerDamager {
	var speed:Float = 30;
	var direction:Cardinal;

	var splatted = false;

	public function new(x:Float, y:Float, direction:Cardinal) {
		super(x, y);
		this.direction = direction;

		loadGraphic(AssetPaths.fly__png, true, 8, 8);
		animation.add(Cardinal.E.asString(), [for (i in 0...6) i], 5);
		animation.add(Cardinal.W.asString(), [for (i in 0...6) i], 5, true, true);
		animation.add("die_E", [6], 0, false, true);
		animation.add("die_W", [6]);
		animation.add("thud_E", [7], 0, false, true);
		animation.add("thud_W", [7]);

		animation.play(direction.asString());

		var velVec = direction.asVector();
		velocity.x = velVec.scale(speed).x;
		velVec.put();

		if (direction == E) {
			x -= width;
		}
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (y > FlxG.height) {
			kill();
		}

		FlxG.watch.addQuick("bird vel x: ", velocity.x);

		if (animation.name != null && StringTools.startsWith(animation.name, "thud")) {
			// Slightly cheesy way of getting the bird to stop
			if (velocity.x > 1) {
				acceleration.x = -WorldConstants.GRAVITY;
			} else if (velocity.x < -1) {
				acceleration.x = WorldConstants.GRAVITY;
			} else {
				acceleration.set();
				velocity.set();
				x = Math.round(x);
			}
		}
	}

	public function hitPlayer() {
		die();
	}

	public function isDead() {
		return splatted;
	}

	public function die() {
		splatted = true;
		// TODO: SFX bird dies
		FmodManager.PlaySoundOneShot(FmodSFX.BirdBomb);

		animation.play("die_" + direction.asString());
		acceleration.y = WorldConstants.GRAVITY;
	}

	public function thud() {
		if (alive) {
			// only thud once
			FmodManager.PlaySoundOneShot(FmodSFX.BirdBombLow);
			alive = false;
			animation.play("thud_" + direction.asString());
		}
	}

	public function hasHitPlayer():Bool {
		// TODO: Don't need to keep state as the bird kills itself at the moment
		return false;
	}
}
