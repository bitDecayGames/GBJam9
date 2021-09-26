package entities;

import entities.particle.Dust;
import flixel.FlxG;
import states.PlayState;
import flixel.FlxSprite;

class Bomb extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);
		loadGraphic(AssetPaths.bomb__png);
	}

	public function hitLevel() {
		// TODO: SFX player attack strikes ground
		FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);
		cast(FlxG.state, PlayState).addParticle(new Dust(x + width / 2, y + 5, false));
	}
}