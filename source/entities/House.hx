package entities;

import flixel.util.FlxColor;
import misc.FlxTextFactory;
import flixel.FlxSprite;

class House extends FlxSprite {
	// These are in distance from center
	var targetMaxDist:Float = 16;
	var perfectMaxDist:Float = 6;

	public function new(x:Float, y:Float) {
		super(x, y);
		loadGraphic(AssetPaths.house__png);
		offset.y = height;
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public function packageArrived(b:Box) {
		var boxCenter = b.x + b.width / 2;
		var accuracy = x + width / 2 - boxCenter;

		// TODO: This is pseudo-temporary. I just want to see how close it lands right now
		b.color = FlxColor.BLACK;

		// TODO: figure out how to make this render well
		// TODO: need to use Bitmap Fonts... meaning TextPop won't work as-is
		// TextPop.pop(Std.int(x), Std.int(y), '${Math.abs(Std.int(accuracy))}');
	}
}
