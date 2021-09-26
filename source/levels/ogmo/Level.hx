package levels.ogmo;

import entities.RedTruck;
import entities.Truck;
import flixel.util.FlxColor;
import entities.Tree;
import entities.Fuse;
import entities.TriggerableSprite;
import flixel.group.FlxGroup;
import entities.Landing;
import entities.Player;
import entities.Bird;
import entities.Box;
import entities.House;
import entities.Rocket;
import entities.Wind;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import states.PlayState;

/**
 * Template for loading an Ogmo level file
**/
class Level {
	public var layer:FlxTilemap;
	public var decor:FlxTilemap;
	public var bgDecals:FlxGroup;

	public var takeoff:FlxSprite;
	public var landing:FlxSprite;
	public var triggeredEntities:Array<EntityMarker> = new Array();
	public var staticEntities:Array<EntityMarker> = new Array();

	public function new(level:String, state:PlayState) {
		var loader = new FlxOgmo3Loader(AssetPaths.project__ogmo, level);

		layer = loader.loadTilemap(AssetPaths.ground_new__png, "layout");
		decor = loader.loadTilemap(AssetPaths.ground_new__png, "decor");

		bgDecals = loader.loadDecals("background", "assets/");

		var boxId:Int = 0;

		loader.loadEntities((entityData) -> {
			switch (entityData.name) {
				// START Dynamics
				case "bird":
					var triggerPoint = FlxPoint.get(entityData.x, entityData.y);
					if (entityData.values.direction == "E") {
						// if the bird is flying left-to-right, we spawn it one screen width late
						triggerPoint.x += FlxG.width + PlayState.WALL_WIDTH;
					}
					triggeredEntities.push(new EntityMarker(entityData.name, triggerPoint, () -> {
						state.addBird(new Bird(entityData.x, entityData.y, Cardinal.fromString(entityData.values.direction)));
					}));
				case "para_box":
					var triggerPoint = FlxPoint.get(entityData.x, entityData.y);
					// delay is number of tiles
					triggerPoint.x += entityData.values.delay * 8;
					var marker = new EntityMarker(entityData.name, triggerPoint, () -> {
						state.addBox(new Box(boxId++, entityData.x, entityData.y, entityData.values.open_at * 8));
					});

					// to let us have stuff spawn immediately
					if (entityData.x < FlxG.width) {
						staticEntities.push(marker);
					} else {
						triggeredEntities.push(marker);
					}
				case "rocket":
					var triggerPoint = FlxPoint.get(entityData.x, entityData.y);

					var rocket = new Rocket(entityData.x, entityData.y, entityData.values.alt * 8);
					state.addRocket(rocket);

					var triggeree:TriggerableSprite = rocket;
					// delay is in number of fuse segments
					for (i in 0...entityData.values.delay) {
						var fuse = new Fuse(triggeree.x - 8, triggeree.y, triggeree);
						state.addFuse(fuse);
						triggeree = fuse;
					}

					triggeredEntities.push(new EntityMarker(entityData.name, triggerPoint, () -> {
						triggeree.trigger();
					}));
				case "truck":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addTruck(new Truck(entityData.x, entityData.y));
					}));
				case "big_truck":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addTruck(new RedTruck(entityData.x, entityData.y));
					}));

				// START Statics
				case "house":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addHouse(new House(entityData.x, entityData.y, true));
					}));
				case "friendlyHouse":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addHouse(new House(entityData.x, entityData.y, false));
					}));
				case "wind":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addWind(new Wind(entityData.x, entityData.y, entityData.width, entityData.height,
							Cardinal.fromString(entityData.values.direction), entityData.values.strength));
					}));
				case "takeoff":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addPlayer(new Player(entityData.x, entityData.y));
					}));
				case "landing":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addLanding(new Landing(entityData.x, entityData.y, entityData.width));
					}));
				case "tree":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addTree(new Tree(entityData.x, entityData.y));
					}));
				case "water":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						var water = new FlxSprite(entityData.x, entityData.y);
						water.makeGraphic(entityData.width, entityData.height, FlxColor.BLUE);
						water.alpha = 0;
						#if debug
						water.alpha = 0.2;
						#end
						state.addWater(water);
					}));
				default:
					var msg = 'Entity \'${entityData.name}\' is not supported, add parsing to ${Type.getClassName(Type.getClass(this))}';
					#if debug
					trace(msg);
					#else
					// throw msg;
					#end
			}
		}, "entities");
	}
}
