package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import backend.Highscore;
import backend.Song;
import backend.Paths;

// Dieser kleine Befehl erlaubt uns den Zugriff auf die privaten Variablen!
@:access(states.FreeplayState)
class FreeplayOverlay extends MusicBeatSubstate {
	var parent:FreeplayState;
	
	var customState:Int = 0; // 0 = Song, 1 = Diff
	var customSongBox:FlxSprite;
	var customSongText:FlxText;
	var customDiffBox:FlxSprite;
	var customDiffText:FlxText;
	var overlayCam:FlxCamera;

	public function new() {
		super();
		
		parent = cast(FlxG.state, FreeplayState);

		// Verstecke das normale UI
		if (parent.grpSongs != null) parent.grpSongs.visible = false;
		if (parent.scoreText != null) parent.scoreText.visible = false;
		if (parent.scoreBG != null) parent.scoreBG.visible = false;
		if (parent.diffText != null) parent.diffText.visible = false;

		overlayCam = new FlxCamera();
		overlayCam.bgColor.alpha = 0;
		FlxG.cameras.add(overlayCam, false);

		// --- PHASE 1: Schräger Song-Kasten ---
		customSongBox = new FlxSprite(-50, FlxG.height - 200).makeGraphic(700, 120, FlxColor.BLACK);
		customSongBox.angle = -15; 
		customSongBox.cameras = [overlayCam];
		add(customSongBox);

		customSongText = new FlxText(50, FlxG.height - 180, 600, "", 48);
		customSongText.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER);
		customSongText.angle = -15;
		customSongText.cameras = [overlayCam];
		add(customSongText);

		// --- PHASE 2: Schwierigkeits-Kasten ---
		customDiffBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, 150, FlxColor.BLACK);
		customDiffBox.screenCenter();
		customDiffBox.alpha = 0;
		customDiffBox.scale.y = 0; 
		customDiffBox.cameras = [overlayCam];
		add(customDiffBox);

		customDiffText = new FlxText(0, 0, FlxG.width, "", 48);
		customDiffText.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER);
		customDiffText.screenCenter();
		customDiffText.alpha = 0;
		customDiffText.cameras = [overlayCam];
		add(customDiffText);

		updateUI();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (customState == 0) {
			if (controls.UI_LEFT_P || controls.UI_UP_P) {
				parent.changeSelection(-1);
				updateUI();
			}
			if (controls.UI_RIGHT_P || controls.UI_DOWN_P) {
				parent.changeSelection(1);
				updateUI();
			}
			
			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close(); 
				MusicBeatState.switchState(new MainMenuState());
			}
			
			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				customState = 1;
				
				FlxTween.tween(FlxG.camera, {zoom: 1.15}, 0.5, {ease: FlxEase.expoOut});
				FlxTween.tween(customDiffBox, {alpha: 0.8}, 0.3);
				FlxTween.tween(customDiffBox.scale, {y: 1}, 0.4, {ease: FlxEase.backOut});
				FlxTween.tween(customDiffText, {alpha: 1}, 0.4);
				
				FlxTween.tween(customSongBox, {x: -800}, 0.4, {ease: FlxEase.expoIn});
				FlxTween.tween(customSongText, {x: -800}, 0.4, {ease: FlxEase.expoIn});
				
				updateUI();
			}
		} 
		else if (customState == 1) {
			if (controls.UI_LEFT_P) {
				parent.changeDiff(-1);
				updateUI();
			}
			if (controls.UI_RIGHT_P) {
				parent.changeDiff(1);
				updateUI();
			}

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				customState = 0;
				
				FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.5, {ease: FlxEase.expoOut});
				FlxTween.tween(customDiffBox, {alpha: 0, "scale.y": 0}, 0.3, {ease: FlxEase.expoIn});
				FlxTween.tween(customDiffText, {alpha: 0}, 0.3);
				
				FlxTween.tween(customSongBox, {x: -50}, 0.4, {ease: FlxEase.backOut});
				FlxTween.tween(customSongText, {x: 50}, 0.4, {ease: FlxEase.backOut});
			}

			if (controls.ACCEPT) {
				var songLowercase:String = Paths.formatToSongPath(parent.songs[parent.curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, parent.curDifficulty);
				
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = parent.curDifficulty;
				
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
		}
	}

	function updateUI() {
		var songName = parent.songs[parent.curSelected].songName;
		customSongText.text = "◁ " + songName.toUpperCase() + " ▷";
		
		customSongText.scale.set(1, 1);
		customSongText.updateHitbox();
		if (customSongText.width > 550) {
			var ratio = 550 / customSongText.width;
			customSongText.scale.set(ratio, ratio);
			customSongText.updateHitbox();
		}

		var diffs = backend.Difficulty.list;
		var diffString = "";
		
		for (i in 0...diffs.length) {
			if (i == parent.curDifficulty) {
				diffString += "◁ " + diffs[i].toUpperCase() + " ▷   ";
			} else {
				diffString += diffs[i] + "   ";
			}
		}
		customDiffText.text = diffString;
	}
}