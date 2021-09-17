package states;

import flixel.group.FlxGroup;
import entities.Wind;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxG;
import spacial.Cardinal;

using extensions.FlxStateExt;

class PlayState extends FlxTransitionableState {
	var player:Player;

	var winds:FlxTypedGroup<Wind> = new FlxTypedGroup();

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		var wind = new Wind(0, 0, 200, 16, Cardinal.E);
		winds.add(wind);
		add(wind);

		var wind2 = new Wind(0, 100, 200, 16, Cardinal.W);
		winds.add(wind2);
		add(wind2);

		player = new Player();
		add(player);
	}

	override public function update(elapsed:Float) {
		FlxG.overlap(player, winds,
			function (p:Player, w:Wind) {
				w.blowOn(p);
			}
		);
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
