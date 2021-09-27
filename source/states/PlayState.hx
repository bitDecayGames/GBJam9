package states;

import flixel.FlxObject;
import entities.Shadow;
import metrics.DropScore;
import haxefmod.flixel.FmodFlxUtilities;
import metrics.Metrics;
import com.bitdecay.analytics.Bitlytics;
import flixel.util.FlxTimer;
import metrics.Points;
import flixel.util.FlxStringUtil;
import flixel.text.FlxBitmapText;
import metrics.Trackers;
import entities.Bomb;
import entities.Truck;
import entities.particle.Splash;
import flixel.math.FlxPoint;
import entities.Tree;
import entities.Fuse;
import flixel.util.FlxPool;
import entities.Gust;
import entities.Landing;
import flixel.effects.FlxFlicker;
import input.SimpleController;
import levels.ogmo.Level;
import ui.font.BitmapText;
import entities.ParentedSprite;
import entities.RocketBoom;
import entities.Bird;
import entities.Box;
import entities.House;
import entities.Player;
import entities.Rocket;
import entities.Wind;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import signals.Lifecycle;
import spacial.Cardinal;

using extensions.FlxStateExt;

class PlayState extends FlxTransitionableState {
	public static inline var WALL_WIDTH = 16;

	public static inline var SCROLL_SPEED = 4;

	public static var currentLevel = 0;
	public static var levelOrder = [
		AssetPaths.level1__json,
		AssetPaths.level2__json,
		AssetPaths.level3__json,
		AssetPaths.level4__json,
	];

	var level:Level;

	var levelStarted = false;
	var levelFinished = false;
	var scrollSpeed = SCROLL_SPEED;

	var player:Player;
	var ground:FlxSprite;

	var launchText:BitmapText;

	var ceiling:FlxSprite = new FlxSprite();
	var walls:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var playerGroup:FlxTypedGroup<Player> = new FlxTypedGroup();
	var shadows:FlxTypedGroup<Shadow> = new FlxTypedGroup();
	var winds:FlxTypedGroup<Wind> = new FlxTypedGroup();
	var gusts:FlxTypedGroup<Gust> = new FlxTypedGroup();
	var birds:FlxTypedGroup<Bird> = new FlxTypedGroup();
	var houses:FlxTypedGroup<House> = new FlxTypedGroup();
	var trees:FlxTypedGroup<Tree> = new FlxTypedGroup();
	var waters:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var splashes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var landing:FlxTypedGroup<Landing> = new FlxTypedGroup();
	var boxes:FlxTypedGroup<Box> = new FlxTypedGroup();
	var rockets:FlxTypedGroup<Rocket> = new FlxTypedGroup();
	var fuses:FlxTypedGroup<Fuse> = new FlxTypedGroup();
	var bombs:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var trucks:FlxTypedGroup<Truck> = new FlxTypedGroup(); // for collisions
	var backTrucks:FlxTypedGroup<Truck> = new FlxTypedGroup(); // for rendering order
	var frontTrucks:FlxTypedGroup<Truck> = new FlxTypedGroup(); // for rendering order
	var rocketsBooms:FlxTypedGroup<RocketBoom> = new FlxTypedGroup();


	var activeHouses:FlxTypedGroup<House> = new FlxTypedGroup();

	var gustPool = new FlxPool<Gust>(Gust);

	var timeDisplay:FlxBitmapText;
	var pointsDisplay:FlxBitmapText;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		#if hitbox
		FlxG.debugger.drawDebug = true;
		#end

		// TODO: Keep an eye on this and see if we get more split glitch/flicker
		gustPool.preAllocate(100);

		var levelFile = levelOrder[PlayState.currentLevel];

		#if testland
		levelFile = AssetPaths.takeoff_landing_test__json;
		#end

		level = new Level(levelFile, this);
		#if debug
		trace('statics: ${level.staticEntities}');
		trace('triggers: ${level.triggeredEntities}');
		#end

		// stretch it a bit outside the level bounds to make sure off-screen stuff works properly
		FlxG.worldBounds.set(-100, -100, level.layer.widthInTiles * 8 + 100, level.layer.heightInTiles * 8 + 100);

		setupScreenBounds();

		// Adding these in proper rending order
		level.bgDecals.forEach((decal) -> {
			cast(decal, FlxSprite).scrollFactor.set(.5, 0);
		});
		add(level.bgDecals);
		add(winds);
		add(level.decor);
		add(level.layer);
		add(birds);
		add(houses);
		add(trees);
		add(gusts);
		add(backTrucks);
		add(shadows);
		add(playerGroup);
		add(bombs);
		add(boxes);
		add(fuses);
		add(rockets);
		add(frontTrucks);
		add(rocketsBooms);
		add(waters);
		add(splashes);
		add(landing);

		for (marker in level.staticEntities) {
			marker.maker();
		}

		setupTestObjects();

		launchText = new AerostatRed(30, 30, "PRESS UP TO\n TAKE OFF! ");
		launchText.x = (FlxG.width - launchText.width) / 2;
		FlxFlicker.flicker(launchText, 0, 0.5);
		add(launchText);

		if (currentLevel == 0) {
			var finishText = new AerostatRed(0, 80, "LAND HERE!");
			finishText.x = (FlxG.width - finishText.width) * .75 - FlxG.width + level.layer.width;
			// finishText.scrollFactor.set(0, 0);
			FlxFlicker.flicker(finishText, 0, 0.5);
			add(finishText);
		}

		// Reset scores
		Trackers.attemptTimer = 0;
		Trackers.points = 0;
		Trackers.drops = new Array<DropScore>();
		Trackers.houseMax = level.houseCount;

		timeDisplay = new AerostatRed(0, 0, "T");
		timeDisplay.scrollFactor.set();

		pointsDisplay = new AerostatRed(FlxG.width - 8 * 6, 0, "000000");
		pointsDisplay.scrollFactor.set();

		// add this last so it is on top of everything else
		add(timeDisplay);
		add(pointsDisplay);
	}

	override public function update(delta:Float) {
		#if debug
		FlxG.watch.addQuick("Gust Pool size: ", gustPool.length);
		FlxG.watch.addQuick("init count: ", Gust.initCount);
		#end

		if (player.controllable) {
			Trackers.attemptTimer += delta;
			timeDisplay.text = "T" + StringTools.lpad(FlxStringUtil.formatTime(Trackers.attemptTimer, false), " ", 5);
		}

		pointsDisplay.text = StringTools.lpad(Std.string(Trackers.points), "0", 6);

		if (!levelStarted) {
			if (SimpleController.just_pressed(Button.UP)) {
				levelStarted = true;
				FlxFlicker.stopFlickering(launchText);
				launchText.kill();
				player.takeControl();

				// TODO: Need to make the player feel like they took control
				player.velocity.y = -10;

				// Trigger anything that's on-screen at start
				for (marker in level.triggeredEntities) {
					if (marker.location.x <= FlxG.width) {
						marker.maker();
					}
				}

				// TODO: Metrics level start
			}
		}

		FlxG.camera.scroll.x = player.playerMiddleX() - FlxG.camera.width / 2;

		FlxG.camera.scroll.x = Math.max(0, FlxG.camera.scroll.x);
		FlxG.camera.scroll.x = Math.min(level.layer.width - FlxG.camera.width, FlxG.camera.scroll.x);

		doCollisions();

		checkTriggers();

		alignBounds();

		super.update(delta);
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
		FlxG.overlap(player, landing, function(p:Player, l:Landing) {
			if (player.isControllable() && !levelFinished) {
				Trackers.landingBonus = l.getScore(player.playerMiddleX());
				levelFinished = true;

				if (player.controllable){

					FmodManager.PlaySoundOneShot(FmodSFX.BalloonLand);

					if (FmodManager.IsSoundPlaying("BalloonDeflate")) {
						FmodManager.StopSoundImmediately("BalloonDeflate");
					}

					if (FmodManager.IsSoundPlaying("BalloonFire")) {
						FmodManager.StopSoundImmediately("BalloonFire");
					}
				}

				player.loseControl();
				player.velocity.set();
				player.maxVelocity.set();

				// TODO: Metrics record complete time and level number
				Bitlytics.Instance().Queue(Metrics.FINISH_POINTS, Trackers.points);
				Bitlytics.Instance().Queue(Metrics.FINISH_TIME, Trackers.attemptTimer);

				// A good time to flush the metrics in case player closes game right as they finish
				Bitlytics.Instance().ForceFlush();

				new FlxTimer().start(2, (t) -> {
					FmodFlxUtilities.TransitionToStateAndStopMusic(new SummaryState());
				});
			}
		});

		// Keep player in bounds
		// XXX: WE are doing brute checks against x and y positions because collisions are really jacked up with FlxSpriteGroups
		if (player.y < 0) {
			player.velocity.y = 0;
			player.y = 0;
		}

		if (player.x < camera.scroll.x) {
			player.velocity.x = 0;
			player.x = camera.scroll.x;
		}

		// TODO: This width calculation may not be good as it takes the indicator into account
		if (player.x > camera.scroll.x + camera.width - player.collisionWidth) {
			player.velocity.x = 0;
			player.x = camera.scroll.x + camera.width - player.collisionWidth;
		}

		// TODO: the FlxSpriteGroup drifts because of this... need to figure out a different way to handle this
		// FlxG.collide(level.layer, player);

		if (player.y + player.collisionHeight > Player.PLAYER_LOWEST_ALTITUDE) {
			player.velocity.y = 0;
			player.y = Player.PLAYER_LOWEST_ALTITUDE - player.collisionHeight;
		}

		// TODO: This seems even more buggy. wtf.
		// level.layer.overlapsWithCallback(player, (l, b) -> {
		// 	player.y = l.y - 24 - 5;
		// 	player.velocity.y = 0;
		// 	return true;
		// });

		FlxG.overlap(player, winds, function(p:Player, w:Wind) {
			w.blowOn(player);
		});

		FlxG.overlap(player, birds, function(p:Player, b:Bird) {
			if (b.isDead()) {
				return;
			}

			player.hitBy(b);
			Trackers.points += Points.HIT_BY_BIRD;
		});

		FlxG.overlap(trees, winds, function(t:Tree, w:Wind) {
			t.beBlown();
		});

		FlxG.overlap(player, rocketsBooms, function(p:Player, r:ParentedSprite) {
			// we collide with the sub-particles of the RocketBoom
			var boom = cast(r.parent, RocketBoom);
			if (!boom.hasHitPlayer()) {
				player.hitBy(boom);
				Trackers.points += Points.HIT_BY_FIREWORK;
			}
		});

		// boxes are FlxSpriteGroups which have a lot of weirdness... so loop through manually
		for (box in boxes) {

			FlxG.overlap(box.box, winds, function(p:ParentedSprite, w:Wind) {
				if (box.isChuteOpen()) {
					w.blowOn(box);
				}
			});

			// check boxes against houses first
			FlxG.overlap(box.box, activeHouses, (p:ParentedSprite, h:House) -> {
				trace('box touch house. HouseDel: ${h.deliverable}     b.dropped: ${cast(p.parent, Box).dropped}');
				if (h.deliverable) {
					if (cast(p.parent, Box).dropped) {
						h.packageArrived(cast(p.parent, Box));
						activeHouses.remove(h);

						cast(p.parent, Box).grabbable = false;

						Trackers.points += Points.DELIVERY;
					}
				}
			});

			// Boxes vs player
			FlxG.overlap(player, box.box, (balloon, b) -> {
				if (box.grabbable) {
					cast(balloon.parent, Player).addBox(box);
				}
			});

			// Boxes vs level
			level.layer.overlapsWithCallback(box.box, (g, b) -> {
				// only collide boxes with ground if they aren't attached to the player
				if (box.attached) {
					return false;
				}

				// XXX: So ugly...
				cast(cast(b, ParentedSprite).parent, Box).hitLevel(g);

				// stop the box if it collides with the ground
				// b.velocity.set(0, 0);
				// make sure the box isn't inside the ground
				// b.y = g.y - b.height;
				return true;
			});

			FlxG.overlap(box, waters, (b:FlxSprite, w:FlxSprite) -> {
				box.kill();
				addSplash(b.getMidpoint(), true);

				// TODO: SFX big splash
				FmodManager.PlaySoundOneShot(FmodSFX.Splash);

				Trackers.points += Points.LOST_PACKAGE;

				Bitlytics.Instance().Queue(Metrics.LOST_BOXES, 1);
			});
		}

		FlxG.overlap(bombs, birds, (bo, bi) -> {
			// TODO: Hook up fancier deaths
			bo.kill();
			bi.die();

			Trackers.points += Points.KILL_BIRD;
		});

		FlxG.overlap(bombs, trucks, (b, t:Truck) -> {
			if (!t.exploded) {
				b.kill();
				t.hit();

				Trackers.points += Points.KILL_TRUCK;
			}
		});

		FlxG.collide(level.layer, bombs, (g, b:Bomb) -> {
			b.kill();
			b.hitLevel();
		});

		FlxG.collide(level.layer, birds, (g, b:Bird) -> {
			b.thud();
		});

		FlxG.overlap(bombs, waters, (b, w) -> {
			b.kill();
			addSplash(b.getMidpoint(), false);

			// TODO: SFX small splash
			FmodManager.PlaySoundOneShot(FmodSFX.SplashSmall);
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

	function setupTestObjects() {}

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

	public function addTree(tree:Tree) {
		trees.add(tree);
	}

	public function addBox(box:Box) {
		boxes.add(box);

		shadows.add(new Shadow(box, 0, 8, 0));
	}

	public function addRocket(rocket:Rocket) {
		rockets.add(rocket);
	}

	public function addFuse(fuse:Fuse) {
		fuses.add(fuse);
	}

	public function addPlayer(player:Player) {
		this.player = player;
		playerGroup.add(player);

		shadows.add(new Shadow(player, 0, player.collisionHeight, -1));
	}

	public function addLanding(l:Landing) {
		landing.add(l);
	}

	public function addGust(x:Float, y:Float, dir:Cardinal) {
		var gust = gustPool.get();
		gusts.add(gust);
		gust.setup(x, y, dir);
		gust.done = () -> {
			gustPool.put(gust);
		};
	}

	public function addWater(water:FlxSprite) {
		waters.add(water);
	}

	public function addParticle(p:FlxSprite) {
		splashes.add(p);
	}

	public function addTruck(truck:Truck, front:Bool = true) {
		if (front) {
			frontTrucks.add(truck);
		} else {
			backTrucks.add(truck);
		}
		trucks.add(truck);
	}

	function addSplash(p:FlxPoint, big:Bool) {
		var splash = new Splash(p.x, p.y, big);
		splashes.add(splash);
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
