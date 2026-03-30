package mikolka.vslice.ui.title;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxGradient;
import backend.Paths;
import backend.MusicBeatState;

class ChooseFirstSongState extends MusicBeatState {
	var songs:Array<String> = [];
	var songDisplayNames:Map<String, String> = new Map();
	var grpSongs:FlxTypedGroup<FlxText>;
	var visBars:Array<FlxSprite> = [];
	var curSelected:Int = 0;
	var isSelecting:Bool = true; // ✨ Verhindert doppeltes Drücken während des Fades

	override function create() {
		super.create();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF050508);
		add(bg);

		for (i in 0...45) { 
			var bar = new FlxSprite(0, 0).makeGraphic(15, 400, FlxColor.WHITE);
			bar.alpha = 0.2;
			add(bar);
			visBars.push(bar);
		}

		var title = new FlxText(0, 100, FlxG.width, "CHOOSE MAIN MENU SONG", 40);
		title.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.CYAN, CENTER, OUTLINE, FlxColor.BLACK);
		add(title);
		
		var hint = new FlxText(0, 160, FlxG.width, "(You can change this later in the Settings)", 20);
		hint.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		hint.alpha = 0.6;
		add(hint);

		var libraryPath:String = "assets/shared/music/menuSongs/";
		if (sys.FileSystem.exists(libraryPath)) {
			for (file in sys.FileSystem.readDirectory(libraryPath)) {
				if (std.StringTools.endsWith(file, ".ogg")) {
					var fileName = file.split(".")[0];
					songs.push(fileName);
					songDisplayNames.set(fileName, formatFileName(fileName));
				}
			}
		}
		if (songs.length == 0) songs = ["freakyMenu"];

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);
		
		for (i in 0...songs.length) {
			var text = new FlxText(0, 0, 0, songDisplayNames.get(songs[i]).toUpperCase(), 32);
			text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			text.ID = i;
			grpSongs.add(text);
		}
		
		changeSelection(0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!isSelecting) return; // Wenn der Fade läuft, stoppen wir die Updates hier

		var c1 = 0xFF00FFFF; var c2 = 0xFFFF00FF; var c3 = 0xFFFFFFFF;
		var gradBmp = FlxGradient.createGradientBitmapData(20, 400, [c3, c2, c1], 1, 90);
		var spacing = (FlxG.width - 200) / visBars.length;
		for (i in 0...visBars.length) {
			var wave = Math.sin((Date.now().getTime()/1000) * 2.5 + i * 0.4) * 0.4;
			visBars[i].pixels = gradBmp;
			visBars[i].scale.y = FlxMath.lerp(visBars[i].scale.y, 0.25 + wave, 0.1);
			visBars[i].x = 100 + (i * spacing);
			visBars[i].y = FlxG.height/2-200;
		}

		var lerpVal = FlxMath.bound(elapsed * 10, 0, 1);
		for (item in grpSongs.members) {
			if (item == null) continue;
			var diff = item.ID - curSelected;
			var targetX = (FlxG.width / 2) - (item.width / 2) + (diff * 380);
			item.x = FlxMath.lerp(item.x, targetX, lerpVal);
			item.y = FlxMath.lerp(item.y, (FlxG.height / 2) - (item.height / 2) + 50, lerpVal);
			item.alpha = FlxMath.lerp(item.alpha, (diff == 0 ? 1 : 0.35), lerpVal);
			
			var targetScale:Float = (diff == 0 ? 1.0 : 0.6);
			var smoothScale:Float = FlxMath.lerp(item.scale.x, targetScale, lerpVal);
			item.scale.set(smoothScale, smoothScale);
		}

		if (controls.UI_LEFT_P) changeSelection(-1);
		if (controls.UI_RIGHT_P) changeSelection(1);

		if (controls.ACCEPT) {
			isSelecting = false; // Blockiert weiteren Input
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			FlxG.save.data.lastSongName = songs[curSelected];
			FlxG.save.data.hasChosenStartSong = true;
			FlxG.save.flush();
			
			// ✨ Sanfter Fadeout zu Schwarz (1 Sekunde) und dann zum TitleScreen
			FlxG.camera.fade(FlxColor.BLACK, 1.0, false, function() {
				MusicBeatState.switchState(new TitleState());
			});
		}
	}

	function changeSelection(change:Int) {
		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		FlxG.sound.playMusic(Paths.music('menuSongs/' + songs[curSelected]), 1);
	}

	function formatFileName(name:String):String {
		var words = name.split("-");
		for (i in 0...words.length) if (words[i].length > 0) words[i] = words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
		return words.join(" ");
	}
}