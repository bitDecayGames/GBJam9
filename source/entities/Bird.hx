package entities;

import spacial.Cardinal;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Bird extends FlxSprite {
	var speed:Float = 30;

	public function new(x:Float, y:Float, direction:Cardinal) {
		super(x, y);
		// TODO: rig up all the animation stuff
		loadGraphic(AssetPaths.bird__png);

		var velVec = direction.asVector();
		velocity.x = velVec.scale(speed).x;
		velVec.put();
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public function crash() {
		// TODO: actually go into death animation and fall from the sky
		kill();
	}
}
