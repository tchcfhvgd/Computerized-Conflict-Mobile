package;

import flixel.graphics.FlxGraphic;
import sys.FileSystem;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;

class CutsceneState extends MusicBeatState
{
	public var finishCallback:Void->Void;
	public var songName:String;
	public var endingCutscene:Bool = false;

	public var video:MP4Handler;

	public function new(songName:String, isEnd:Bool, ?finishCallback:Void->Void)
	{
		super();

		if (finishCallback != null)
			this.finishCallback = finishCallback;

		this.songName = songName;
		endingCutscene = isEnd;
	}
	
	override public function create()
	{
		Paths.clearStoredMemory();
		
		video = new MP4Handler();
		video.playVideo(Paths.video(songName + '-cutscene'));
		
		video.finishCallback = function()
		{
			if (finishCallback != null)
				finishCallback();
		}
	}
}