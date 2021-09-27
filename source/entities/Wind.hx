package entities;

import states.PlayState;
import flixel.FlxG;
import flixel.math.FlxVector;
import spacial.Cardinal;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Wind extends FlxSprite {
	// Spread: Lower number means more wind being spawned
	public static inline var WIND_SPREAD = 5000;

	var rawDir:Cardinal;
	var direction:FlxVector;

	// TODO: Do we want all wind to be the same strength?
	var strength:Float = 10;
	var spawnRate:Float;

	var timer = 0.0;

	public function new(x:Float, y:Float, width:Float, height:Float, dir:Cardinal, strength:Float) {
		super(x, y);
		rawDir = dir;
		direction = dir.asVector();

		makeGraphic(1, 1, FlxColor.GRAY);
		#if debug
		alpha = 0.2;
		#else
		alpha = 0.0;
		#end

		if (strength <= 0) {
			strength = 1;
		}
		this.strength = strength;

		// calculate number of gusts to spawn per pixel density
		var density = (width * height) / WIND_SPREAD;
		spawnRate = (1 / (strength * density));
		trace(spawnRate);

		this.width = width;
		this.height = height;
		scale.set(width, height);
		updateHitbox();
	}

	override public function update(delta:Float) {
		super.update(delta);

		timer += delta;
		while (timer > spawnRate) {
			timer -= spawnRate;
			cast(FlxG.state, PlayState).addGust(FlxG.random.float(x, x + width - 8), FlxG.random.float(y, y + height - 8), rawDir);
		}
	}

	public function blowOn(other:FlxSprite) {
		var vec = FlxVector.weak();
		vec.copyFrom(direction).scale(strength);
		other.acceleration.set(vec.x, other.acceleration.y);
		vec.put();

		// TODO: SFX Play blowing noise
	}
}
