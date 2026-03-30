package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

import backend.Song;
import backend.Paths;
import backend.Conductor;
import backend.CacheSystem; 
import states.PlayState;
import mikolka.vslice.ui.MainMenuState; 

class ProjectState extends MusicBeatState
{
    var weekItems:Array<String> = ['tutorial', 'week1', 'week2', 'week3', 'music']; 
    var grpWeekItems:FlxTypedGroup<FlxSprite>;
    
    public static var curSelected:Int = 0;
    var selectedSomethin:Bool = false;

    override function create()
    {
        try {
            CacheSystem.clearStoredMemory();
            CacheSystem.clearUnusedMemory();
        } catch(e) {}

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        bg.antialiasing = true;
        bg.screenCenter();
        add(bg);

        grpWeekItems = new FlxTypedGroup<FlxSprite>();
        add(grpWeekItems);

        for (i in 0...weekItems.length)
        {
            var item:FlxSprite = new FlxSprite(0, 0);
            item.frames = Paths.getSparrowAtlas('mainmenu/menu_' + weekItems[i]);
            item.animation.addByPrefix('idle', weekItems[i] + " basic", 24);
            item.animation.addByPrefix('selected', weekItems[i] + " white", 24);
            item.animation.play('idle');
            
            item.ID = i;
            item.antialiasing = true;
            item.scale.set(0.5, 0.5);
            item.updateHitbox();
            grpWeekItems.add(item);
        }

        changeItem();
        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if (!selectedSomethin)
        {
            if (FlxG.keys.justPressed.X) {
                quickLaunch("dadbattle", "nightmare"); 
            }

            if (controls.UI_UP_P || controls.UI_LEFT_P) changeItem(-1);
            if (controls.UI_DOWN_P || controls.UI_RIGHT_P) changeItem(1);

            if (controls.BACK) {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new MainMenuState());
            }

            if (controls.ACCEPT) {
                selectWeek();
            }
        }
        super.update(elapsed);
    }

    function changeItem(huh:Int = 0)
    {
        if (huh != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + huh, 0, weekItems.length - 1);

        grpWeekItems.forEach(function(item:FlxSprite)
        {
            var diff = item.ID - curSelected;
            item.animation.play(item.ID == curSelected ? 'selected' : 'idle');

            var angle:Float = diff * 0.45; 
            var targetX = 250 + (Math.cos(angle) * 300); 
            var targetY = (FlxG.height / 2 - 50) + (Math.sin(angle) * 250); 

            FlxTween.tween(item, {
                x: targetX,
                y: targetY,
                alpha: (item.ID == curSelected ? 1 : 0.4)
            }, 0.25, {ease: FlxEase.quadOut});

            if (item.ID == curSelected) {
                item.color = 0xFFCCCCCC;
                FlxTween.color(item, 0.4, 0xFFCCCCCC, FlxColor.WHITE, {ease: FlxEase.quadInOut, type: PINGPONG});
            } else {
                item.color = FlxColor.WHITE;
                FlxTween.cancelTweensOf(item, ["color"]);
            }
        });

        grpWeekItems.sort(function(order:Int, a:FlxSprite, b:FlxSprite):Int {
            return FlxSort.byValues(FlxSort.DESCENDING, Math.abs(a.ID - curSelected), Math.abs(b.ID - curSelected));
        });
    }

    function selectWeek()
    {
        selectedSomethin = true;
        FlxG.sound.play(Paths.sound('confirmMenu'));
        FlxG.camera.flash(FlxColor.WHITE, 0.5);

        var songName = weekItems[curSelected].toLowerCase();

        if (songName == 'music') {
            new FlxTimer().start(1, function(tmr:FlxTimer) {
                openSubState(new mikolka.vslice.ui.MusicSettingsSubState());
            });
            return; 
        }

        PlayState.storyPlaylist = [songName];
        PlayState.isStoryMode = true;
        PlayState.storyDifficulty = 2; 

        try {
            PlayState.SONG = Song.loadFromJson(songName + '-hard', songName);
        } catch(e:Dynamic) {
            PlayState.SONG = Song.loadFromJson(songName, songName);
        }

        new FlxTimer().start(1, function(tmr:FlxTimer) {
            openSubState(new mikolka.vslice.ui.CharSelectSubState(songName));
        });
    }

    function quickLaunch(song:String, diff:String)
    {
        selectedSomethin = true;
        FlxG.sound.play(Paths.sound('confirmMenu'));
        
        var songLower = song.toLowerCase();
        
        try {
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = 3; 
            PlayState.SONG = Song.loadFromJson(songLower + '-' + diff, songLower);
            
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() {
                MusicBeatState.switchState(new PlayState());
            });
        } catch(e:Dynamic) {
            MusicBeatState.switchState(new mikolka.vslice.freeplay.FreeplayState());
        }
    }

    // ✨ NEU: Entsperrt die Tasten wieder, wenn das Overlay geschlossen wird!
    override public function closeSubState() {
        super.closeSubState();
        selectedSomethin = false; 
    }
}