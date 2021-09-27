package states;

import flixel.util.FlxTimer;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import input.SimpleController;
import flixel.FlxState;
import config.Configure;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.UiHelpers;
import misc.FlxTextFactory;

using extensions.FlxStateExt;

class CreditsState extends FlxState {

	var selector:FlxSprite;
	var disableControls = true;

	override public function create():Void {
		super.create();

		var credits = new FlxSprite(AssetPaths.credits__png);
		add(credits);

		selector = new FlxSprite(18, 116);
		selector.loadGraphic(AssetPaths.indicators__png, true, 8, 8);
		selector.animation.add("pointing", [0, 1], 3, true, true);
		selector.animation.play("pointing");
		add(selector);

		FmodManager.PlaySong(FmodSongs.HopIn);

		new FlxTimer().start((t) -> {
			disableControls = false;
		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!disableControls) {
			if (SimpleController.just_pressed(Button.A) || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER) {
				clickMainMenu();
				FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
			}
		}
	}

	function clickMainMenu():Void {
		FmodFlxUtilities.TransitionToState(new MainMenuState());
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
