package states;

import flixel.math.FlxMath;
import input.SimpleController;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import states.transitions.Trans;
import states.transitions.SwirlTransition;
import com.bitdecay.analytics.Bitlytics;
import config.Configure;
import flixel.FlxG;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITypedButton;
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

			// var keys:Int = 0;
			// if (Configure.config.menus.keyboardNavigation) {
			// 	keys |= FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_WASD;
			// }
			// if (Configure.config.menus.controllerNavigation) {
			// 	keys |= FlxUICursor.GAMEPAD_DPAD;
			// }
			// cursor.setDefaultKeys(keys);
		// }

		FmodManager.PlaySong(FmodSongs.LetsGo);
		bgColor = FlxColor.TRANSPARENT;
		FlxG.camera.pixelPerfectRender = true;

		// #if !windows
		// // Hide exit button for non-windows targets
		// var test = _ui.getAsset("exit_button");
		// test.visible = false;
		// #end

		// Trigger our focus logic as we are just creating the scene
		this.handleFocus();

		// we will handle transitions manually
		transOut = null;
	}

	// override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
	// 	if (name == FlxUITypedButton.CLICK_EVENT) {
	// 		var button_action:String = params[0];
	// 		trace('Action: "${button_action}"');

	// 		if (button_action == "play") {
	// 			clickPlay();
	// 		}

	// 		if (button_action == "credits") {
	// 			clickCredits();
	// 		}

	// 		#if windows
	// 		if (button_action == "exit") {
	// 			clickExit();
	// 		}
	// 		#end
	// 	}
	// }

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		if (FlxG.keys.pressed.D && FlxG.keys.justPressed.M) {
			// Keys D.M. for Disable Metrics
			Bitlytics.Instance().EndSession(false);
			FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
			trace("---------- Bitlytics Stopped ----------");
		}

		if (SimpleController.just_pressed(Button.DOWN)) {
			cursorIndex++;
		}

		if (SimpleController.just_pressed(Button.UP)) {
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

		if (SimpleController.just_pressed(Button.A)) {
			switch(cursorIndex) {
				case 0:
					clickPlay();
				case 1:
					clickCredits();
				default:
					trace('no menu item for index ${cursorIndex}');
			}
		}
	}

	function clickPlay():Void {
		FmodManager.StopSong();
		var swirlOut = new SwirlTransition(Trans.OUT, () -> {
			// make sure our music is stopped;
			FmodManager.StopSongImmediately();
			FlxG.switchState(new PlayState());
		}, FlxColor.GRAY);
		openSubState(swirlOut);
	}

	function clickCredits():Void {
		FmodFlxUtilities.TransitionToState(new CreditsState());
	}

	#if windows
	function clickExit():Void {
		System.exit(0);
	}
	#end

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
