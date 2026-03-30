package mikolka.vslice.ui.mainmenu;

import states.FreeplayState;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSort; 
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.misc.ColorTween; 
import mikolka.vslice.ui.ProjectState;
import states.CreditsState;
import mikolka.vslice.ui.StoryMenuState;
import mikolka.vslice.ui.title.TitleState;

#if !LEGACY_PSYCH
import states.editors.MasterEditorMenu;
#else
import editors.MasterEditorMenu;
#end

@:access(mikolka.vslice.ui.MainMenuState)
class DesktopMenuState extends FlxBasic
{
    var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'music', 'options'];
    var parallaxBG:FlxSprite;
    var logo:FlxSprite; 
    var menuItems:FlxTypedGroup<FlxSprite>;
    
    public static var curSelected:Int = 0;
    var selectedSomethin:Bool = false;
    var host:mikolka.vslice.ui.MainMenuState;
    var targetBGX:Float = 0;

    var colorTweens:Array<ColorTween> = [];

    public function new(host:mikolka.vslice.ui.MainMenuState) {
        super();
        this.host = host;
        host.add(this);
        
        host.subStateClosed.add(function(state:flixel.FlxSubState) {
            if (Std.isOfType(state, mikolka.vslice.ui.GlobalPlaylistSubState)) return;
            selectedSomethin = false;
            
            if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
                var startSong:String = 'freakyMenu';
                if (FlxG.save.data.lastSongName != null && FlxG.save.data.lastSongName != "") {
                    startSong = FlxG.save.data.lastSongName;
                }

                FlxG.save.data.lastSongTime = 0;
                FlxG.save.flush();

                mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile = startSong;
                FlxG.sound.playMusic(Paths.music('menuSongs/' + startSong), 0.7);
            }
            changeItem(0); 
        });

        parallaxBG = new FlxSprite().loadGraphic(Paths.image('mainmenu/menuBG'));
        parallaxBG.antialiasing = true;
        parallaxBG.setGraphicSize(Std.int(FlxG.width * 1.3)); 
        parallaxBG.updateHitbox();
        parallaxBG.screenCenter();
        parallaxBG.scrollFactor.set(0, 0); 
        host.add(parallaxBG);
        targetBGX = parallaxBG.x;
        
        logo = new FlxSprite().loadGraphic(Paths.image('logo')); 
        logo.antialiasing = true;
        logo.setGraphicSize(Std.int(logo.width * 0.45));
        logo.updateHitbox();
        logo.x = FlxG.width - logo.width - 50; 
        logo.y = (FlxG.height / 2) - (logo.height / 2);
        logo.scrollFactor.set(0, 0);
        host.add(logo);

        FlxTween.tween(logo.scale, {x: 0.47, y: 0.47}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});
        menuItems = new FlxTypedGroup<FlxSprite>();
        host.add(menuItems);

        for (i in 0...optionShit.length) {
            var menuItem:FlxSprite = new FlxSprite(0, 0);
            
            // ✨ FIX: Lädt jetzt nur das reine Bild, keine XML nötig!
            menuItem.loadGraphic(Paths.image('mainmenu/customButtons/menu_' + optionShit[i]));
            
            menuItem.ID = i; 
            menuItem.antialiasing = true;

            // Alle Buttons haben die gleiche Skalierung
            menuItem.scale.set(0.6, 0.6); 
            
            menuItem.updateHitbox();
            menuItem.centerOffsets(); 
            menuItems.add(menuItem);
        }

        changeItem();
    }

    override function update(elapsed:Float) {
        if (host.subState != null) return;

        if (parallaxBG != null) {
            parallaxBG.x = FlxMath.lerp(parallaxBG.x, targetBGX, FlxMath.bound(elapsed * 4, 0, 1));
        }

        if (!selectedSomethin) {
            if (FlxG.keys.justPressed.SEVEN) {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('scrollMenu'));
                MusicBeatState.switchState(new MasterEditorMenu());
            }

            if (host.controls.UI_UP_P || host.controls.UI_LEFT_P) changeItem(-1);
            if (host.controls.UI_DOWN_P || host.controls.UI_RIGHT_P) changeItem(1);
            
            if (host.controls.BACK) {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new TitleState());
            }

            if (host.controls.ACCEPT) {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                FlxG.camera.flash(FlxColor.WHITE, 0.2); 
                
                var selectedSpr:FlxSprite = null;
                menuItems.forEach(function(spr:FlxSprite) {
                    if(spr.ID == curSelected && colorTweens[spr.ID] != null) colorTweens[spr.ID].cancel();
                    
                    if (spr.ID == curSelected) selectedSpr = spr;
                    else FlxTween.tween(spr, {alpha: 0}, 0.3); 
                });
                
                if (selectedSpr != null) {
                    selectedSpr.color = FlxColor.WHITE; 
                    FlxTween.tween(selectedSpr, {x: (FlxG.width / 2) - (selectedSpr.width / 2), y: (FlxG.height / 2) - (selectedSpr.height / 2)}, 0.6, {ease: FlxEase.expoOut});
                }

                new FlxTimer().start(0.2, function(tmr:FlxTimer) {
                    if (optionShit[curSelected] == 'music') {
                        selectedSomethin = false; 
                        host.openSubState(new mikolka.vslice.ui.MusicSettingsSubState());
                        menuItems.forEach(function(spr:FlxSprite) { spr.alpha = 1; });
                    } else {
                        if(logo != null) FlxTween.tween(logo, {alpha: 0}, 0.3);
                        FlxTween.tween(FlxG.camera, {zoom: 3.0}, 0.8, {ease: FlxEase.expoIn});
                        
                        FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function() {
                            FlxTransitionableState.skipNextTransIn = true;
                            FlxTransitionableState.skipNextTransOut = true;
                            
                            switch (optionShit[curSelected]) {
                                case 'story_mode': MusicBeatState.switchState(new ProjectState());
                                case 'freeplay': MusicBeatState.switchState(new states.FreeplayState()); 
                                case 'credits': MusicBeatState.switchState(new CreditsState());
                                case 'options': host.goToOptions();
                            }
                        });
                    }
                });
            }
        }
        super.update(elapsed);
    }

    function sortDepth(order:Int, a:FlxSprite, b:FlxSprite):Int {
        var diffA = Math.abs(a.ID - curSelected);
        var diffB = Math.abs(b.ID - curSelected);
        return FlxSort.byValues(FlxSort.DESCENDING, diffA, diffB);
    }

    function changeItem(huh:Int = 0) {
        if (huh != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + huh, 0, optionShit.length - 1);

        menuItems.forEach(function(item:FlxSprite) {
            var diff = item.ID - curSelected;
            
            FlxTween.cancelTweensOf(item); 
            FlxTween.cancelTweensOf(item.scale);
            if(colorTweens[item.ID] != null) colorTweens[item.ID].cancel(); 
            
            item.visible = true; 
            
            var angle:Float = diff * 0.45; 
            var targetX = -200 + (Math.cos(angle) * 280); 
            var targetY = 300 + (Math.sin(angle) * 350); 

            var baseScale = 0.6; 
            var targetScale = (item.ID == curSelected) ? baseScale + 0.15 : baseScale;

            FlxTween.tween(item, {
                x: targetX,
                y: targetY, 
                alpha: (item.ID == curSelected ? 1 : 0.4) 
            }, 0.25, {ease: FlxEase.quadOut});

            FlxTween.tween(item.scale, {
                x: targetScale,
                y: targetScale
            }, 0.25, {ease: FlxEase.quadOut});

            if (item.ID == curSelected) {
                item.color = 0xFFCCCCCC; 
                colorTweens[item.ID] = FlxTween.color(item, 0.4, item.color, FlxColor.WHITE, {
                    ease: FlxEase.quadInOut, 
                    type: PINGPONG
                });
            } else {
                item.color = FlxColor.WHITE; 
            }
        });

        menuItems.sort(sortDepth);
        targetBGX = -100 + (curSelected * 40); 
    }
}