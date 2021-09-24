package entities;

import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.FlxG;

using extensions.FlxPointExt;

class RocketBoom extends FlxSpriteGroup implements PlayerDamager {
	// These are in distance from center
	var radius:Float = 16;
	var particleCount:Int = 8;
	var particleFallDistance = 5;

	var boomOrigin:FlxPoint;

	public var damagedPlayer = false;

	public function new(x:Float, y:Float) {
		// TODO: We create the parent object at the origin and track the correct
		//       position because of weirdness with how collisions between two
		//       FlxSpriteGroups seem to behave
		super();
		boomOrigin = FlxPoint.get(x, y);

		createParticles();
	}

	private function createParticles() {
		var inc = 360 / particleCount;
		var temp:FlxPoint;
		for (angle in 0...particleCount) {
			temp = boomOrigin.pointOnCircumference(angle * inc, radius);
			var particle = new ParentedSprite(temp.x, temp.y);
			particle.parent = this;
			particle.loadGraphic(AssetPaths.sparks__png, true, 8, 8);
			particle.animation.add("play", [0, 1, 2], FlxG.random.int(5, 10));
			particle.animation.play("play");
			add(particle);
			var life = FlxG.random.float(0.75, 2);
			FlxFlicker.flicker(particle, life, FlxG.random.float(0.05, 0.1));
			FlxTween.linearMotion(particle, particle.x, particle.y, particle.x, particle.y + particleFallDistance, life, {
				ease: FlxEase.quadInOut,
				onComplete: (t) -> {
					kill();
				}
			});
		}
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	public function hitPlayer():Void {
		damagedPlayer = true;
	}

	public function hasHitPlayer():Bool {
		return damagedPlayer;
	}
}
