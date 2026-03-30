package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxGradient;
import flixel.util.FlxSpriteUtil;
import backend.Paths;
import sys.FileSystem;

enum PlayerState { SELECTING; PLAYING; }

class MusicSettingsSubState extends MusicBeatSubstate
{
    public static var currentPlayingFile:String = "";
    var songs:Array<String> = [];
    var songDisplayNames:Map<String, String> = new Map();
    var curSelected:Int = 0;
    var playingIndex:Int = -1;
    var currentState:PlayerState = PLAYING;
    
    var bgOverlay:FlxSprite; 
    
    var playlistBox:FlxSprite;
    var visBars:Array<FlxSprite> = [];
    var grpSongs:FlxTypedGroup<FlxText>;
    
    var songTitle:FlxText;
    var progressBar:FlxSprite;
    var timeText:FlxText;
    var volText:FlxText;
    var speedText:FlxText;

    var helpGroup:FlxTypedGroup<FlxSprite>;
    var helpBg:FlxSprite;
    var helpPopup:FlxSprite;
    var showHelp:Bool = false;
    
    var lastStyle:String = ""; 

    public function new() 
    {
        super();
        
        FlxG.mouse.visible = false;
        
        bgOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgOverlay.alpha = 0.85; 
        bgOverlay.scrollFactor.set();
        add(bgOverlay);

        if (FlxG.save.data.songColors == null) FlxG.save.data.songColors = new Map<String, Array<Int>>();
        if (FlxG.save.data.hasSeenMusicHelp == null) FlxG.save.data.hasSeenMusicHelp = false;

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
        
        loadState();
        
        var activeIdx = songs.indexOf(currentPlayingFile);
        if (activeIdx != -1) {
            curSelected = activeIdx;
            playingIndex = activeIdx;
        } else if (currentPlayingFile == "" || currentPlayingFile == null) {
            currentPlayingFile = songs[curSelected];
        }

        for (i in 0...45) { 
            var bar = new FlxSprite(0, 0).makeGraphic(15, 400, FlxColor.WHITE);
            bar.alpha = 0.2;
            add(bar);
            visBars.push(bar);
        }

        playlistBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        playlistBox.alpha = 0;
        add(playlistBox);

        grpSongs = new FlxTypedGroup<FlxText>();
        add(grpSongs);
        for (i in 0...songs.length) {
            var text = new FlxText(0, 0, 0, songDisplayNames.get(songs[i]).toUpperCase(), 32);
            text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
            text.ID = i;
            grpSongs.add(text);
        }

        songTitle = new FlxText(0, FlxG.height / 2 - 50, FlxG.width, "", 50);
        songTitle.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER);
        add(songTitle);

        progressBar = new FlxSprite(0, FlxG.height - 70).makeGraphic(600, 4, FlxColor.WHITE);
        progressBar.screenCenter(X);
        progressBar.origin.x = 0;
        add(progressBar);

        timeText = new FlxText(0, FlxG.height - 55, FlxG.width, "0:00 / 0:00", 14);
        timeText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, CENTER);
        add(timeText);

        volText = new FlxText(20, 20, 0, "VOL: 100%", 16);
        volText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
        add(volText);

        speedText = new FlxText(FlxG.width - 150, 20, 0, "SPEED: 1.0x", 16);
        speedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
        add(speedText);

        createHelpMenu();

        playSong(false);
        
        if (!FlxG.save.data.hasSeenMusicHelp) {
            FlxG.save.data.hasSeenMusicHelp = true;
            FlxG.save.flush();
            toggleHelp(true);
        }
    }

    function createHelpMenu() {
        helpGroup = new FlxTypedGroup<FlxSprite>();
        helpGroup.visible = false;

        helpBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        helpBg.alpha = 0;
        helpGroup.add(helpBg);

        helpPopup = new FlxSprite().makeGraphic(600, 450, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawRoundRect(helpPopup, 0, 0, 600, 450, 30, 30, 0xE60A0A0A);
        helpPopup.screenCenter();
        helpGroup.add(helpPopup);

        var helpTitle = new FlxText(0, helpPopup.y + 30, FlxG.width, "SYSTEM GUIDE", 34);
        helpTitle.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.CYAN, CENTER, OUTLINE, FlxColor.BLACK);
        helpGroup.add(helpTitle);

        var helpLine = new FlxSprite(0, helpPopup.y + 80).makeGraphic(400, 3, FlxColor.CYAN);
        helpLine.screenCenter(X);
        helpGroup.add(helpLine);

        var helpCommands = new FlxText(0, helpPopup.y + 110, FlxG.width, 
            "[P] PLAYLIST MODE\n\n" +
            "[S] OPEN SETTINGS\n\n" +
            "[Q] TOGGLE GUIDE\n\n" +
            "[UP/DOWN] VOLUME\n\n" +
            "[SPACE] PAUSE/PLAY\n\n" +
            "[ESC] BACK", 22);
        helpCommands.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER);
        helpGroup.add(helpCommands);

        add(helpGroup);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed); 
        
        var lerpVal = FlxMath.bound(elapsed * 10, 0, 1);
        
        var songCols:Array<Int> = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];
        if (FlxG.save.data.songColors != null && currentPlayingFile != null) {
            var saved = FlxG.save.data.songColors.get(currentPlayingFile);
            if (saved != null && saved.length >= 3) songCols = saved;
        }

        updateVisualizer(songCols, FlxG.save.data.visMode != null ? FlxG.save.data.visMode : 0);

        if (subState != null) {
            return;
        }

        if (FlxG.keys.justPressed.Q) toggleHelp(!showHelp);

        if (showHelp) {
            if (FlxG.keys.justPressed.ESCAPE || controls.BACK) toggleHelp(false);
            return;
        }

        var style:String = FlxG.save.data.playerUIStyle != null ? FlxG.save.data.playerUIStyle : "Horizontal";
        if (style != lastStyle) { lastStyle = style; updateBoxGraphic(style); }

        if (FlxG.keys.justPressed.S) openSubState(new mikolka.vslice.ui.MusicUISettingsSubState());

        switch (currentState) {
            case SELECTING:
                playlistBox.alpha = FlxMath.lerp(playlistBox.alpha, 0.75, lerpVal);
                songTitle.alpha = FlxMath.lerp(songTitle.alpha, 0, lerpVal);
                
                for (item in grpSongs.members) {
                    item.visible = true;
                    var diff = item.ID - curSelected;
                    
                    if (style == "Vertical") {
                        item.screenCenter(X);
                        item.y = FlxMath.lerp(item.y, (FlxG.height / 2) - (item.height / 2) + (diff * 80), lerpVal);
                    } else {
                        var targetX = (FlxG.width / 2) - (item.width / 2) + (diff * 380);
                        item.x = FlxMath.lerp(item.x, targetX, lerpVal);
                        item.y = FlxMath.lerp(item.y, (FlxG.height / 2) - (item.height / 2), lerpVal);
                    }
                    
                    item.alpha = FlxMath.lerp(item.alpha, (diff == 0 ? 1 : 0.35), lerpVal);
                    var targetScale:Float = (diff == 0 ? 1.0 : 0.6);
                    var smoothScale:Float = FlxMath.lerp(item.scale.x, targetScale, lerpVal);
                    item.scale.set(smoothScale, smoothScale); 
                }
                
                if (controls.UI_LEFT_P || (style == "Vertical" && controls.UI_UP_P)) changeSelection(-1);
                if (controls.UI_RIGHT_P || (style == "Vertical" && controls.UI_DOWN_P)) changeSelection(1);
                
                if (controls.ACCEPT) {
                    currentState = PLAYING;
                    playSong(true);
                }
            case PLAYING:
                playlistBox.alpha = FlxMath.lerp(playlistBox.alpha, 0, lerpVal);
                songTitle.alpha = FlxMath.lerp(songTitle.alpha, 1, lerpVal);
                for (item in grpSongs.members) item.alpha = FlxMath.lerp(item.alpha, 0, lerpVal);
        }

        if (FlxG.keys.justPressed.P) currentState = (currentState == PLAYING ? SELECTING : PLAYING);

        volText.color = speedText.color = songTitle.color = progressBar.color = songCols[0];
        volText.text = "VOL: " + Math.round(FlxG.sound.volume * 100) + "%";
        
        if (FlxG.sound.music != null && FlxG.sound.music.playing) {
            progressBar.scale.x = FlxG.sound.music.time / FlxG.sound.music.length;
            timeText.text = formatTime(FlxG.sound.music.time) + " / " + formatTime(FlxG.sound.music.length);
        }

        if (controls.BACK && currentState == PLAYING) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            close(); 
        }
    }

    function toggleHelp(snap:Bool = false) {
        showHelp = !showHelp;
        var duration:Float = snap ? 0.001 : 0.35;

        if (showHelp) {
            helpGroup.visible = true;
            for (member in helpGroup.members) {
                if (member != helpBg && member.alpha == 0) member.scale.set(0.8, 0.8);
            }
        }

        FlxTween.cancelTweensOf(helpBg);
        FlxTween.tween(helpBg, {alpha: showHelp ? 0.6 : 0}, duration);

        for (member in helpGroup.members) {
            if (member == helpBg) continue;
            
            FlxTween.cancelTweensOf(member);
            FlxTween.cancelTweensOf(member.scale);
            
            FlxTween.tween(member, {alpha: showHelp ? 1 : 0}, duration, {
                ease: showHelp ? FlxEase.quartOut : FlxEase.quartIn,
                onComplete: function(_) { if (!showHelp && member == helpPopup) helpGroup.visible = false; }
            });
            
            FlxTween.tween(member.scale, {x: showHelp ? 1 : 0.8, y: showHelp ? 1 : 0.8}, duration, {
                ease: showHelp ? FlxEase.backOut : FlxEase.quartIn
            });
        }
    }

    function updateBoxGraphic(style:String) {
        playlistBox.pixels.dispose();
        playlistBox.makeGraphic(style == "Vertical" ? 380 : FlxG.width, style == "Vertical" ? FlxG.height : 160, FlxColor.BLACK);
        playlistBox.screenCenter();
    }

    function updateVisualizer(cols:Array<Int>, mode:Int) {
        var gradBmp = FlxGradient.createGradientBitmapData(20, 400, [cols[2], cols[1], cols[0]], 1, 90);
        var spacing = (FlxG.width - 200) / visBars.length;
        for (i in 0...visBars.length) {
            var wave = Math.sin((Date.now().getTime()/1000) * 2.5 + i * 0.4) * 0.4;
            visBars[i].pixels = gradBmp;
            visBars[i].scale.y = FlxMath.lerp(visBars[i].scale.y, 0.25 + wave, 0.1);
            if (mode == 2) {
                var angle = (i / visBars.length) * Math.PI * 2;
                visBars[i].x = (FlxG.width/2) + Math.cos(angle)*230-10;
                visBars[i].y = (FlxG.height/2) + Math.sin(angle)*230-200;
                visBars[i].angle = (angle * 180 / Math.PI) + 90;
            } else {
                visBars[i].x = 100 + (i * spacing);
                visBars[i].y = FlxG.height/2-200;
                visBars[i].origin.y = (mode == 1) ? 200 : 400;
            }
        }
    }

    function playSong(save:Bool) {
        playingIndex = curSelected;
        if (currentPlayingFile != songs[playingIndex]) {
            FlxG.sound.playMusic(Paths.music('menuSongs/' + songs[playingIndex]), 1);
            currentPlayingFile = songs[playingIndex];
        }
        songTitle.text = songDisplayNames.get(currentPlayingFile).toUpperCase();
        if (save) saveState();
    }

    function formatTime(ms:Float):String {
        var s:Int = Std.int(ms / 1000);
        return Std.int(s / 60) + ":" + (s % 60 < 10 ? "0" + (s % 60) : "" + (s % 60));
    }

    function changeSelection(change:Int) {
        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    }

    function saveState() { 
        FlxG.save.data.lastSongName = songs[playingIndex]; 
        FlxG.save.flush(); 
    }
    
    function loadState() { 
        if (FlxG.save.data.lastSongName != null) {
            var idx = songs.indexOf(FlxG.save.data.lastSongName);
            if (idx != -1) playingIndex = curSelected = idx;
        }
    }
    
    function formatFileName(name:String):String {
        var words = name.split("-");
        for (i in 0...words.length) if (words[i].length > 0) words[i] = words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
        return words.join(" ");
    }
}