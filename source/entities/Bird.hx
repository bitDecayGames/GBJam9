package entities;

import flixel.FlxG;
import const.WorldConstants;
import flixel.FlxObject;
import spacial.Cardinal;
import flixel.FlxSprite;

class Bird extends FlxSprite implements PlayerDamager {
	var speed:Float = 30;
	var direction:Cardinal;

	public function new(x:Float, y:Float, direction:Cardinal) {
		super(x, y);
		this.direction = direction;

		loadGraphic(AssetPaths.fly__png, true, 8, 8);
		animation.add(Cardinal.E.asString(), [for (i in 0...6) i], 5);
		animation.add(Cardinal.W.asString(), [for (i in 0...6) i], 5, true, true);
		animation.add("die_E", [6], 0, false, true);
		animation.add("die_W", [6]);

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
	}

	public function hitPlayer() {
		die();
	}

	public function die() {
		// TODO: SFX bird dies
		FmodManager.PlaySoundOneShot(FmodSFX.BirdBomb);

		allowCollisions = FlxObject.NONE;
		animation.play("die_" + direction.asString());
		acceleration.y = WorldConstants.GRAVITY;
	}

	public function hasHitPlayer():Bool {
		// TODO: Don't need to keep state as the bird kills itself at the moment
		return false;
	}
}
