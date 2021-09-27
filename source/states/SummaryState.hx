package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxefmod.flixel.FmodFlxUtilities;
import input.SimpleController;
import metrics.DropScore;
import metrics.Trackers;
import ui.font.BitmapText.AerostatBig;
import ui.font.BitmapText.AerostatRed;

using extensions.FlxStateExt;

class SummaryState extends FlxState {
	var totalScore:Int = 0;
	var totalScoreDisplay:FlxBitmapText;

	var rawRating = "";

	var selector:FlxSprite;
	var cursorIndex = 0;
	var disableCursor = true;

	var buttonLocations = [
		// Retry Button
		FlxPoint.get(54, 55),
		// Next Button
		FlxPoint.get(49, 72)
	];

	override public function create():Void {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		var resultBackdrop = new FlxSprite(AssetPaths.results__png);
		add(resultBackdrop);

		var menuOverlay = new FlxSprite(AssetPaths.next__png);

		selector = new FlxSprite();
		selector.loadGraphic(AssetPaths.indicators__png, true, 8, 8);
		selector.animation.add("pointing", [0, 1], 3, true, true);
		selector.animation.play("pointing");

		var spacing = 0.5;
		var xPos = 160 - 6 * 8;
		var xPos10Size = 160 - 6 * 10;

		var time = new AerostatRed(xPos, 23, StringTools.lpad(FlxStringUtil.formatTime(Trackers.attemptTimer, false), " ", 6));

		// TODO: Figure out how to calculate this if we want to do this
		var timeBonus = 0;

		var score = new AerostatRed(xPos, 41, StringTools.lpad(Std.string(Trackers.points), " ", 6));

		var landingBonus = new AerostatRed(xPos, 81, StringTools.lpad(Std.string(Trackers.landingBonus), " ", 6));

		totalScoreDisplay = new AerostatRed(xPos, 111, StringTools.lpad("0", " ", 6));
		// We want this to show always
		add(totalScoreDisplay);

		// Avoid potential divide by zero errors
		var maxPossible = Math.max(1, Trackers.houseMax * 3000);
		// var rating = new AerostatBig(xPos - 2, 127, StringTools.lpad("S", " ", 6));
		var rating = new AerostatBig(xPos10Size, 128, StringTools.lpad("S", " ", 6));

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
								var percent = totalScore / maxPossible;
								rawRating = percentToRating(percent);
								rating.text = StringTools.lpad(percentToRating(percent), " ", 6);
								add(rating);
								FmodManager.PlaySoundOneShot(FmodSFX.Splash);

								new FlxTimer().start(3, (t) -> {
									// Add these last so they are on top of everything
									add(menuOverlay);
									add(selector);
									disableCursor = false;
								});
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

	function percentToRating(percent:Float):String {
		if (percent >= 1) {
			return "S";
		} else if (percent >= 0.8) {
			return "A";
		} else if (percent >= 0.6) {
			return "B";
		} else if (percent >= 0.4) {
			return "C";
		} else {
			return "F";
		}
	}

	function updateTotalScore(mod:Int) {
		totalScore += mod;
		totalScoreDisplay.text = StringTools.lpad(Std.string(totalScore), " ", 6);
	}

	function buildDrops(x:Int, y:Int):FlxTween {
		// start first character at right edge of screen
		x = 160 - 8;
		var tween:FlxTween = null;
		var lastTween:FlxTween = null;
		#if debug
		trace('building tweens for ${Trackers.drops.length} drops');
		trace('total houses ${Trackers.houseMax} drops');
		#end
		for (i in 0...Trackers.houseMax) {
			var drop:DropScore;
			if (i < Trackers.drops.length) {
				drop = Trackers.drops[i];
			} else {
				drop = new DropScore(0, "-");
			}

			var txt = new AerostatRed(x, y - 8, drop.grade);
			txt.alpha = 0;
			add(txt);
			var alphaTween = FlxTween.tween(txt, {alpha: 1}, 0.01);
			// appear, then slam down
			lastTween = FlxTween.linearMotion(txt, txt.x, txt.y, txt.x, y, 0.2, {
				onComplete: (t) -> {
					updateTotalScore(drop.points);
					FmodManager.PlaySoundOneShot(FmodSFX.CrateLand);

					if (drop.grade == "-") {
						FmodManager.PlaySoundOneShot(FmodSFX.ScoreZero);
					}
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

		if (!disableCursor) {
			checkControls();
		}

		if (cursorIndex >= buttonLocations.length) {
			cursorIndex = 0;
		}

		if (cursorIndex < 0) {
			cursorIndex = buttonLocations.length - 1;
		}

		selector.x = buttonLocations[cursorIndex].x;
		selector.y = buttonLocations[cursorIndex].y;
	}

	function checkControls() {
		if (SimpleController.just_pressed(Button.DOWN)) {
			FmodManager.PlaySoundOneShot(FmodSFX.MenuHover);
			cursorIndex++;
		}

		if (SimpleController.just_pressed(Button.UP)) {
			FmodManager.PlaySoundOneShot(FmodSFX.MenuHover);
			cursorIndex--;
		}

		if (SimpleController.just_pressed(Button.A) || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER) {
			switch (cursorIndex) {
				case 0:
					clickNext();
					FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
					disableCursor = true;
				case 1:
					clickRetry();
					FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
					disableCursor = true;
				default:
					#if debug
					trace('no menu item for index ${cursorIndex}');
					#end
			}
		}
	}

	function clickRetry() {
		FmodFlxUtilities.TransitionToState(new PlayState());
	}

	function clickNext():Void {
		// save level score for current level
		Trackers.levelScores.push(rawRating);

		PlayState.currentLevel++;
		if (PlayState.currentLevel >= PlayState.levelOrder.length) {
			FmodFlxUtilities.TransitionToState(new FinalGradeState());
		} else {
			clickRetry();
		}
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
