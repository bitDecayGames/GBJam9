package entities;

import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import const.WorldConstants;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Box extends FlxSpriteGroup {

	// TODO: this state is quite messy. We should find a way to simplify it
	public var attached = false;
	public var dropped = false;
	public var grabbable = true;
	public var colliding = true;

	var openY:Float;
	var openStarted = false;

	// public so we can properly do collisions/separation
	public var box:ParentedSprite;
	var chute:ParentedSprite;

	public function new(x:Float, y:Float, openAltitude:Float) {
		super(x, y);

		openY = openAltitude;

		box = new ParentedSprite(AssetPaths.box__png);
		box.setParent(this);
		add(box);

		chute = new ParentedSprite(-4, -10);
		chute.setParent(this);
		chute.loadGraphic(AssetPaths.parachute__png, true, 16, 8);
		chute.animation.add("open", [1, 2, 3], 10, false);
		chute.animation.add("close", [4, 5, 0], 10, false);
		chute.animation.add("hidden", [0], 10);
		chute.animation.play("hidden");
		chute.animation.finishCallback = (name) -> {
			switch(name) {
			case "open":
				// parachute opened, slow decent
				maxVelocity.y = 10;
			default:
				// nothing to do
			}
		}
		// not sure we need this one as open willstop on the open frame
		// chute.animation.add("float", [3], 10);
		add(chute);

		acceleration.y = WorldConstants.GRAVITY;
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (!openStarted && y >= openY) {
			openStarted = true;
			chute.animation.play("open");
		}
	}

	public function released() {
		acceleration.y = WorldConstants.GRAVITY;
		maxVelocity.set();
		// give us a delay so we don't instantly re-grab the box
		new FlxTimer().start(1, (t) -> { grabbable = true;});
		colliding = true;
	}

	public function hitLevel(o:FlxObject) {
		if (colliding) {
			colliding = false;
			y = o.y - box.height;
			acceleration.set();
			velocity.set(0, 0);

			if (chute.animation.name == "open") {
				chute.animation.play("close");
			}
		}
	}

	public function alignTo(alignX:Float, alignY:Float) {
		x = alignX - box.width / 2;
		y = alignY;
	}
}
