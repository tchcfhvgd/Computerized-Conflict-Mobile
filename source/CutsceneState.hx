package;

import flixel.graphics.FlxGraphic;
#if sys
import sys.FileSystem;
#end
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
import openfl.utils.Assets as OpenFlAssets;

#if VIDEOS_ALLOWED
#if (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#else import vlc.MP4Handler; #end
#end

using StringTools;

class CutsceneState extends MusicBeatState
{
	public var finishCallback:Void->Void;
	public var videoName:String;
	public var endingCutscene:Bool = false;
	public var isIntro:Bool = false;
	public var skipeable:Bool = true;

	var video:MP4Handler;

	public function new(videoName:String, isEnd:Bool, ?finishCallback:Void->Void, ?canSkip:Bool = true)
	{
		super();

		if (finishCallback != null)
			this.finishCallback = finishCallback;

		this.videoName = videoName;
		this.skipeable = canSkip;
	}

	override public function create()
	{
		Paths.clearStoredMemory();

		startVideo(videoName + '-cutscene', skipeable);
	}

	override function update(elapsed:Float)
	{
		if (!skipeable) 
		{
			#if (hxCodec >= "2.6.1")
			video.volume = Std.int(#if FLX_SOUND_SYSTEM ((FlxG.sound.muted) ? 0 : 1) * #end FlxG.sound.volume * 100);
			#else
			if (FlxG.sound.muted || FlxG.sound.volume <= 0)
				video.volume = 0;
			else
				video.volume = FlxG.sound.volume + 0.4;
			#end
		}

		super.update(elapsed);
	}

	public function startVideo(name:String, ?canSkip:Bool = true)
	{
		#if VIDEOS_ALLOWED

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			goToState();
		}

		video = new MP4Handler();
		video.playVideo(filepath);
		if (!canSkip) 
		{
			FlxG.stage.removeEventListener('enterFrame', @:privateAccess video.update);
		}

		video.finishCallback = function()
		{
			goToState();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		goToState();
		#end
	}

	function goToState()
	{
		switch(videoName)
		{
			case 'codes':
				MusicBeatState.switchState(new MessagesState(true));
			case 'alan-unlock' | 'tco_credits':
				MusicBeatState.switchState(new FreeplayMenu());
			default:
				LoadingState.loadAndSwitchState(new PlayState());
		}
	}
}