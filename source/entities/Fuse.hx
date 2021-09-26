package entities;

import flixel.FlxSprite;

class Fuse extends TriggerableSprite {

	var next:TriggerableSprite;

	public function new(x:Float, y:Float, next:TriggerableSprite) {
		super(x, y);

		this.next = next;

		loadGraphic(AssetPaths.fuse__png, true, 8, 8);
		animation.add("unlit", [0]);
		animation.add("lit", [4, 8, 5, 9, 6, 10, 7, 11], 4, false);
		animation.play("unlit");

		animation.finishCallback = (name) -> {
			if (name == "lit") {
				kill();
				next.trigger();
			}
		}
	}

	override public function trigger() {
		animation.play("lit");
	}
}