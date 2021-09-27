package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxefmod.flixel.FmodFlxUtilities;
import input.SimpleController;
import metrics.Trackers;
import ui.font.BitmapText.AerostatBig;

using extensions.FlxStateExt;

class FinalGradeState extends FlxState {
	var totalScore:Int = 0;
	var totalScoreDisplay:FlxBitmapText;

	var selector:FlxSprite;
	var cursorIndex = 0;
	var disableCursor = true;

	var creditTimer = 8.0;

	var buttonLocations = [
		// Retry Button
		FlxPoint.get(54, 55),
		// Next Button
		FlxPoint.get(49, 72)
	];

	override public function create():Void {
		#if last
		Trackers.levelScores = ["B", "A", "S", "F"];
		#end

		super.create();
		FmodManager.PlaySong(FmodSongs.Wind);

		FlxG.camera.pixelPerfectRender = true;

		// TODO: Load real backdrop
		var resultBackdrop = new FlxSprite(AssetPaths.final__png);
		add(resultBackdrop);

		// var finalScoreTxt = new AerostatRed(0, 8, "FINAL SCORE");
		// finalScoreTxt.x = (FlxG.width - finalScoreTxt.width) / 2;
		// add(finalScoreTxt);

		// var thanksTxt = new AerostatRed(0, FlxG.height - 16, "THANK YOU!");
		// thanksTxt.x = (FlxG.width - thanksTxt.width) / 2;
		// add(thanksTxt);

		var menuOverlay = new FlxSprite(AssetPaths.next__png);

		selector = new FlxSprite();
		selector.loadGraphic(AssetPaths.indicators__png, true, 8, 8);
		selector.animation.add("pointing", [0, 1], 3, true, true);
		selector.animation.play("pointing");

		var next = () -> {
			// Add these last so they are on top of everything
			// add(thanksTxt);

			// add(menuOverlay);
			// add(selector);
			disableCursor = false;
		}

		var tween = buildDrops();
		if (tween != null) {
			// if we have a tween (i.e. at least one package was delivered), wait for the tween to finish
			tween.onComplete = (t) -> {
				next();
			}
		} else {
			// otherwise just move on
			next();
		}
	}

	function buildDrops():FlxTween {
		// 4 centered characters (a little wiggle because we are using 10x10 characters)
		var letterSize = 10;
		var spacing = 5;
		var tweak = 2;
		var x = FlxG.width / 2 - 2 * (spacing + letterSize) + tweak;
		var y = FlxG.height / 2 - 10;
		var tween:FlxTween = null;
		var lastTween:FlxTween = null;
		for (index => value in Trackers.levelScores) {
			var txt = new AerostatBig(x, -10, value);
			txt.alpha = 0;
			add(txt);
			var alphaTween = FlxTween.tween(txt, {alpha: 1}, 0.01);
			// appear, then slam down
			lastTween = FlxTween.linearMotion(txt, txt.x, -10, txt.x, y, 0.4, {
				ease: FlxEase.quadIn,
				onComplete: (t) -> {
					FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);
				}
			});

			if (tween == null) {
				tween = lastTween;
			} else {
				tween.then(alphaTween).then(lastTween);
			}
			x += letterSize + spacing;
		}

		if (lastTween != null) {
			// XXX: this is basically just to get sounds to work properly
			var noopTween = FlxTween.linearMotion(new FlxObject(), 0, 0, 0, 0, 0.1);
			tween.then(noopTween);
			return noopTween;
		} else {
			return null;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		if (!disableCursor) {
			if (SimpleController.just_pressed(Button.A) || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER) {
				clickDone();
			}

			creditTimer -= elapsed;
			if (creditTimer <= 0) {
				clickDone();
			}
		}
	}

	function clickDone():Void {
		FmodFlxUtilities.TransitionToStateAndStopMusic(new CreditsState());
		FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
		disableCursor = true;
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
