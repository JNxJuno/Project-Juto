package;

import mikolka.vslice.components.crash.CrashServer;
import mikolka.vslice.components.DebugDisplay.FunkinDebugDisplay;
import mikolka.funkin.custom.mobile.MobileScaleMode;
import states.InitState;
import mikolka.vslice.components.crash.Logger;
#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end
import openfl.display.FPS;
import mikolka.GameBorder;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
#if (linux || mac)
import lime.graphics.Image;
#end

#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
class Main extends Sprite
{
	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: InitState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var debugDisplay:FunkinDebugDisplay;
	public static final platform:String = #if mobile "Phones" #else "PCs" #end;

	public static function loadGameEarly()
	{
		#if sys
		haxe.Log.trace = function(v, ?infos) {
			var str = (infos != null ? infos.fileName + ":" + infos.lineNumber + ": " : "") + v;
			untyped __cpp__('printf("%s\\n", str.__s)');
		};
		#end

		CrashServer.init();

		#if (linux || mac) 
		var icon = lime.graphics.Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if android
		StorageUtil.requestPermissions();
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		#if mobile
		extension.haptics.Haptic.initialize();
		#end

		#if sys
		Logger.startLogging();
		trace("CWD IS " + StorageUtil.getStorageDirectory());
		#end

		backend.CrashHandler.init();
		trace("Crash handler is up!");

		try
		{
			trace("Pushing global mods");
			#if LUA_ALLOWED
			Mods.pushGlobalMods();
			#end
			trace("Pushing top mod");
			Mods.loadTopMod();
		}
		catch (x:haxe.Exception)
			trace("Something went wrong with mod code: " + x.message);

		#if hxvlc
		trace("Starting hxvlc..");
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
		#end
	}

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		trace("Main constructor done");
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		setupGame();
	}

	private function setupGame():Void
	{
		trace(backend.Native.buildSystemInfo());

		#if (openfl <= "9.2.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		#else
		if (game.zoom == -1.0)
			game.zoom = 1.0;
		#end

		trace("Initializing save .sol");
		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		CrashServer.setupInstanceId();

		trace("Loading scores..");
		Highscore.load();

		#if HSCRIPT_ALLOWED
		Iris.warn = function(x, ?pos:haxe.PosInfos) {
			if (PlayState.instance != null) PlayState.instance.addTextToDebug('WARNING: ' + x, flixel.util.FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos) {
			if (PlayState.instance != null) PlayState.instance.addTextToDebug('ERROR: ' + x, flixel.util.FlxColor.RED);
		}
		#end

		#if LUA_ALLOWED
		trace("Hooking up Lua");
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call));
		#end

		trace("Loading controls");
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		trace("Loading game object...");
		var gameObject = new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen);

		@:privateAccess
		gameObject._customSoundTray = mikolka.vslice.components.FunkinSoundTray;

		addChild(gameObject);

		trace("Finishing up..");
		debugDisplay = new FunkinDebugDisplay(10, 10, 0xFFFFFF);
		addChild(debugDisplay);

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		if (debugDisplay != null)
		{
			debugDisplay.visible = ClientPrefs.data.showFPSOpacity != 0;
			debugDisplay.backgroundOpacity = ClientPrefs.data.showFPSOpacity;
			debugDisplay.isAdvanced = ClientPrefs.data.fpsRework;
		}

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = #if mobile 30 #else 60 #end;
		FlxG.keys.preventDefaultKeys = [TAB];

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		FlxG.signals.gameResized.add(function(w, h)
		{
			if (FlxG.game != null) resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}