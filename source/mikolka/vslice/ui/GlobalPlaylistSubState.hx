package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import backend.Paths;
import sys.FileSystem;

class GlobalPlaylistSubState extends MusicBeatSubstate
{
    var songs:Array<String> = [];
    var songDisplayNames:Map<String, String> = new Map();
    var curSelected:Int = 0;
    
    var songText:FlxText;
    var leftArrow:FlxText;
    var rightArrow:FlxText;
    var playCam:FlxCamera;

    public function new()
    {
        super();
        playCam = new FlxCamera();
        playCam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(playCam, false);
        this.cameras = [playCam];

        var libraryPath:String = "assets/shared/music/menuSongs/";
        if (FileSystem.exists(libraryPath)) {
            for (file in FileSystem.readDirectory(libraryPath)) {
                if (std.StringTools.endsWith(file, ".ogg")) { 
                    var fileName = file.split(".")[0];
                    songs.push(fileName);
                    songDisplayNames.set(fileName, formatFileName(fileName));
                }
            }
        }
        if (songs.length == 0) songs = ["freakyMenu"];
        if (FlxG.save.data.lastSongIndex != null) curSelected = FlxG.save.data.lastSongIndex;

        var bgBox = new FlxSprite().makeGraphic(FlxG.width, 160, FlxColor.BLACK);
        bgBox.alpha = 0.85;
        bgBox.screenCenter(Y);
        add(bgBox);

        leftArrow = new FlxText(0, 0, 0, "<", 48);
        leftArrow.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(leftArrow);

        songText = new FlxText(0, 0, 800, "", 48);
        songText.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(songText);

        rightArrow = new FlxText(0, 0, 0, ">", 48);
        rightArrow.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(rightArrow);

        var helpTxt = new FlxText(0, bgBox.y + 120, FlxG.width, "[ARROWS] Select | [ENTER] Play | [ESC/P] Close", 16);
        helpTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.GRAY, CENTER);
        add(helpTxt);

        changeSelection(0);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var lerpVal = FlxMath.bound(elapsed * 12, 0, 1);
        
        songText.scale.set(FlxMath.lerp(songText.scale.x, 1, lerpVal), FlxMath.lerp(songText.scale.y, 1, lerpVal));
        songText.y = FlxMath.lerp(songText.y, (FlxG.height / 2) - (songText.height / 2) - 10, lerpVal);
        
        var textWidth = songText.textField.textWidth;
        leftArrow.x = FlxMath.lerp(leftArrow.x, songText.x + (songText.width / 2) - (textWidth / 2) - 50, lerpVal);
        rightArrow.x = FlxMath.lerp(rightArrow.x, songText.x + (songText.width / 2) + (textWidth / 2) + 20, lerpVal);
        
        leftArrow.y = songText.y;
        rightArrow.y = songText.y;

        if (controls.UI_LEFT_P) {
            changeSelection(-1);
            leftArrow.x -= 25; 
            songText.scale.set(1.1, 1.1); 
            songText.y -= 5;
        }
        if (controls.UI_RIGHT_P) {
            changeSelection(1);
            rightArrow.x += 25; 
            songText.scale.set(1.1, 1.1); 
            songText.y -= 5;
        }
        
        if (controls.ACCEPT) {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            var songFile = songs[curSelected];
            FlxG.save.data.lastSongIndex = curSelected;
            
            FlxG.save.data.lastSongTime = 0;
            FlxG.save.flush();
            
            mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile = songFile;
            FlxG.sound.playMusic(Paths.music('menuSongs/' + songFile), 1);
            close();
        }

        if (controls.BACK) close();
    }

    override function destroy() {
        if (playCam != null) FlxG.cameras.remove(playCam);
        super.destroy();
    }

    function changeSelection(change:Int) {
        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
        if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        
        songText.text = songDisplayNames.get(songs[curSelected]).toUpperCase();
        songText.screenCenter(X);
    }

    function formatFileName(name:String):String {
        var words = name.split("-");
        for (i in 0...words.length) if (words[i].length > 0) words[i] = words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
        return words.join(" ");
    }
}