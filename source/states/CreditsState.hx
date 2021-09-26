package states;

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
	override public function create():Void {
		super.create();

		var credits = new FlxSprite(AssetPaths.credits__png);
		add(credits);

		FmodManager.PlaySong(FmodSongs.HopIn);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (SimpleController.just_pressed(Button.A)) {
			clickMainMenu();
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
