package entities;

import flixel.FlxSprite;

class ParentedSprite extends FlxSprite {
	public var parent:FlxSprite;

	public function setParent(p:FlxSprite) {
		parent = p;
	}
}
