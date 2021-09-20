package entities;

import flixel.math.FlxVector;
import spacial.Cardinal;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Wind extends FlxSprite {
	var direction:Cardinal;

	// TODO: Do we want all wind to be the same strength?
	var strength:Float = 10;

	public function new(x:Float, y:Float, width:Float, height:Float, dir:Cardinal) {
		super(x, y);
		direction = dir;

		// TODO: Add graphics
		makeGraphic(1, 1, FlxColor.GRAY);
		alpha = 0.3;

		this.width = width;
		this.height = height;
		scale.set(width, height);
		updateHitbox();
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public function blowOn(other:FlxSprite) {
		var vec = FlxVector.weak();
		direction.asVector(vec).scale(strength);
		other.acceleration.set(vec.x, other.acceleration.y);
		vec.put();
	}
}
