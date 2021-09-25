package entities;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Landing extends FlxSprite {
    public function new(x:Float, y:Float) {
        // XXX: We need this to protrude from the ground a bit so we can actually collide with it
        super(x, y - 3);

        // TODO: Load real graphics
        makeGraphic(32, 8, FlxColor.MAGENTA);
    }
}