package;

import config.Configure;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;
import states.SplashScreenState;
#if play
import states.PlayState;
#else
import misc.Macros;
import states.MainMenuState;
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
		FlxG.autoPause = false;
		#end
	}
}
