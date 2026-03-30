package options;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.vslice.components.crash.UserErrorSubstate;
import backend.StageData;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import mikolka.vslice.ui.GlobalNowPlaying;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Note Colors', 'Controls', 'Delay & Combo', 'Graphics',
		'Visuals', 'Gameplay', 'P-Slice Options', 'V-Slice Options'
		#if TRANSLATIONS_ALLOWED , 'Language' #end
		#if (TOUCH_CONTROLS_ALLOWED || mobile) , 'Mobile Options' #end
	];
	var optionDescs:Array<String> = [
		'Adjust the colors\nof your notes.',
		'Change your\nkeybinds.',
		'Calibrate your\naudio delay and\ncombo position.',
		'Settings for\nFPS and more.',
		'Toggle visual\neffects.',
		'Change gameplay\nmechanics.',
		'Special settings\nfor the\nP-Slice Engine.',
		'Special settings\nfor the\nV-Slice Engine.'
		#if TRANSLATIONS_ALLOWED , 'Change the\ngame language.' #end
		#if (TOUCH_CONTROLS_ALLOWED || mobile) , 'Adjust touch\ncontrols.' #end
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var descGroup:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	
	public static var onPlayState:Bool = false;
	var exiting:Bool = false;
	var transitioning:Bool = false;

	private var mainCam:FlxCamera;
	public static var funnyCam:FlxCamera;
	function openSelectedSubstate(label:String) {
		if (label != "Delay & Combo") funnyCam.visible = persistentUpdate = false;

		switch(label) {
			case 'Note Colors': openSubState(new options.NotesColorSubState());
			case 'Controls':
				if (controls.mobileC) {
					funnyCam.visible = persistentUpdate = true;
					UserErrorSubstate.makeMessage("Unsupported controls", "You don't need to go there on mobile!\n\nSet 'Mobile Controls Opacity' to 0%");
				} else openSubState(new options.ControlsSubState());
			case 'Graphics': openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals': openSubState(new options.VisualsSettingsSubState());
			case 'Gameplay': openSubState(new options.GameplaySettingsSubState());
			case 'Delay & Combo': MusicBeatState.switchState(new options.NoteOffsetState());
			case 'P-Slice Options': openSubState(new PSliceSubState());
			case 'V-Slice Options': openSubState(new VSliceSubState());
			#if (TOUCH_CONTROLS_ALLOWED || mobile) case 'Mobile Options': openSubState(new mobile.options.MobileOptionsSubState()); #end
			#if TRANSLATIONS_ALLOWED case 'Language': openSubState(new options.LanguageSubState()); #end
		}
	}

	override function create()
	{
		mainCam = initPsychCamera();
		funnyCam = new FlxCamera();
		funnyCam.bgColor.alpha = 0;
		FlxG.cameras.add(funnyCam, false);

		FlxG.camera.zoom = 1.3;
		FlxTween.tween(FlxG.camera, {zoom: 1.0}, 0.5, {ease: FlxEase.expoOut});
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		#if DISCORD_ALLOWED DiscordClient.changePresence("Options Menu", null); #end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFA8D0E6;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		descGroup = new FlxTypedGroup<Alphabet>();
		add(descGroup);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		for (num => option in options)
		{
			var optionText:Alphabet = new Alphabet(0, 0, Language.getPhrase('options_$option', option), true);
			optionText.ID = num;
			optionText.cameras = [funnyCam];
			optionText.x = -100; 
			optionText.y = (FlxG.height / 2) + ((num - curSelected) * 120);
			
			grpOptions.add(optionText);
		}

		changeSelection(0);
		ClientPrefs.saveSettings();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('UP_DOWN', 'A_B');
		var button = new TouchZone(90,270,FlxG.width,100,FlxColor.PURPLE);
		var scroll = new ScrollableObject(-0.01,100,0,FlxG.width-200,FlxG.height,button);
		scroll.onPartialScroll.add(delta -> changeSelection(Std.int(delta)));
		scroll.onFullScrollSnap.add(() ->changeSelection(0));
		scroll.onTap.add(() ->{ 
			if(!transitioning) startTransition(); 
		});
		add(scroll);
		add(button);
		#end
		
		super.create();
		
		var globalMusic = new GlobalNowPlaying();
		globalMusic.cameras = [funnyCam];
		add(globalMusic);
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED DiscordClient.changePresence("Options Menu", null);
		#end
		controls.isInSubstate = false;
		persistentUpdate = funnyCam.visible = true;
		
		transitioning = false;
		for (item in grpOptions.members) {
			item.x = -800; 
		}
		changeSelection(0);

		#if TOUCH_CONTROLS_ALLOWED
		removeTouchPad();
		addTouchPad('UP_DOWN', 'A_B');
		#end
	}

		override function update(elapsed:Float) {
		super.update(elapsed);
		if(exiting) return;

		if (!transitioning) {
			if (controls.UI_UP_P || controls.UI_LEFT_P) changeSelection(-1);
			if (controls.UI_DOWN_P || controls.UI_RIGHT_P) changeSelection(1);

			var lerpVal:Float = Math.max(0, Math.min(1, elapsed * 10));
			for (item in grpOptions.members)
			{
				var diff = item.ID - curSelected;
				var targetY = (FlxG.height / 2) - (item.height / 2) + (diff * 110);
				var targetX = (item.ID == curSelected) ? 60 : -(item.width / 2); 

				item.y = FlxMath.lerp(item.y, targetY, lerpVal);
				item.x = FlxMath.lerp(item.x, targetX, lerpVal);

				var targetAlpha = (item.ID == curSelected) ? 1.0 : 0.4;
				item.alpha = FlxMath.lerp(item.alpha, targetAlpha, lerpVal);
			}

			// ✨ FIX: Der pure SwitchState für das Options-Menü
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				exiting = true;

				if(onPlayState) {
					StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
				} else {
					MusicBeatState.switchState(new MainMenuState());
				}
			}
			else if (controls.ACCEPT) {
				startTransition();
			}
		}
	}
	
	function startTransition() {
		FlxG.sound.play(Paths.sound('confirmMenu'));
		transitioning = true;
		
		descGroup.forEach(function(txt:Alphabet) {
			FlxTween.tween(txt, {alpha: 0}, 0.3, {ease: FlxEase.quadOut});
		});
		for (item in grpOptions.members) {
			if (item.ID == curSelected) {
				FlxTween.tween(item, {x: FlxG.width + 50}, 0.5, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween) {
					openSelectedSubstate(options[curSelected]);
				}});
			} else {
				FlxTween.tween(item, {x: -500, alpha: 0}, 0.4, {ease: FlxEase.expoIn});
			}
		}
	}

	function changeSelection(change:Int = 0) {
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		
		descGroup.clear();
		var descText = new Alphabet(0, 0, optionDescs[curSelected], true);
		descText.cameras = [funnyCam];
		
		descText.scale.set(0.5, 0.5);
		descText.updateHitbox();
		descText.x = FlxG.width - descText.width - 40; 
		descText.y = (FlxG.height / 2) - (descText.height / 2);
		descText.alpha = 0;
		FlxTween.tween(descText, {alpha: 1}, 0.4, {ease: FlxEase.quadOut});
		descGroup.add(descText);
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}