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
			#if debug
			trace('missed landing');
			#end
			return 100;
		} else {
			// subtract one as the 'perfect' distance is actually one tile back
			var deduction = 100 * Math.floor(distanceFromFront / 8 - 1);
			#if debug
			trace('landing deduction: ${deduction}');
			#end
			return 1000 - deduction;
		}
	}
}
