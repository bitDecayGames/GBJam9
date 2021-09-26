package entities.particle;

import spacial.Cardinal;
import flixel.FlxSprite;

class Dust extends FlxSprite {
	public function new(x:Float, y:Float) {
		// center it on the x
		super(x - 16, y);

		loadGraphic(AssetPaths.swirls__png, true, 32, 8);
		animation.add("do", [for(i in 0...8) i], 10, false);
		animation.play("do");
		animation.finishCallback = (name) -> { kill(); };
	}
}