package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import backend.Highscore;
import backend.Song;
import backend.Paths;
import backend.WeekData;
import backend.Difficulty;
#if TOUCH_CONTROLS_ALLOWED
import mobile.objects.TouchPad;
#end

class FreeplayState extends MusicBeatState {
	var songs:Array<String> = [];
	var curSelected:Int = 0;
	var curDifficulty:Int = 1; 
	
	var customState:Int = 0; 
	
	var customSongBox:FlxSprite;
	var customDiffBox:FlxSprite;
	
	var grpSongTexts:FlxTypedGroup<FlxText>;
	var grpDiffTexts:FlxTypedGroup<FlxText>;

	public static function build(?payload:Dynamic, ?sticker:Dynamic):FreeplayState {
		return new FreeplayState();
	}

	override function create() {
		super.create();
		
		WeekData.reloadWeekFiles(false);
		for (i in 0...WeekData.weeksList.length) {
			var week = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			for (song in week.songs) {
				songs.push(song[0]);
			}
		}
		if (songs.length == 0) songs.push("Test"); 

		Difficulty.list = ['Easy', 'Normal', 'Hard', 'Erect', 'Nightmare'];
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFA8D0E6; 
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		
		customSongBox = new FlxSprite(-200, FlxG.height - 120).makeGraphic(700, 250, FlxColor.BLACK);
		customSongBox.angle = 25; 
		add(customSongBox);

		grpSongTexts = new FlxTypedGroup<FlxText>();
		add(grpSongTexts);

		for (i in 0...songs.length) {
			var text = new FlxText(0, 0, 0, songs[i].toUpperCase(), 32);
			text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
			text.angle = 25; 
			text.ID = i;
			text.alpha = 0;
			grpSongTexts.add(text);
		}

		customDiffBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, 180, FlxColor.BLACK);
		customDiffBox.screenCenter();
		customDiffBox.alpha = 0;
		customDiffBox.scale.y = 0;
		add(customDiffBox);

		grpDiffTexts = new FlxTypedGroup<FlxText>();
		add(grpDiffTexts);

		for (i in 0...Difficulty.list.length) {
			var text = new FlxText(0, 0, 0, Difficulty.list[i].toUpperCase(), 48);
			text.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER);
			text.screenCenter(Y);
			text.ID = i;
			text.alpha = 0;
			grpDiffTexts.add(text);
		}

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('UP_DOWN_LEFT_RIGHT', 'A_B');
		#end

		changeSelection(0);
		changeDiff(0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var lerpVal = FlxMath.bound(elapsed * 12, 0, 1);

		for (item in grpSongTexts.members) {
			var diff = item.ID - curSelected;
			
			// ✨ Auto-Scale Berechnung für lange Namen
			var unscaledWidth = item.width / item.scale.x;
			var baseScale = 1.0;
			if (unscaledWidth > 300) {
				baseScale = 300 / unscaledWidth;
			}

			var targetAlpha:Float = 0;
			var targetScale:Float = 0.6 * baseScale;
			
			// Feste schräge Linie
			var targetX:Float = 80 + (diff * 180); 
			var targetY:Float = (FlxG.height - 100) + (diff * 83); 

			if (customState == 0) {
				if (diff == 0) {
					targetAlpha = 1;
					targetScale = 1.0 * baseScale;
				} else {
					targetAlpha = 0.4;
				}
			} else {
				targetX -= 1000; 
				targetY -= 500;
			}
			
			item.x = FlxMath.lerp(item.x, targetX, lerpVal);
			item.y = FlxMath.lerp(item.y, targetY, lerpVal);
			item.alpha = FlxMath.lerp(item.alpha, targetAlpha, lerpVal);
			item.scale.set(FlxMath.lerp(item.scale.x, targetScale, lerpVal), FlxMath.lerp(item.scale.y, targetScale, lerpVal));
		}

		for (item in grpDiffTexts.members) {
			var targetAlpha:Float = 0;
			var targetScale:Float = 0.6;
			var targetX:Float = (FlxG.width / 2) - (item.width / 2);

			if (customState == 1) {
				var diff = item.ID - curDifficulty;
				targetX += diff * 350; 
				
				if (diff == 0) {
					targetAlpha = 1;
					targetScale = 1.1; 
				} else {
					targetAlpha = 0.4;
					targetScale = 0.7; 
				}
			}
			
			item.x = FlxMath.lerp(item.x, targetX, lerpVal);
			item.alpha = FlxMath.lerp(item.alpha, targetAlpha, lerpVal);
			item.scale.set(FlxMath.lerp(item.scale.x, targetScale, lerpVal), FlxMath.lerp(item.scale.y, targetScale, lerpVal));
		}

		if (customState == 0) { 
			if (controls.UI_LEFT_P || controls.UI_UP_P) changeSelection(-1);
			if (controls.UI_RIGHT_P || controls.UI_DOWN_P) changeSelection(1);
			
			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new mikolka.vslice.ui.MainMenuState());
			}
			
			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				customState = 1;
				
				FlxTween.tween(FlxG.camera, {zoom: 1.15}, 0.5, {ease: FlxEase.expoOut});
				FlxTween.tween(customDiffBox, {alpha: 0.8}, 0.3);
				FlxTween.tween(customDiffBox.scale, {y: 1}, 0.4, {ease: FlxEase.backOut});
				
				FlxTween.tween(customSongBox, {x: -1200, y: FlxG.height + 300}, 0.4, {ease: FlxEase.expoIn});
			}
		} 
		else if (customState == 1) { 
			if (controls.UI_LEFT_P) changeDiff(-1);
			if (controls.UI_RIGHT_P) changeDiff(1);

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				customState = 0;
				
				FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.5, {ease: FlxEase.expoOut});
				FlxTween.tween(customDiffBox, {alpha: 0, "scale.y": 0}, 0.3, {ease: FlxEase.expoIn});
				
				FlxTween.tween(customSongBox, {x: -200, y: FlxG.height - 120}, 0.4, {ease: FlxEase.backOut});
			}

			if (controls.ACCEPT) {
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected]);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				
				try {
					var songObj = Song.loadFromJson(poop, songLowercase);
					if (songObj != null) {
						PlayState.SONG = songObj;
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = curDifficulty;
						
						LoadingState.loadAndSwitchState(new PlayState());
						FlxG.sound.music.volume = 0;
					} else {
						throw "Song is null";
					}
				} catch(e:Dynamic) {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.camera.shake(0.015, 0.15);
				}
			}
		}
	}

	function changeSelection(change:Int = 0) {
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
		
		for (item in grpSongTexts.members) {
			if (item.ID == curSelected) {
				item.text = "< " + songs[item.ID].toUpperCase() + " >";
			} else {
				item.text = songs[item.ID].toUpperCase();
			}
			item.updateHitbox();
		}
	}

	function changeDiff(change:Int = 0) {
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length - 1);

		for (item in grpDiffTexts.members) {
			if (item.ID == curDifficulty) {
				item.text = "< " + Difficulty.list[item.ID].toUpperCase() + " >";
			} else {
				item.text = Difficulty.list[item.ID].toUpperCase();
			}
			item.updateHitbox();
		}
	}
}