package entities;

import const.WorldConstants;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Box extends FlxSprite {
	public var attached = false;
	public var dropped = false;

	public function new(x:Float, y:Float) {
		super(x, y);
		makeGraphic(8, 8, FlxColor.RED);
		acceleration.y = WorldConstants.GRAVITY;
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
