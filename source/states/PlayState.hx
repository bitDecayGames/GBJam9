package states;

import ui.font.BitmapText.PressStart;
import entities.ParentedSprite;
import entities.PlayerDamager;
import entities.RocketBoom;
import entities.Bird;
import entities.Box;
import entities.House;
import entities.Player;
import entities.Rocket;
import entities.Wind;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import signals.Lifecycle;
import spacial.Cardinal;

using extensions.FlxStateExt;

class PlayState extends FlxTransitionableState {
	var player:Player;
	var ground:FlxSprite;

	var bounds:FlxGroup = new FlxGroup();

	var winds:FlxTypedGroup<Wind> = new FlxTypedGroup();
	var birds:FlxTypedGroup<Bird> = new FlxTypedGroup();
	var boxes:FlxTypedGroup<Box> = new FlxTypedGroup();
	var activeHouses:FlxTypedGroup<House> = new FlxTypedGroup();
	var rockets:FlxTypedGroup<Rocket> = new FlxTypedGroup();

	var rocketsBooms:FlxTypedGroup<RocketBoom> = new FlxTypedGroup();

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		// var font = new PressStart(30, 30, "Instance of a BitmapFont");
		// add(font);

		setupScreenBounds();

		setupTestObjects();

		// TODO: When loading the level, make sure to update FlxG.worldBounds to ensure collisions work throughout level
	}

	override public function update(elapsed:Float) {
		FlxG.overlap(player.balloon, winds, function(balloon:ParentedSprite, w:Wind) {
			w.blowOn(balloon);
		});

		FlxG.overlap(player.balloon, birds, function(balloon:ParentedSprite, b:Bird) {
			cast(balloon.parent, Player).hitBy(b);
		});

		FlxG.overlap(player.balloon, rocketsBooms, function(balloon:ParentedSprite, r:ParentedSprite) {
			// we collide with the sub-particles of the RocketBoom
			var boom = cast(r.parent, RocketBoom);
			if (!boom.hasHitPlayer()) {
				cast(balloon.parent, Player).hitBy(boom);
			}
		});

		FlxG.overlap(player.balloon, boxes, function(balloon:ParentedSprite, b:Box) {
			if (!b.attached && !b.dropped) {
				cast(balloon.parent, Player).addBox(b);
			}
		});

		FlxG.collide(player.balloon, bounds);

		// check boxes against houses first
		FlxG.overlap(boxes, activeHouses, (b, h) -> {
			trace("box touching house");
			if (b.dropped) {
				trace("box triggered house!");
				h.packageArrived(b);
				activeHouses.remove(h);
			}
		});

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

	public function setupScreenBounds() {
		ground = new FlxSprite(0, FlxG.height - 16);
		ground.makeGraphic(FlxG.width, 16, FlxColor.BROWN);
		ground.immovable = true;
		add(ground);
		bounds.add(ground);

		var ceiling = new FlxSprite(0, -16);
		ceiling.makeGraphic(FlxG.width, 16, FlxColor.BROWN);
		ceiling.immovable = true;
		bounds.add(ceiling);

		var leftWall = new FlxSprite(-16, 0);
		leftWall.makeGraphic(16, FlxG.height, FlxColor.BROWN);
		leftWall.immovable = true;
		bounds.add(leftWall);

		var rightWall = new FlxSprite(FlxG.width, 0);
		rightWall.makeGraphic(16, FlxG.height, FlxColor.BROWN);
		rightWall.immovable = true;
		bounds.add(rightWall);
	}

	function setupTestObjects() {
		var house = new House(50, ground.y);
		activeHouses.add(house);
		add(house);

		var wind = new Wind(0, 0, 200, 16, Cardinal.E);
		winds.add(wind);
		add(wind);

		var wind2 = new Wind(0, 120, 200, 8, Cardinal.W);
		winds.add(wind2);
		add(wind2);

		var box = new Box(90, 70);
		boxes.add(box);
		add(box);

		// var box2 = new Box(60, 80);
		// boxes.add(box2);
		// add(box2);

		var rocket = new Rocket(20, ground.y);
		rockets.add(rocket);
		add(rocket);

		player = new Player();
		add(player);
	}

	public function addBoom(rocketBoom:RocketBoom) {
		rocketsBooms.add(rocketBoom);
		add(rocketBoom);
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
