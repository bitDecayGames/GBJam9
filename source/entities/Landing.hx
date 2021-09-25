package entities;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Landing extends FlxSprite {
    public function new(x:Float, y:Float) {
        super(x, y);

        // TODO: Load real graphics
        makeGraphic(32, 8, FlxColor.MAGENTA);
    }
}