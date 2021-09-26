package entities;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Landing extends FlxSprite {
	public function new(x:Float, y:Float, width:Int) {
		// XXX: We need this to protrude from the ground a bit so we can actually collide with it
		super(x, y);

		// TODO: Load real graphics
		makeGraphic(width, 8, FlxColor.MAGENTA);
		alpha = 0.7;
	}
}
