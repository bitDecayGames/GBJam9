package ui.font;

import flixel.math.FlxRect;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxBitmapFont;

@:forward
abstract PressStart(BitmapText) to BitmapText {
	static public var font(get, null):FlxBitmapFont = null;

	inline public function new(x = 0.0, y = 0.0, text = "") {
		this = new BitmapText(x, y, text, font);
	}

	inline static function get_font() {
		if (font == null) {
			@:privateAccess
			font = BitmapText.createPressStartFont();
		}
		return font;
	}
}

class BitmapText extends flixel.text.FlxBitmapText {
	static var mainFont:FlxBitmapFont = null;

	@:allow(PressStart)
	static function createPressStartFont():FlxBitmapFont {
		var path = AssetPaths.PressStart2P_regular_8__png;
		var chars = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

		var graphic = FlxG.bitmap.add(path);
		var frame = graphic.imageFrame.frame;

		var font = new FlxBitmapFont(frame);

		final widths = [];
		var bmd = openfl.Assets.getBitmapData(path);
		var curWidth = 0;
		var bottom = bmd.height - 1;
		for (x in 0...bmd.width) {
			trace(StringTools.hex(bmd.getPixel(x, bottom), 8));
			if (bmd.getPixel(x, bottom) == 0xfbf236) {
				trace("match");
				if (curWidth > 0) {
					widths.push(curWidth + 1);
				}
				curWidth = 0;
			} else {
				curWidth++;
			}
		}
		if (curWidth > 0) {
			widths.push(curWidth + 1);
		}

		trace(widths.length);
		trace(chars.length);
		trace(font.frames.length);
		trace(widths);

		var spaceWidth = 5;
		var height = 9;
		var x = 0;

		for (i in 0...chars.length) {
			var code = chars.charCodeAt(i);
			trace('index: ${i}');
			trace('code: ${code}');
			trace('char: ${chars.charAt(i)}');
			trace('width: ${widths[i]}');
			font.addCharFrame(code, FlxRect.get(x, 0, widths[i], height), FlxPoint.get(), widths[i]);
			x += widths[i];
		}

		font.lineHeight = height;
		font.spaceWidth = spaceWidth;
		return font;
	}

	public function new(x = 0.0, y = 0.0, text = "", ?font:FlxBitmapFont):Void {
		if (font == null) {
			if (mainFont == null)
				mainFont = createPressStartFont();

			font = mainFont;
		}

		super(font);

		this.x = x;
		this.y = y;
		this.text = text;
		moves = false;
		active = false;
	}
}
