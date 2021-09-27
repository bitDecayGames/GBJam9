package entities;

import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import ui.font.BitmapText.AerostatRed;
import flixel.FlxG;
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
		var score = 0;

		var distanceFromFront = landX - x;
		#if debug
		trace('landing distance: ${distanceFromFront}');
		#end
		if (distanceFromFront < 8) {
			// first tile is a "bad" zone
			// landed before the scoring zone
			#if debug
			trace('missed landing');
			#end
			score = 100;
		} else {
			// subtract one as the 'perfect' distance is actually one tile back
			var deduction = 100 * Math.floor(distanceFromFront / 8 - 1);
			#if debug
			trace('landing deduction: ${deduction}');
			#end
			score = 1000 - deduction;
		}

		var rating = "F";
		if (score == 1000) {
			rating = "S";
		} else if (score >= 800) {
			rating = "A";
		} else if (score >= 600) {
			rating = "B";
		} else if (score >= 400) {
			rating = "C";
		}

		var display = new AerostatRed(landX - 4, y, rating);
		FlxTween.linearMotion(display, display.x, display.y, display.x, display.y - 36, 1.5, {
			ease: FlxEase.quadOut,
			onComplete: (t) -> {
				display.kill();
			}
		});
		cast(FlxG.state, PlayState).addParticle(display);

		return score;
	}
}
