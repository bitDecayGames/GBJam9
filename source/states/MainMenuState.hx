package states;

import flixel.util.FlxTimer;
import metrics.Trackers;
import input.SimpleController;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import com.bitdecay.analytics.Bitlytics;
import config.Configure;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;

using extensions.FlxStateExt;

#if windows
import lime.system.System;
#end

class MainMenuState extends FlxUIState {
	var _btnPlay:FlxButton;
	var _btnCredits:FlxButton;
	var _btnExit:FlxButton;

	var disableCursor = true;

	var _txtTitle:FlxText;

	var selector:FlxSprite;
	var cursorIndex = 0;
	var buttonLocations = [
		// Play Button
		FlxPoint.get(10, 95),
		// Credits Button
		FlxPoint.get(10, 106)
	];

	override public function create():Void {
		_xml_id = "main_menu";
		if (Configure.config.menus.keyboardNavigation || Configure.config.menus.controllerNavigation) {
			_makeCursor = true;
		}

		super.create();

		// if (_makeCursor) {
		selector = new FlxSprite();
		selector.loadGraphic(AssetPaths.indicators__png, true, 8, 8);
		selector.animation.add("pointing", [0, 1], 3, true, true);
		selector.animation.play("pointing");
		add(selector);

		bgColor = FlxColor.TRANSPARENT;
		FlxG.camera.pixelPerfectRender = true;

		// Trigger our focus logic as we are just creating the scene
		this.handleFocus();

		// we will handle transitions manually
		transOut = null;

		new FlxTimer().start(0.5, (t) -> {
			// fix a small bug where the controls double-click and immediately start the game after getting
			// back to the title screen
			disableCursor = false;
		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		if (FlxG.keys.pressed.D && FlxG.keys.justPressed.M) {
			// Keys D.M. for Disable Metrics
			Bitlytics.Instance().EndSession(false);
			FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
			trace("---------- Bitlytics Stopped ----------");
		}

		if (SimpleController.just_pressed(Button.DOWN) && !disableCursor) {
			FmodManager.PlaySoundOneShot(FmodSFX.MenuHover);
			cursorIndex++;
		}

		if (SimpleController.just_pressed(Button.UP) && !disableCursor) {
			FmodManager.PlaySoundOneShot(FmodSFX.MenuHover);
			cursorIndex--;
		}

		if (cursorIndex >= buttonLocations.length) {
			cursorIndex = 0;
		}

		if (cursorIndex < 0) {
			cursorIndex = buttonLocations.length - 1;
		}

		selector.x = buttonLocations[cursorIndex].x;
		selector.y = buttonLocations[cursorIndex].y;

		if (SimpleController.just_pressed(Button.A) && !disableCursor) {
			switch (cursorIndex) {
				case 0:
					clickPlay();
					FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
					disableCursor = true;
				case 1:
					clickCredits();
					FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
				default:
					trace('no menu item for index ${cursorIndex}');
			}
		}
	}

	function clickPlay():Void {
		// reset level scores
		Trackers.levelScores = [];
		FmodFlxUtilities.TransitionToStateAndStopMusic(new PlayState());
	}

	function clickCredits():Void {
		FmodFlxUtilities.TransitionToState(new CreditsState());
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
