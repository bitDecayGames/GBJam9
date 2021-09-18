package entities;

import spacial.Cardinal;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Bird extends FlxSprite implements PlayerDamager {
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

	public function hitPlayer() {
		// TODO: actually go into death animation and fall from the sky
		kill();
	}

	public function hasHitPlayer():Bool {
		// TODO: Don't need to keep state as the bird kills itself at the moment
		return false;
	}
}
