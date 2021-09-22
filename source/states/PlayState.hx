package states;

import levels.ogmo.Level;
import ui.font.BitmapText;
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
	var level:Level;
	var scrollSpeed = 3;

	var player:Player;
	var ground:FlxSprite;

	var ceiling:FlxSprite = new FlxSprite();
	var walls:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var winds:FlxTypedGroup<Wind> = new FlxTypedGroup();
	var birds:FlxTypedGroup<Bird> = new FlxTypedGroup();
	var boxes:FlxTypedGroup<Box> = new FlxTypedGroup();
	var activeHouses:FlxTypedGroup<House> = new FlxTypedGroup();
	var rockets:FlxTypedGroup<Rocket> = new FlxTypedGroup();
	var bombs:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var rocketsBooms:FlxTypedGroup<RocketBoom> = new FlxTypedGroup();

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		level = new Level(AssetPaths.test__json, this);
		#if debug
		trace('statics: ${level.staticEntities}');
		trace('triggers: ${level.triggeredEntities}');
		#end

		// stretch it a bit outside the level bounds to make sure off-screen stuff works properly
		FlxG.worldBounds.set(-100, -100, level.layer.widthInTiles * 8 + 100, level.layer.heightInTiles * 8 + 100);

		// var font = new PressStart(30, 30, "Instance of a BitmapFont");
		// add(font);

		setupScreenBounds();

		add(level.layer);

		for (marker in level.staticEntities) {
			marker.maker();
		}

		setupTestObjects();

		// var mockPoints = new PressStart(8, FlxG.height - 17, "Score\n1234");
		// add(mockPoints);

		// var mockTime = new PressStart(FlxG.width - 8 * 6, FlxG.height - 17, "  Time\n1:35:14");
		// add(mockTime);
	}

	override public function update(delta:Float) {
		doCollisions();

		checkTriggers();

		FlxG.camera.scroll.x += scrollSpeed * delta;
		alignBounds();

		super.update(delta);

		// DEBUG STUFF
		if (FlxG.keys.justPressed.B) {
			var bird = new Bird(FlxG.width, FlxG.height / 5, Cardinal.W);
			birds.add(bird);
			add(bird);
		}
	}

	function checkTriggers() {
		for (marker in level.triggeredEntities) {
			// TODO: Probably should make a dedicated box to check these collisions against
			if (walls.members[1].overlapsPoint(marker.location)) {
				marker.maker();
				level.triggeredEntities.remove(marker);
			}
		}
	}

	function doCollisions() {
		FlxG.collide(player.balloon, ceiling);
		FlxG.collide(level.layer, player.balloon);
		FlxG.overlap(player.balloon, walls, function(balloon:ParentedSprite, wall:FlxSprite) {
			// check left wall
			if (wall == walls.members[0]) {
				balloon.velocity.set(scrollSpeed, balloon.velocity.y);
				balloon.x = wall.x + wall.width + 1;
			}

			// check right wall
			if (wall == walls.members[1]) {
				balloon.velocity.set(scrollSpeed, balloon.velocity.y);
				balloon.x = wall.x - balloon.width - 1;
			}
		});

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

		// check boxes against houses first
		FlxG.overlap(boxes, activeHouses, (b, h) -> {
			if (b.dropped) {
				h.packageArrived(b);
				activeHouses.remove(h);
			}
		});

		for (box in boxes) {
			level.layer.overlapsWithCallback(box, (g, b) -> {
				// only collide boxes with ground if they aren't attached to the player
				if (box.attached) {
					return false;
				}

				FlxObject.separate(b, g);
				// stop the box if it collides with the ground
				b.velocity.set(0, 0);
				// make sure the box isn't inside the ground
				b.y = g.y - b.height;
				return true;
			});
		}

		FlxG.overlap(bombs, birds, (bo, bi) -> {
			// TODO: Hook up fancier deaths
			bo.kill();
			bi.kill();
		});

		FlxG.collide(level.layer, bombs, (g, b) -> {
			b.kill();
		});
	}

	public function setupScreenBounds() {
		ceiling = new FlxSprite(0, -16);
		ceiling.makeGraphic(FlxG.width, 16, FlxColor.BROWN);
		ceiling.immovable = true;

		var leftWall = new FlxSprite(-16, 0);
		leftWall.makeGraphic(16, FlxG.height, FlxColor.BROWN);
		leftWall.immovable = true;
		walls.add(leftWall);

		var rightWall = new FlxSprite(FlxG.width, 0);
		rightWall.makeGraphic(16, FlxG.height, FlxColor.BROWN);
		rightWall.immovable = true;
		walls.add(rightWall);
	}

	function alignBounds() {
		cast(ceiling, FlxSprite).x = FlxG.camera.scroll.x;

		// left wall
		var left = cast(walls.members[0], FlxSprite);
		left.x = FlxG.camera.scroll.x - left.width;

		// right wall
		cast(walls.members[1], FlxSprite).x = FlxG.camera.scroll.x + FlxG.width;
	}

	function setupTestObjects() {
		// var house = new House(50, ground.y);
		// activeHouses.add(house);
		// add(house);

		// var wind = new Wind(0, 0, 200, 16, Cardinal.E);
		// winds.add(wind);
		// add(wind);

		// var wind2 = new Wind(0, 120, 200, 8, Cardinal.W);
		// winds.add(wind2);
		// add(wind2);

		// var box = new Box(90, 70);
		// boxes.add(box);
		// add(box);

		// var box2 = new Box(60, 80);
		// boxes.add(box2);
		// add(box2);

		// var rocket = new Rocket(20, ground.y);
		// rockets.add(rocket);
		// add(rocket);

		player = new Player();
		player.x = 30;
		add(player);
	}

	public function addBoom(rocketBoom:RocketBoom) {
		rocketsBooms.add(rocketBoom);
		add(rocketBoom);
	}

	public function addBomb(bomb:FlxSprite) {
		bombs.add(bomb);
		add(bomb);
	}

	public function addBird(bird:Bird) {
		birds.add(bird);
		add(bird);
	}

	public function addHouse(house:House) {
		activeHouses.add(house);
		add(house);
	}

	public function addWind(wind:Wind) {
		winds.add(wind);
		add(wind);
	}

	public function addBox(box:Box) {
		boxes.add(box);
		add(box);
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
