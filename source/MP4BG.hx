package;

import flixel.FlxSprite;
import openfl.events.Event;
import flixel.FlxG;
import vlc.bitmap.VlcBitmap;

/**
 * Play a video using cpp.
 * Use bitmap to connect to a graphic or use `MP4Sprite`.
 */

// this is me, tibu (I had to copy most of the MP4 handler thing's code)
class MP4BG extends VlcBitmap
{
	public var readyCallback:Void->Void;
	public var finishCallback:Void->Void;

    public var pathToVideo:String;

	public function new(?width:Float = 320, ?height:Float = 240, ?autoScale:Bool = true)
	{
		super(width, height, autoScale);

		onVideoReady = onVLCVideoReady;
		onComplete = finishVideo;
		onError = onVLCError;

		FlxG.addChildBelowMouse(this);

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		FlxG.signals.focusGained.add(function()
		{
			resume();
		});
		FlxG.signals.focusLost.add(function()
		{
			pause();
		});

        alpha = 0;

        volume = 0;
	}

	function update(e:Event)
	{
        alpha = 0;

		volume = 0;
	}

	#if sys
	function checkFile(fileName:String):String
	{
		#if !android
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
		#else
		return "file://" + fileName;
		#end
	}
	#end

	function onVLCVideoReady()
	{
		trace("Video loaded!");

		if (readyCallback != null)
			readyCallback();
	}

	function onVLCError()
	{
		// TODO: Catch the error
		throw "VLC caught an error!";
	}

	public function finishVideo()
	{
		#if sys
		play(checkFile(pathToVideo));
		#else
		throw "Doesn't support sys";
		#end
	}

	/**
	 * Native video support for Flixel & OpenFL & my ass
	 * @param path Example: `your/video/here.mp4`
	 */
	public function playVideo(path:String, ?repeat:Bool = false, pauseMusic:Bool = false)
	{
        pathToVideo = path;
		#if sys
		play(checkFile(pathToVideo));
		#else
		throw "Doesn't support sys";
		#end
	}
}
