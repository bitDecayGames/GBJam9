package;

import states.FinalGradeState;
import states.SplashScreenState;
import misc.Macros;
import states.MainMenuState;
import flixel.FlxState;
import config.Configure;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import misc.FlxTextFactory;
import openfl.display.Sprite;
#if play
import states.PlayState;
#end

class Main extends Sprite {
	public function new() {
		super();
		Configure.initAnalytics(false);

		var startingState:Class<FlxState> = SplashScreenState;
		#if play
		startingState = PlayState;
		#else
		if (Macros.isDefined("SKIP_SPLASH")) {
			startingState = MainMenuState;
		}
		#end

		#if last
		startingState = FinalGradeState;
		#end

		// 160x144 is gameboy resolution
		addChild(new FlxGame(160, 144, startingState, 1, 60, 60, true, false));

		FlxG.fixedTimestep = false;

		// Disable flixel volume controls as we don't use them because of FMOD
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;

		// Don't use the flixel cursor
		FlxG.mouse.useSystemCursor = true;

		#if debug
		#end
		FlxG.autoPause = false;

		// I don't think "fade" transitions are really in the spirit of GB games
		// Set up basic transitions. To override these see `transOut` and `transIn` on any FlxTransitionable states
		// FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.35);
		// FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.35);

		// TODO: if we want another font, we gotta figure out how to get it to work at low resolution
		// FlxTextFactory.defaultFont = AssetPaths.Brain_Slab_8__ttf;
	}
}
