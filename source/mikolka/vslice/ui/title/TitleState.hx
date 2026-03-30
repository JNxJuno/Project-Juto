package mikolka.vslice.ui.title;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.compatibility.VsliceOptions;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDirectionFlags;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import haxe.Json;
import openfl.Assets;
import mikolka.vslice.components.crash.Logger;
import shaders.ColorSwap;

#if VIDEOS_ALLOWED
import mikolka.vslice.ui.title.AttractState;
#end

typedef TitleData =
{
    var titlex:Float;
    var titley:Float;
    var startx:Float;
    var starty:Float;
    var gfx:Float;
    var gfy:Float;
    var backgroundSprite:String;
    var bpm:Float;
    @:optional var animation:String;
    @:optional var dance_left:Array<Int>;
    @:optional var dance_right:Array<Int>;
    @:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;

    var bg:FlxSprite;
    var logoBl:FlxSprite;
    var gfDance:FlxSprite;
    var titleText:FlxSprite;
    var swagShader:ColorSwap = null;
    
    var danceLeft:Bool = false;
    var newTitle:Bool = false;
    var skippedIntro:Bool = false;
    var transitioning:Bool = false;
    var cheatActive:Bool = false;

    // Variablen für den JSON Loader
    var musicBPM:Float = 102;
    var enterPosition:FlxPoint = FlxPoint.get(100, 576);

    override public function create():Void
    {
        CacheSystem.clearStoredMemory();
        super.create();
        CacheSystem.clearUnusedMemory();
        
        if (FlxG.save.data.hasChosenStartSong == null || FlxG.save.data.hasChosenStartSong == false) {
            MusicBeatState.switchState(new mikolka.vslice.ui.title.ChooseFirstSongState());
            return;
        }

        startIntro();
    }

    function startIntro()       
    {
        persistentUpdate = true;
        if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        {
            var startSong:String = 'freakyMenu';
            if (FlxG.save.data.lastSongName != null && FlxG.save.data.lastSongName != "") {
                startSong = FlxG.save.data.lastSongName;
            }

            mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile = startSong;
            FlxG.sound.playMusic(Paths.music('menuSongs/' + startSong), 0);
            FlxG.sound.music.fadeIn(4, 0, 0.7);
        }

        loadJsonData();
        easterEggData(); // ✨ Funktion wird jetzt immer gefunden
        Conductor.bpm = musicBPM;

        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('freakyBackground', 'shared')); 
        bg.antialiasing = VsliceOptions.ANTIALIASING;
        bg.updateHitbox();
        bg.screenCenter(); 
        add(bg); 

        // ✨ LOGO: 0.7 Scale & Zentriert
        logoBl = new FlxSprite(0, -500); 
        logoBl.loadGraphic(Paths.image('logo')); 
        logoBl.antialiasing = VsliceOptions.ANTIALIASING;
        
        logoBl.scale.set(0.7, 0.7); 
        logoBl.updateHitbox();
        logoBl.screenCenter(X); 
        
        if (VsliceOptions.SHADERS) {
            swagShader = new ColorSwap();
            logoBl.shader = swagShader.shader;
        }
        add(logoBl);

        // ✨ TEXT: Weiter unten bei Y=620
        titleText = new FlxSprite(0, 620);
        titleText.frames = Paths.getSparrowAtlas('titleEnter');
        titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
        titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
        titleText.animation.play('idle');
        titleText.updateHitbox();
        titleText.screenCenter(X); 
        add(titleText);

        if (!initialized) {
        } else {
            #if desktop
            DiscordClient.changePresence("Titelbildschirm", null);
            #end
            startTitleMovement();
        }

        if (initialized) skipIntro();
        else {
            openSubState(new IntroSubstate());
            initialized = true;
        }
    }

    function loadJsonData()
    {
        if (Paths.fileExists('images/gfDanceTitle.json', TEXT))
        {
            var titleRaw:String = Paths.getTextFromFile('images/gfDanceTitle.json');
            if (titleRaw != null && titleRaw.length > 0)
            {
                try {
                    var titleJSON:TitleData = Json.parse(titleRaw);
                    musicBPM = titleJSON.bpm;
                } catch (e:haxe.Exception) {
                    trace('[WARN] Title JSON broken');
                }
            }
        }
    }

    // ✨ FIX: Diese Funktion muss existieren, damit der Compiler nicht meckert
    function easterEggData() {
        // Hier könnte später Code für Easter Eggs rein
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.R) {
            FlxG.save.data.hasChosenStartSong = false;
            FlxG.save.flush();
            MusicBeatState.switchState(new mikolka.vslice.ui.title.ChooseFirstSongState());
            return;
        }

        if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

        var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
        if (initialized && !transitioning && skippedIntro)
        {
            if (pressedEnter)
            {
                if (titleText != null) titleText.animation.play('press');
                FlxG.camera.flash(FlxColor.WHITE, 1);
                FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                transitioning = true;

                new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    MusicBeatState.switchState(new MainMenuState());
                    closedState = true;
                });
            }
        }

        if (initialized && pressedEnter && !skippedIntro) skipIntro();

        super.update(elapsed);
    }

    override function beatHit()
    {
        super.beatHit();
    }

    function skipIntro():Void
    {
        if (!skippedIntro)
        {
            closeSubState();
            FlxG.camera.flash(FlxColor.WHITE, 4);
            skippedIntro = true;
            startTitleMovement();
        }
    }

    function startTitleMovement() {
        // Schwebendes Logo bei Y=30
        FlxTween.tween(logoBl, {y: 30}, 1.4, {
            ease: FlxEase.expoOut 
        });
    }
}