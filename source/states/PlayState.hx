package states;

import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import entities.Box;
import entities.Bird;
import flixel.group.FlxGroup;
import entities.Wind;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxG;
import spacial.Cardinal;

using extensions.FlxStateExt;

class PlayState extends FlxTransitionableState {
	var player:Player;
	var ground:FlxSprite;

	var winds:FlxTypedGroup<Wind> = new FlxTypedGroup();
	var birds:FlxTypedGroup<Bird> = new FlxTypedGroup();
	var boxes:FlxTypedGroup<Box> = new FlxTypedGroup();

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		ground = new FlxSprite(0, FlxG.height - 16);
		ground.makeGraphic(FlxG.width, 16, FlxColor.BROWN);
		ground.immovable = true;
		add(ground);

		var wind = new Wind(0, 0, 200, 16, Cardinal.E);
		winds.add(wind);
		add(wind);

		var wind2 = new Wind(0, 120, 200, 8, Cardinal.W);
		winds.add(wind2);
		add(wind2);

		var box = new Box(30, 70);
		boxes.add(box);
		add(box);

		var box2 = new Box(60, 80);
		boxes.add(box2);
		add(box2);

		player = new Player();
		add(player);
	}

	override public function update(elapsed:Float) {
		FlxG.overlap(player, winds, function(p:Player, w:Wind) {
			w.blowOn(p);
		});

		FlxG.overlap(player, birds, function(p:Player, b:Bird) {
			p.hitBy(b);
		});

		FlxG.overlap(player, boxes, function(p:Player, b:Box) {
			if (!b.attached && !b.dropped) {
				p.addBox(b);
			}
		});

		FlxG.collide(player, ground);

		FlxG.overlap(boxes, ground, (b, g) -> {
			FlxObject.separate(b, g);
			// stop the box if it collides with the ground
			b.velocity.set(0, 0);
			// make sure the box isn't inside the ground
			b.y = g.y - b.height;
		}, (b, g) -> {
			// only collide boxes with ground if they aren't attached to the player
			return !b.attached;
		});

		super.update(elapsed);

		// DEBUG STUFF
		if (FlxG.keys.justPressed.B) {
			var bird = new Bird(FlxG.width, FlxG.height / 5, Cardinal.W);
			birds.add(bird);
			add(bird);
		}
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
