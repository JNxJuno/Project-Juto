package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import states.PlayState;
import backend.Paths;

class CharSelectSubState extends MusicBeatSubstate 
{
    var targetSong:String;
    var titleText:FlxText;
    var triangleTop:FlxSprite;
    var triangleBot:FlxSprite;
    var exiting:Bool = false;
    
    // ✨ Speichert, welches Dreieck ausgewählt ist (0 = oben, 1 = unten)
    var curSelected:Int = 0; 

    public function new(songName:String)
    {
        super();
        this.targetSong = songName;
    }

    override function create()
    {
        super.create();

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6; 
        add(bg);

        titleText = new FlxText(-800, -800, 0, "Choose Character", 50);
        titleText.setFormat(null, 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        titleText.angle = -25; 
        add(titleText);

        triangleTop = new FlxSprite(-800, -800).makeGraphic(120, 120, FlxColor.WHITE);
        triangleTop.angle = 45;
        add(triangleTop);

        triangleBot = new FlxSprite(-800, -800).makeGraphic(120, 120, FlxColor.GRAY);
        triangleBot.angle = 45;
        add(triangleBot);

        var centerX = FlxG.width / 2;
        var centerY = FlxG.height / 2;

        FlxTween.tween(titleText, {x: centerX - 250, y: centerY - 30}, 0.8, {ease: FlxEase.quartOut});
        FlxTween.tween(triangleTop, {x: centerX + 50, y: centerY - 150}, 0.8, {ease: FlxEase.quartOut, startDelay: 0.1});
        FlxTween.tween(triangleBot, {x: centerX - 180, y: centerY + 80}, 0.8, {ease: FlxEase.quartOut, startDelay: 0.1});
        
        changeSelection(0); // ✨ Setzt die erste Auswahl beim Start
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (exiting) return;

        // ✨ Wechselt mit Hoch/Runter die Auswahl
        if (controls.UI_UP_P || controls.UI_DOWN_P) {
            changeSelection(curSelected == 0 ? 1 : 0); 
        }

        if (controls.BACK)
        {
            exiting = true; 
            FlxG.sound.play(Paths.sound('cancelMenu'));
            
            FlxTween.tween(triangleTop, {x: -800, y: -800}, 0.6, {ease: FlxEase.quartIn});
            FlxTween.tween(triangleBot, {x: -800, y: -800}, 0.6, {ease: FlxEase.quartIn});
            FlxTween.tween(titleText, {x: -800, y: -800}, 0.6, {
                ease: FlxEase.quartIn, 
                onComplete: function(twn:FlxTween) {
                    close(); 
                }
            });
        }

        if (controls.ACCEPT)
        {
            exiting = true;
            FlxG.sound.play(Paths.sound('confirmMenu'));
            
            // ✨ Hier übergeben wir später, welcher Charakter gespielt wird!
            MusicBeatState.switchState(new PlayState());
        }
    }
    
    // ✨ Ändert die Farben beim Auswählen
    function changeSelection(newSelection:Int) {
        curSelected = newSelection;
        FlxG.sound.play(Paths.sound('scrollMenu'));
        
        if (curSelected == 0) {
            triangleTop.color = FlxColor.WHITE; // Leuchtet
            triangleBot.color = 0xFF555555;     // Dunkelgrau
        } else {
            triangleTop.color = 0xFF555555;     // Dunkelgrau
            triangleBot.color = FlxColor.WHITE; // Leuchtet
        }
    }
}