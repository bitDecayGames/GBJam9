package states;

import flixel.text.FlxBitmapText;
import metrics.DropScore;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import ui.font.BitmapText.Aerostat;
import metrics.Trackers;
import ui.font.BitmapText.AerostatRed;
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

class SummaryState extends FlxState {
	var totalScore:Int;
	var totalScoreDisplay:FlxBitmapText;

	override public function create():Void {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		var resultBackdrop = new FlxSprite(AssetPaths.results__png);
		add(resultBackdrop);

		var spacing = 0.5;
		var xPos = 160 - 6 * 8;

		var time = new AerostatRed(xPos, 23, StringTools.lpad(FlxStringUtil.formatTime(Trackers.attemptTimer, false), " ", 6));
		// TODO: Figure out how to calculate this
		var timeBonus = 1000;

		var score = new AerostatRed(xPos, 41, StringTools.lpad(Std.string(Trackers.points), " ", 6));

		var landingBonus = new AerostatRed(xPos, 81, StringTools.lpad(Std.string(Trackers.landingBonus), " ", 6));

		totalScoreDisplay = new AerostatRed(xPos, 111, StringTools.lpad("0", " ", 6));
		// We want this to show always
		add(totalScoreDisplay);

		// TODO: Calculate final rating
		var rating = new AerostatRed(xPos, 129, StringTools.lpad("S", " ", 6));

		new FlxTimer().start(spacing, (t) -> {
			add(time);
			updateTotalScore(timeBonus);
			FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);

			new FlxTimer().start(spacing, (t) -> {
				add(score);
				updateTotalScore(Trackers.points);
				FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);

				new FlxTimer().start(spacing, (t) -> {
					var next = () -> {
						new FlxTimer().start(spacing, (t) -> {
							add(landingBonus);
							updateTotalScore(Trackers.landingBonus);
							FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);

							new FlxTimer().start(spacing * 3, (t) -> {
								add(rating);
								FmodManager.PlaySoundOneShot(FmodSFX.Splash);
							});
						});
					}

					var tween = buildDrops(113, 59);
					if (tween != null) {
						// if we have a tween (i.e. at least one package was delivered), wait for the tween to finish
						tween.onComplete = (t) -> {
							next();
						}
					} else {
						// otherwise just move on
						next();
					}
				});
			});
		});
	}

	function updateTotalScore(mod:Int) {
		totalScore += mod;
		totalScoreDisplay.text =  StringTools.lpad(Std.string(totalScore), " ", 6);
	}

	function buildDrops(x:Int, y:Int):FlxTween {
		// start first character at right edge of screen
		x = 160 - 8;
		var tween:FlxTween = null;
		var lastTween:FlxTween = null;
		trace('building tweens for ${Trackers.drops.length} drops');
		for (index => value in Trackers.drops) {
			var txt = new AerostatRed(x, y-8, value.grade);
			txt.alpha = 0;
			add(txt);
			var alphaTween = FlxTween.tween(txt, { alpha: 1}, 0.01);
			// appear, then slam down
			lastTween =FlxTween.linearMotion(txt, txt.x, txt.y, txt.x, y, 0.2, {
				onComplete: (t) -> {
					updateTotalScore(value.points);
					FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);
				}
			});

			if (tween == null) {
				tween = lastTween;
			} else {
				tween.then(alphaTween).then(lastTween);
			}
			x -= 8;
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

		if (SimpleController.just_pressed(Button.A)) {
			// TODO: How to get off of this screen?
			// clickMainMenu();
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
