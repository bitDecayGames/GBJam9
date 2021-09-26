package entities;

import flixel.FlxSprite;

class Tree extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);

		loadGraphic(AssetPaths.tree__png, true, 32, 24);
		animation.add("still", [0], 0);
		animation.add("blow", [1, 2, 3, 4, 5], 3);
		animation.play("blow");
	}

	public function beBlown() {
		if (animation.name != "blow") {
			alpha = 0.5;
			animation.play("blow");
		}
	}
}