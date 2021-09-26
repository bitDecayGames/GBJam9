package entities;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Landing extends FlxSprite {
	public function new(x:Float, y:Float, width:Int) {
		// XXX: We need this to protrude from the ground a bit so we can actually collide with it
		super(x, y);

		// TODO: Load real graphics
		makeGraphic(width, 8, FlxColor.MAGENTA);

		alpha = 0;
		#if debug
		alpha = 0.5;
		#end
	}

	public function getScore(landX:Float):Int {
		var distanceFromFront = landX - x;
		trace('landing distance: ${distanceFromFront}');
		if (distanceFromFront < 8) {
			// first tile is a "bad" zone
			// landed before the scoring zone
			trace('missed landing');
			return 100;
		} else {
			var deduction = 100 * Math.round(distanceFromFront / 8);
			trace('landing deduction: ${deduction}');
			return 1000 - deduction;
		}
	}
}
