package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import sys.FileSystem;
import sys.io.File;

class FanArtState extends MusicBeatState
{
	public var image:FlxSprite;
	public static var coolArtistArray:Array<String> = [];
	public static var actualNum = 0;
	public static var numOfThings = 0;
	var selectedSmth:Bool = false;
	var bg:FlxSprite;
	var colorTween:FlxTween;
	var firstImage:Float = 0;
	
	override public function create()
	{
		Paths.clearStoredMemory();

		var thing:Array<String> = FileSystem.readDirectory('assets/images/fan-arts/');
		for (i in 0...thing.length){
			coolArtistArray.push(thing[i]);
		}
		
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		image = new FlxSprite();
		add(image);
		
		changeImage();
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		if (!selectedSmth)
		{
			numOfThings = FileSystem.readDirectory('assets/images/fan-arts/' + coolArtistArray[actualNum] + '/').length;

			for (i in 0...coolArtistArray.length) image.loadGraphic(Paths.image('fan-arts/' + coolArtistArray[actualNum] + '/' + (firstImage+1)));
			image.screenCenter();

			if(firstImage >= numOfThings)
				firstImage = 0;
			else if(firstImage < 0)
				firstImage = numOfThings - 1;

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			
			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeImage(1);
			}
			else if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeImage(-1);
			}
			else if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeNo(1);
			}
			else if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeNo(-1);
			}
		}
		super.update(elapsed);
	}
	
	function changeImage(number:Int = 0)
	{
		actualNum += number;

		firstImage = 1;
		
		if (actualNum >= coolArtistArray.length)
			actualNum = 0;
		if (actualNum < 0)
			actualNum = coolArtistArray.length - 1;
		
			
		//for (i in 0...coolArtistArray.length) image.loadGraphic(Paths.image('fan-arts/' + coolArtistArray[actualNum] + '/' + (firstImage+1)));
		//image.screenCenter();
		
		trace(firstImage + ' ' + numOfThings);
	}

	function changeNo(change:Int = 0)
	{
		firstImage += change;
	}
}