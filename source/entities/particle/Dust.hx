package entities.particle;

import flixel.FlxSprite;

class Dust extends FlxSprite {
	public function new(x:Float, y:Float, big:Bool = true) {
		// big dust is 32x8
		// small dust is 16x8

		// center it on the x
		var xSize = big ? 32 : 16;
		super(x - xSize / 2, y);

		var asset = big ? AssetPaths.swirls__png : AssetPaths.smallSwirls__png;

		loadGraphic(asset, true, xSize, 8);
		animation.add("do", [for (i in 0...8) i], 10, false);
		animation.play("do");
		animation.finishCallback = (name) -> {
			kill();
		};
	}
}
