package entities;

import entities.particle.Dust;
import flixel.FlxG;
import flixel.FlxSprite;
import states.PlayState;

class Bomb extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);
		loadGraphic(AssetPaths.bomb__png);
	}

	override public function update(delta:Float) {
		super.update(delta);

		// in case they shoot the bullets off screen
		if (y > FlxG.height) {
			kill();
		}
	}

	public function hitLevel() {
		// TODO: SFX (done) player attack strikes ground
		FmodManager.PlaySoundOneShot(FmodSFX.ShootGround);
		cast(FlxG.state, PlayState).addParticle(new Dust(x + width / 2, y + 5, false));
	}
}
