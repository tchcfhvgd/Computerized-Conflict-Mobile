package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;

#if desktop
import Discord.DiscordClient;
#end

#if mobile
import mobile.CopyState;
#end

using StringTools;

class Main extends Sprite
{
	public static var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}

	public function new()
	{
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		CrashHandler.init();

		#if windows
		@:functionCode("
		#include <windows.h>
		#include <winuser.h>
		setProcessDPIAware() // allows for more crisp visuals
		DisableProcessWindowsGhosting() // lets you move the window and such if it's not responding
		")
		#end
			
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
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
		#if desktop
		Window.setDarkMode(true);
		Window.registerAsDPICompatible();
		#end
		
		ClientPrefs.loadDefaultKeys();
		FlxTransitionableState.skipNextTransOut = true;
		addChild(new FlxGame(game.width, game.height, #if (mobile && MODS_ALLOWED) !CopyState.checkExistingFiles() ? CopyState : #end game.initialState, #if (flixel < "5.0.0") 1, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		#if !mobile
		addChild(fpsVar);
		#else
		FlxG.game.addChild(fpsVar);
		#end
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

                #if mobile
		lime.system.System.allowScreenTimeout = ClientPrefs.screensaver;
		#if android
		FlxG.android.preventDefaultKeys = [BACK]; 
		#end
		#end

		FlxG.signals.gameResized.add(fixCameraShaders);

		#if desktop
		if (!DiscordClient.isInitialized) {
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		}
		#end
	}

	public static function fixCameraShaders(w:Int, h:Int) //fixes shaders after resizing the window / fullscreening
	{
		if (FlxG.cameras.list.length > 0)
		{
			for (cam in FlxG.cameras.list)
			{
				if (cam.flashSprite != null)
				{
					@:privateAccess 
					{
						cam.flashSprite.__cacheBitmap = null;
						cam.flashSprite.__cacheBitmapData = null;
						cam.flashSprite.__cacheBitmapData2 = null;
						cam.flashSprite.__cacheBitmapData3 = null;
						cam.flashSprite.__cacheBitmapColorTransform = null;
					}
				}
			}
		}
	}
}
