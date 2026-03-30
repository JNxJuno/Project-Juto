package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSpriteUtil;
import backend.Paths;

class MusicUISettingsSubState extends MusicBeatSubstate
{
	var options:Array<String> = ["UI Style", "Playback Speed", "Volume", "Vis Mode", "Edit Colors"];
	var curSelected:Int = 0;
	
	var grpOptions:FlxTypedGroup<FlxText>;
	var valueTexts:FlxTypedGroup<FlxText>;
	
	var bgOverlay:FlxSprite;
	var popupPanel:FlxSprite;
	var popupTitle:FlxText;
	
	var styles:Array<String> = ["Horizontal", "Vertical"];
	var visModes:Array<String> = ["Bar", "Middle", "Circle"];
	var isClosing:Bool = false;

	public function new() {
		super();
		
		bgOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgOverlay.alpha = 0;
		add(bgOverlay);

		popupPanel = new FlxSprite().makeGraphic(600, 450, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRoundRect(popupPanel, 0, 0, 600, 450, 30, 30, 0xE60A0A0A);
		popupPanel.screenCenter();
		popupPanel.alpha = 0;
		popupPanel.scale.set(0.8, 0.8);
		add(popupPanel);

		popupTitle = new FlxText(0, popupPanel.y + 30, FlxG.width, "SETTINGS", 32);
		popupTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		popupTitle.alpha = 0;
		popupTitle.scale.set(0.8, 0.8);
		add(popupTitle);

		grpOptions = new FlxTypedGroup<FlxText>();
		valueTexts = new FlxTypedGroup<FlxText>();
		add(grpOptions);
		add(valueTexts);

		for (i in 0...options.length) {
			var finalY = popupPanel.y + 110 + (i * 55);

			var opt = new FlxText(popupPanel.x + 40, finalY + 50, 0, options[i].toUpperCase(), 24);
			opt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
			opt.ID = i;
			opt.alpha = 0;
			opt.scale.set(0.8, 0.8);
			grpOptions.add(opt);

			var val = new FlxText(popupPanel.x + 300, finalY + 50, 250, "", 24);
			val.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.CYAN, RIGHT);
			val.ID = i;
			val.alpha = 0;
			val.scale.set(0.8, 0.8);
			valueTexts.add(val);
		}

		var duration = 0.35;
		FlxTween.tween(bgOverlay, {alpha: 0.6}, duration, {ease: FlxEase.quartOut});
		FlxTween.tween(popupPanel, {alpha: 1}, duration, {ease: FlxEase.quartOut});
		FlxTween.tween(popupPanel.scale, {x: 1, y: 1}, duration, {ease: FlxEase.backOut});
		
		FlxTween.tween(popupTitle, {alpha: 1}, duration, {ease: FlxEase.quartOut});
		FlxTween.tween(popupTitle.scale, {x: 1, y: 1}, duration, {ease: FlxEase.backOut});

		for (i in 0...grpOptions.members.length) {
			FlxTween.tween(grpOptions.members[i], {alpha: (i == curSelected ? 1 : 0.4)}, duration, {ease: FlxEase.quartOut});
			FlxTween.tween(grpOptions.members[i].scale, {x: 1, y: 1}, duration, {ease: FlxEase.backOut});
			
			FlxTween.tween(valueTexts.members[i], {alpha: 1}, duration, {ease: FlxEase.quartOut});
			FlxTween.tween(valueTexts.members[i].scale, {x: 1, y: 1}, duration, {ease: FlxEase.backOut});
		}

		updateValues();
		changeSelection(0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (isClosing) return;

		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);
		if (controls.UI_LEFT_P) changeValue(-1);
		if (controls.UI_RIGHT_P) changeValue(1);

		if (controls.BACK) closeWithAnim();
		if (controls.ACCEPT) {
			if (options[curSelected] == "Edit Colors") {
				openSubState(new MusicColorMenuSubState());
			} else {
				closeWithAnim();
			}
		}
	}

	function closeWithAnim() {
		isClosing = true;
		var duration = 0.3;
		
		FlxTween.tween(bgOverlay, {alpha: 0}, duration);
		FlxTween.tween(popupPanel, {alpha: 0}, duration);
		FlxTween.tween(popupPanel.scale, {x: 0.8, y: 0.8}, duration, {ease: FlxEase.quartIn});
		
		FlxTween.tween(popupTitle, {alpha: 0}, duration);
		FlxTween.tween(popupTitle.scale, {x: 0.8, y: 0.8}, duration, {ease: FlxEase.quartIn});
		
		for (i in 0...grpOptions.members.length) {
			FlxTween.tween(grpOptions.members[i], {alpha: 0}, duration);
			FlxTween.tween(grpOptions.members[i].scale, {x: 0.8, y: 0.8}, duration, {ease: FlxEase.quartIn});
			
			FlxTween.tween(valueTexts.members[i], {alpha: 0}, duration);
			FlxTween.tween(valueTexts.members[i].scale, {x: 0.8, y: 0.8}, duration, {ease: FlxEase.quartIn, onComplete: function(_) {
				if (i == grpOptions.members.length - 1) close();
			}});
		}
	}

	function changeSelection(change:Int) {
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		grpOptions.forEach(function(txt:FlxText) {
			txt.alpha = (txt.ID == curSelected) ? 1.0 : 0.4;
			txt.x = popupPanel.x + (txt.ID == curSelected ? 60 : 40); 
		});
	}

	function changeValue(change:Int) {
		if (options[curSelected] == "Edit Colors") return;
		switch (options[curSelected]) {
			case "UI Style":
				var cur = styles.indexOf(FlxG.save.data.playerUIStyle != null ? FlxG.save.data.playerUIStyle : "Horizontal");
				FlxG.save.data.playerUIStyle = styles[FlxMath.wrap(cur + change, 0, styles.length - 1)];
			case "Playback Speed":
				FlxG.save.data.playerSpeed = FlxMath.bound((FlxG.save.data.playerSpeed != null ? FlxG.save.data.playerSpeed : 1.0) + (change * 0.1), 0.5, 2.0);
				if (FlxG.sound.music != null) FlxG.sound.music.pitch = FlxG.save.data.playerSpeed;
			case "Volume":
				FlxG.sound.volume = FlxMath.bound(FlxG.sound.volume + (change * 0.1), 0, 1);
			case "Vis Mode":
				FlxG.save.data.visMode = FlxMath.wrap((FlxG.save.data.visMode != null ? FlxG.save.data.visMode : 0) + change, 0, visModes.length - 1);
		}
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
		updateValues();
	}

	function updateValues() {
		valueTexts.forEach(function(txt:FlxText) {
			switch (options[txt.ID]) {
				case "UI Style": txt.text = "< " + (FlxG.save.data.playerUIStyle != null ? FlxG.save.data.playerUIStyle : "Horizontal") + " >";
				case "Playback Speed": txt.text = "< " + FlxMath.roundDecimal(FlxG.save.data.playerSpeed, 1) + "x >";
				case "Volume": txt.text = "< " + Math.round(FlxG.sound.volume * 100) + "% >";
				case "Vis Mode": txt.text = "< " + visModes[FlxG.save.data.visMode != null ? FlxG.save.data.visMode : 0] + " >";
				case "Edit Colors": txt.text = "PRESS ENTER"; txt.color = FlxColor.YELLOW;
			}
		});
	}
}