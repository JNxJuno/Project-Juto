package backend;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class CustomFadeTransition extends FlxSubState {
	public static var finishCallback:Void->Void;
	var isTransIn:Bool = false;
	var duration:Float;

	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

		// ✨ Wendet den smoothen Effekt automatisch auf JEDE Kamera an!
		for (cam in FlxG.cameras.list) {
			if (cam != null) {
				FlxTween.cancelTweensOf(cam);
				if(isTransIn) {
					cam.zoom = 1.3; 
					FlxTween.tween(cam, {zoom: 1.0}, duration, {ease: FlxEase.expoOut});
					cam.fade(FlxColor.BLACK, duration, true); 
				} 
				else {
					FlxTween.tween(cam, {zoom: 0.7}, duration, {ease: FlxEase.expoIn});
					cam.fade(FlxColor.BLACK, duration, false); 
				}
			}
		}

		new FlxTimer().start(duration, function(tmr:FlxTimer) {
			close();
		});

		super.create();
	}

	override function close():Void
	{
		super.close();
		if(finishCallback != null)
		{
			var cb = finishCallback; 
			finishCallback = null;
			cb();
		}
	}
}