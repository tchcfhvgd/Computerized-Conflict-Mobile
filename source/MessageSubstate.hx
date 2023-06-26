package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

using StringTools;

class MessageSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	
	public function new()
	{
		super();
		
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		add(bg);
		
		var msgBox = new FlxSprite(0, 0).loadGraphic(Paths.image('gfDialog'));
		msgBox.screenCenter();
		msgBox.antialiasing = ClientPrefs.globalAntialiasing;
		add(msgBox);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.85) bg.alpha = 0.85;
	}
}