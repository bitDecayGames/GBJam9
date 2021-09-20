package levels.ogmo;

import entities.House;
import flixel.FlxG;
import spacial.Cardinal;
import entities.Bird;
import flixel.math.FlxPoint;
import states.PlayState;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

/**
 * Template for loading an Ogmo level file
**/
class Level {
	public var layer:FlxTilemap;

	public var takeoff:FlxSprite;
	public var landing:FlxSprite;
	public var triggeredEntities:Array<EntityMarker> = new Array();
	public var staticEntities:Array<EntityMarker> = new Array();

	public function new(level:String, state:PlayState) {
		var loader = new FlxOgmo3Loader(AssetPaths.project__ogmo, level);
		layer = loader.loadTilemap(AssetPaths.player__png, "layout");

		loader.loadEntities((entityData) -> {
			switch (entityData.name) {
				case "bird":
					var triggerPoint = FlxPoint.get(entityData.x, entityData.y);
					if (entityData.values.direction == "E") {
						// if the bird is flying left-to-right, we spawn it one screen width late
						triggerPoint.x += FlxG.width;
					}
					triggeredEntities.push(new EntityMarker(
						entityData.name,
						triggerPoint,
						() -> {
							state.addBird(new Bird(entityData.x, entityData.y, Cardinal.W));
						}
					));
				case "house":
					// spawn houses up front, as they are static
					staticEntities.push(new EntityMarker(
						entityData.name,
						FlxPoint.get(entityData.x, entityData.y),
						() -> {
							state.addHouse(new House(entityData.x, entityData.y));
						}
					));
				case "para_box":
					// obj = new FlxObject();
				default:
					throw 'Entity \'${entityData.name}\' is not supported, add parsing to ${Type.getClassName(Type.getClass(this))}';
			}
		}, "entities");
	}
}
