package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class GlobalNowPlaying extends FlxSpriteGroup
{
    var bgBox:FlxSprite;
    var songTxt:FlxText;
    var lastSong:String = "";
    var showTimer:Float = 0;
    var isShowing:Bool = false;
    var uiCam:FlxCamera;

    public function new()
    {
        super();

        // ✨ EIGENE KAMERA, DIE ALLES ÜBERLAPPEN DARF
        uiCam = new FlxCamera();
        uiCam.bgColor = FlxColor.TRANSPARENT; 
        FlxG.cameras.add(uiCam, false);
        this.cameras = [uiCam];

        bgBox = new FlxSprite().makeGraphic(400, 60, FlxColor.BLACK);
        bgBox.alpha = 0.8;
        add(bgBox);

        songTxt = new FlxText(0, 20, 400, "", 18);
        songTxt.setFormat(backend.Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, flixel.text.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        songTxt.borderSize = 2;
        add(songTxt);

        scrollFactor.set(0, 0);
        x = FlxG.width;
        y = FlxG.height - 80;

        // ✨ Hier wurde der Name zum SubState geändert
        if (mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile != "") {
            lastSong = mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile;
            showNotification(lastSong);
        }
    }

    public function showNotification(songName:String):Void
    {
        songTxt.text = "NOW PLAYING: " + songName.toUpperCase();
        
        // ✨ NEON-FARBE WIEDER HINZUGEFÜGT
        var accentColor:FlxColor = FlxColor.WHITE;
        if (FlxG.save.data.songGradients != null) {
            var savedGrads:Map<String, Array<Int>> = cast FlxG.save.data.songGradients;
            if (savedGrads.exists(songName)) {
                var colors = savedGrads.get(songName);
                accentColor = FlxColor.interpolate(colors[0], colors[1], 0.5);
            } else {
                accentColor = FlxColor.interpolate(0xFFA8D0E6, 0xFF2A4B5E, 0.5);
            }
        } else {
            accentColor = FlxColor.interpolate(0xFFA8D0E6, 0xFF2A4B5E, 0.5);
        }
        songTxt.color = accentColor;

        FlxTween.cancelTweensOf(this);
        isShowing = true;
        showTimer = 5.0; 
        
        FlxTween.tween(this, {x: FlxG.width - 400}, 0.5, {ease: FlxEase.expoOut});
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        // ✨ Und hier wurde der Name ebenfalls angepasst
        if (mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile != lastSong) {
            lastSong = mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile;
            if (lastSong != "") showNotification(lastSong);
        }

        if (isShowing) {
            showTimer -= elapsed;
            if (showTimer <= 0) {
                isShowing = false;
                FlxTween.tween(this, {x: FlxG.width}, 0.5, {ease: FlxEase.expoIn});
            }
        }
    }
    
    override function destroy() {
        if (uiCam != null) FlxG.cameras.remove(uiCam);
        super.destroy();
    }
}