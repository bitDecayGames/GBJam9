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
	public static inline var WALL_WIDTH = 16;

	var level:Level;
	var scrollSpeed = 3;

	var player:Player;
	var ground:FlxSprite;

	var ceiling:FlxSprite = new FlxSprite();
	var walls:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var playerGroup:FlxTypedGroup<Player> = new FlxTypedGroup();
	var winds:FlxTypedGroup<Wind> = new FlxTypedGroup();
	var birds:FlxTypedGroup<Bird> = new FlxTypedGroup();
	var houses:FlxTypedGroup<House> = new FlxTypedGroup();
	var boxes:FlxTypedGroup<Box> = new FlxTypedGroup();
	var rockets:FlxTypedGroup<Rocket> = new FlxTypedGroup();
	var bombs:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var rocketsBooms:FlxTypedGroup<RocketBoom> = new FlxTypedGroup();

	var activeHouses:FlxTypedGroup<House> = new FlxTypedGroup();

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

		// Adding these in proper rending order
		add(winds);
		add(level.layer);
		add(houses);
		add(playerGroup);
		add(bombs);
		add(boxes);
		add(rockets);
		add(rocketsBooms);
		add(birds);

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
		// Keep player in bounds

		// TODO: For some reason the player warps to the right side of the screen sometimes...
		//    it seems to happen both with collide AND overlap. Need to dig more
		FlxG.collide(player.balloon, ceiling);
		// FlxG.overlap(player.balloon, ceiling, (b, c) -> {
		// 	b.velocity.set(b.velocity.x, 0);
		// 	b.y = ceiling.y + ceiling.height + 1;
		// });

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
		ceiling = new FlxSprite(0, -WALL_WIDTH);
		// XXX: Might be better to make a small graphic, then adjust width/height
		ceiling.makeGraphic(Std.int(level.layer.width), WALL_WIDTH, FlxColor.BROWN);
		ceiling.immovable = true;

		var leftWall = new FlxSprite(-WALL_WIDTH, 0);
		leftWall.makeGraphic(WALL_WIDTH, FlxG.height, FlxColor.BROWN);
		leftWall.immovable = true;
		walls.add(leftWall);

		var rightWall = new FlxSprite(FlxG.width, 0);
		rightWall.makeGraphic(WALL_WIDTH, FlxG.height, FlxColor.BROWN);
		rightWall.immovable = true;
		walls.add(rightWall);
	}

	function alignBounds() {
		// left wall
		var left = cast(walls.members[0], FlxSprite);
		left.x = FlxG.camera.scroll.x - left.width;

		// right wall
		cast(walls.members[1], FlxSprite).x = FlxG.camera.scroll.x + FlxG.width;
	}

	function setupTestObjects() {
		// TODO: Load player from ogmo level
		player = new Player();
		player.x = 30;
		playerGroup.add(player);
	}

	public function addBoom(rocketBoom:RocketBoom) {
		rocketsBooms.add(rocketBoom);
	}

	public function addBomb(bomb:FlxSprite) {
		bombs.add(bomb);
	}

	public function addBird(bird:Bird) {
		birds.add(bird);
	}

	public function addHouse(house:House) {
		houses.add(house);
		activeHouses.add(house);
	}

	public function addWind(wind:Wind) {
		winds.add(wind);
	}

	public function addBox(box:Box) {
		boxes.add(box);
	}

	public function addRocket(rocket:Rocket) {
		rockets.add(rocket);
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
