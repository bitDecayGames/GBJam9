package levels;

import flixel.math.FlxPoint;

class EntityMarker {
	public var location:FlxPoint;
	public var entityName:String;
	public var maker:()->Void;

	public function new(name:String, l:FlxPoint, makerFunc:()->Void) {
		entityName = name;
		location = l;
		maker = makerFunc;
	}
}