package levels.ogmo;

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

	public var takeoff:FlxSprite;
	public var landing:FlxSprite;
	public var triggeredEntities:Array<EntityMarker> = new Array();
	public var staticEntities:Array<EntityMarker> = new Array();

	public function new(level:String, state:PlayState) {
		var loader = new FlxOgmo3Loader(AssetPaths.project__ogmo, level);

		layer = loader.loadTilemap(AssetPaths.ground_new__png, "layout");
		decor = loader.loadTilemap(AssetPaths.ground_new__png, "decor");

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
					triggeredEntities.push(new EntityMarker(entityData.name, triggerPoint, () -> {
						state.addBox(new Box(entityData.x, entityData.y, entityData.values.open_at * 8));
					}));
				case "rocket":
					var triggerPoint = FlxPoint.get(entityData.x, entityData.y);
					// delay is number of tiles
					triggerPoint.x += entityData.values.delay * 8;
					var rocket = new Rocket(entityData.x, entityData.y, entityData.values.alt * 8);
					state.addRocket(rocket);
					triggeredEntities.push(new EntityMarker(entityData.name, triggerPoint, () -> {
						rocket.fly();
					}));

				// START Statics
				case "house":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addHouse(new House(entityData.x, entityData.y));
					}));
				case "friendlyHouse":
					staticEntities.push(new EntityMarker(entityData.name, FlxPoint.get(entityData.x, entityData.y), () -> {
						state.addHouse(new House(entityData.x, entityData.y));
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
				default:
					var msg = 'Entity \'${entityData.name}\' is not supported, add parsing to ${Type.getClassName(Type.getClass(this))}';
					#if debug
					trace(msg);
					#else
					throw msg;
					#end
			}
		}, "entities");
	}
}
