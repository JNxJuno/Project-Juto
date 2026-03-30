package states;

import flixel.FlxState;

// https://gamebanana.com/posts/12920491
class FreeplayState extends FlxState {
    override function create() {
        FlxG.switchState(mikolka.vslice.freeplay.FreeplayState.build());
        super.create();

        // ✨ GOOFY POWERPOINT TRANSITION KILLER + ZOOM ✨
		flixel.addons.transition.FlxTransitionableState.skipNextTransIn = true;
		flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
		
		flixel.FlxG.camera.zoom = 1.3;
		flixel.tweens.FlxTween.tween(flixel.FlxG.camera, {zoom: 1.0}, 0.7, {ease: flixel.tweens.FlxEase.expoOut});
		flixel.FlxG.camera.fade(flixel.util.FlxColor.BLACK, 0.5, true);
        openSubState(new FreeplayOverlay());
    }
}