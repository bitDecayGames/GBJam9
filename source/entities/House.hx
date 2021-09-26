package entities;

import metrics.DropScore;
import metrics.Trackers;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import states.PlayState;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import ui.font.BitmapText.AerostatRed;
import flixel.util.FlxColor;
import misc.FlxTextFactory;
import flixel.FlxSprite;

class House extends FlxSprite {
	// These are in distance from center
	var targetMaxDist:Float = 16;
	var perfectMaxDist:Float = 6;

	public var deliverable:Bool = false;

	public static var values = [
		"S" => 2000,
		"A" => 1000,
		"B" => 500,
		"C" => 250,
		"F" => 0
	];

	public function new(x:Float, y:Float, deliverable:Bool) {
		// offset by 16 due to how collisions are built for houses
		super(x, y + 24);

		this.deliverable = deliverable;
		if (deliverable) {
			loadGraphic(AssetPaths.house__png);
		} else {
			loadGraphic(AssetPaths.friendly_house__png);
		}
		offset.y = height;
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public function packageArrived(b:Box) {
		deliverable = false;
		var boxCenter = b.boxMiddleX();
		var accuracy = Math.abs(x + width / 2 - boxCenter);

		#if debug
		trace('HOUSE DELIVERED. ACCURACY: ${accuracy}');
		#end


		var timerDelay:Float = .1;

		var rating:String;
		var num = Math.floor(accuracy);
		if (num <= 1) {
			// S
			rating = "S";

			new FlxTimer().start(timerDelay).onComplete = function(t:FlxTimer) {
				FmodManager.PlaySoundOneShot(FmodSFX.ScoreFour);
			}

			// TODO: SFX perfect delivery
		} else if (num <= 4) {
			rating = "A";
			new FlxTimer().start(timerDelay).onComplete = function(t:FlxTimer) {
				FmodManager.PlaySoundOneShot(FmodSFX.ScoreThree);
			}

			// TODO: SFX great delivery
		} else if (num <= 8) {
			rating = "B";
			new FlxTimer().start(timerDelay).onComplete = function(t:FlxTimer) {
				FmodManager.PlaySoundOneShot(FmodSFX.ScoreTwo);
			}

			// TODO: SFX ok delivery
		} else if (num <= 10) {
			rating = "C";
			new FlxTimer().start(timerDelay).onComplete = function(t:FlxTimer) {
				FmodManager.PlaySoundOneShot(FmodSFX.ScoreOne);
			}

			// TODO: SFX poor delivery
		} else {
			rating = "F";
			new FlxTimer().start(timerDelay).onComplete = function(t:FlxTimer) {
				FmodManager.PlaySoundOneShot(FmodSFX.ScoreZero);
			}

			// TODO: SFX terrible delivery
		}

		var display = new AerostatRed(x + width / 2 - 4, y - height / 2, rating);
		FlxTween.linearMotion(display, display.x, display.y, display.x, display.y - 24,
			{
				ease: FlxEase.quadOut,
				onComplete: (t) -> { display.kill();
			}
		});
		cast(FlxG.state, PlayState).addParticle(display);

		Trackers.drops.push(new DropScore(values.get(rating), rating));

		// TODO: This is pseudo-temporary. I just want to see how close it lands right now
		b.color = FlxColor.BLACK;
	}
}
