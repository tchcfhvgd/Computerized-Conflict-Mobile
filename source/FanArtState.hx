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
	public var coolArtistArray:Array<String> = [];
	public var actualNum = 0;
	public var numOfThings = 0;
	var selectedSmth:Bool = false;
	var bg:FlxSprite;
	var colorTween:FlxTween;
	var firstImage:Float = 0;
	var bgText:FlxSprite;
	var textArtists:FlxText;
	
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
		
		bgText = new FlxSprite(0, -50).loadGraphic(Paths.image('FAMenu/artist-text-BG'));
		bgText.scrollFactor.set();
		bgText.setGraphicSize(Std.int(bgText.width * 0.5));
		bgText.updateHitbox();
		bgText.screenCenter(X);
		bgText.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgText);

		textArtists = new FlxText(0, 15, 0, 'null', 32);
		textArtists.screenCenter(X);
		textArtists.setFormat(Paths.font("phantommuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textArtists.scrollFactor.set();
		add(textArtists);

		changeImage();
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		if (!selectedSmth)
		{
			numOfThings = FileSystem.readDirectory('assets/images/fan-arts/' + coolArtistArray[actualNum] + '/').length;

			for (i in 0...coolArtistArray.length) image.loadGraphic(Paths.image('fan-arts/' + coolArtistArray[actualNum] + '/' + (firstImage+1)));
			image.setGraphicSize(400);
			//image.screenCenter();
			image.updateHitbox();
			image.screenCenter();

			var thing = Std.int(textArtists.width) + 100;

			if (thing < 400) thing = 400;

			bgText.setGraphicSize(thing, 100);

			textArtists.screenCenter(X);
			textArtists.text = coolArtistArray[actualNum];

			/*image.width = 400;
			image.height = 400;*/

			if(firstImage >= numOfThings)
				firstImage = 0;
			else if(firstImage < 0)
				firstImage = numOfThings - 1;

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				Paths.clearUnusedMemory();
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

		firstImage = 0;
		
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