package entities;

import flixel.FlxG;
import flixel.math.FlxVector;
import spacial.Cardinal;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Gust extends FlxSprite {
	public static var initCount = 0;

	public var done:() -> Void;

	public function new() {
		super();

		initCount++;

		loadGraphic(AssetPaths.leftRight__png, true, 16, 8);
		animation.add("blowLeft", [for (i in 0...8) i], 10, false);
		animation.add("blowRight", [for (i in 0...8) i], 10, false, true);
		animation.finishCallback = (name) -> {
			kill();
			done();
		};
	}

	override public function destroy() {
		// XXX: Pools seem to destroy things... don't destroy please
	}

	public function setup(x:Float, y:Float, dir:Cardinal) {
		reset(x, y);

		if (dir == E) {
			animation.play("blowRight", true);
		} else {
			animation.play("blowLeft", true);
		}
	}
}
