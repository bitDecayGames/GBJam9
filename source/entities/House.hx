package entities;

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
		var boxCenter = b.boxMiddleX();
		var accuracy = Math.abs(x + width / 2 - boxCenter);
		trace('HOUSE DELIVERED. ACCURACY: ${accuracy}');

		var rating:String;
		var num = Math.floor(accuracy);
		if (num <= 1) {
			// S
			rating = "S";

			// TODO: SFX perfect delivery
		} else if (num <= 4) {
			rating = "A";

			// TODO: SFX great delivery
		} else if (num <= 8) {
			rating = "B";

			// TODO: SFX ok delivery
		} else if (num <= 10) {
			rating = "C";

			// TODO: SFX poor delivery
		} else {
			rating = "F";

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

		// TODO: This is pseudo-temporary. I just want to see how close it lands right now
		b.color = FlxColor.BLACK;

		// TODO: figure out how to make this render well
		// TODO: need to use Bitmap Fonts... meaning TextPop won't work as-is
		// TextPop.pop(Std.int(x), Std.int(y), '${Math.abs(Std.int(accuracy))}');

		// TODO: SFX play sound based on accurace (good, ok, bad sound)
	}
}
