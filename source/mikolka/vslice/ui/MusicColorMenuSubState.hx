package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.Paths;

class MusicColorMenuSubState extends MusicBeatSubstate
{
    var options:Array<String> = ["Color 1 (Top)", "Color 2 (Mid)", "Color 3 (Bot)"];
    var curSelected:Int = 0;
    var grpOptions:FlxTypedGroup<FlxText>;
    var valueTexts:FlxTypedGroup<FlxText>;
    var isClosing:Bool = false;

    public function new() {
        super();
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);
        FlxTween.tween(bg, {alpha: 0.85}, 0.3);

        grpOptions = new FlxTypedGroup<FlxText>();
        valueTexts = new FlxTypedGroup<FlxText>();
        add(grpOptions);
        add(valueTexts);

        for (i in 0...options.length) {
            var opt = new FlxText(-500, 200 + (i * 120), 0, options[i].toUpperCase(), 35);
            opt.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, LEFT);
            opt.ID = i;
            grpOptions.add(opt);

            var val = new FlxText(FlxG.width + 500, 200 + (i * 120), 500, "", 35);
            val.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, RIGHT);
            val.ID = i;
            valueTexts.add(val);

            FlxTween.tween(opt, {x: 150}, 0.4 + (i * 0.1), {ease: FlxEase.backOut});
            FlxTween.tween(val, {x: FlxG.width - 650}, 0.4 + (i * 0.1), {ease: FlxEase.backOut});
        }
        
        updateValues();
        changeSelection(0);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (isClosing) return;

        if (controls.UI_UP_P) changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);
        if (controls.UI_LEFT_P) changeValue(-1);
        if (controls.UI_RIGHT_P) changeValue(1);
        if (controls.BACK || controls.ACCEPT) close();
    }

    function changeSelection(change:Int) {
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
        grpOptions.forEach(function(txt:FlxText) {
            txt.alpha = (txt.ID == curSelected) ? 1.0 : 0.4;
        });
    }

    function changeValue(change:Int) {
        var song = mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile;
        if (song == null) song = "freakyMenu";

        var colors:Array<Int> = [0xFFFFFFFF, 0xFF00FFFF, 0xFFFF00FF, 0xFFFFFF00, 0xFFFF0000, 0xFF00FF00, 0xFF4B0082, 0xFFFF4500, 0xFF0000FF];
        
        if (FlxG.save.data.songColors == null) FlxG.save.data.songColors = new Map<String, Array<Int>>();
        
        var curCols:Array<Int> = FlxG.save.data.songColors.get(song);
        if (curCols == null || curCols.length < 3) curCols = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];

        var idx = colors.indexOf(curCols[curSelected]);
        if (idx == -1) idx = 0;
        
        curCols[curSelected] = colors[FlxMath.wrap(idx + change, 0, colors.length - 1)];
        
        FlxG.save.data.songColors.set(song, curCols);
        FlxG.save.flush();
        updateValues();
    }

    function updateValues() {
        var song = mikolka.vslice.ui.MusicSettingsSubState.currentPlayingFile;
        if (song == null) song = "freakyMenu";

        var curCols:Array<Int> = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];
        if (FlxG.save.data.songColors != null) {
            var saved:Array<Int> = FlxG.save.data.songColors.get(song);
            if (saved != null && saved.length >= 3) curCols = saved;
        }

        if (valueTexts == null) return;

        valueTexts.forEach(function(txt:FlxText) {
            if (txt == null) return;
            
            var col:Int = 0xFFFFFFFF;
            if (txt.ID >= 0 && txt.ID < curCols.length) {
                col = curCols[txt.ID];
            }
            
            txt.text = "#" + std.StringTools.hex(col, 6);
            txt.color = col;
        });
    }
}