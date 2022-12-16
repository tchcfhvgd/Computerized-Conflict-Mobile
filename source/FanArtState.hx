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
	public static var coolArtistArray:Array<String> =
	[
		'KAV1029',
		'Primpinkk',
		'femalefoxpaint',
		'icemaskuwu',
		'korifiedd',
		'TaigaTart',
		'Kazuki'
	];
	public static var actualNum = 0;
	var selectedSmth:Bool = false;
	var bg:FlxSprite;
	var colorTween:FlxTween;
	var firstImage:Float = 1;
	
	override public function create()
	{
		Paths.clearStoredMemory();
		
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
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			
			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				firstImage = firstImage + 1;
				changeImage(1);
			}
			else if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeImage( -1);
				if (firstImage != 1)firstImage = firstImage - 1;
			}
		}
		super.update(elapsed);
	}
	
	function changeImage(number:Int = 0)
	{
		
		actualNum += number;
		
		if (firstImage == 2)
		{
		if (actualNum >= coolArtistArray.length)
			actualNum = 0;
		if (actualNum < 0)
			actualNum = coolArtistArray.length - 1;
		}
		
		trace(firstImage);
			
		for (i in 0...coolArtistArray.length) image.loadGraphic(Paths.image('fan-arts/' + coolArtistArray[actualNum] + '/' + firstImage));
		image.screenCenter();
		
		if(colorTween != null) {
			colorTween.cancel();
		}
		
		switch(actualNum) //shittest code ever fr
		{
			case 0:
				colorTween = FlxTween.color(bg, 1, bg.color, 0xFFE1F63F, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
			
			case 1:
				colorTween = FlxTween.color(bg, 1, bg.color, 0xFF28A8C8, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
			case 2:
				colorTween = FlxTween.color(bg, 1, bg.color, 0xFFD60600, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
		}
	}
}