package levels;

import flixel.math.FlxPoint;

class EntityMarker {
	public var location:FlxPoint;
	public var entityName:String;
	public var maker:() -> Void;

	public function new(name:String, l:FlxPoint, makerFunc:() -> Void) {
		entityName = name;
		location = l;
		#if debug
		maker = () -> {
			trace('triggering ${name}');
			makerFunc();
		}
		#else
		maker = makerFunc;
		#end
	}
}
