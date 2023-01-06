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

class MinusCharSelector extends MusicBeatState
{
	public var boyfriend:FlxSprite;
	public static var bfSkins:Array<String> = ['betaBF', 'blueBF', 'meanBF'];
	public static var actualNum = 0;
	var selectedSmth:Bool = false;
	var bg:FlxSprite;
	var colorTween:FlxTween;
	var topBars:FlxSprite;
	var bottomBars:FlxSprite;
	
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
		
		topBars = new FlxSprite().makeGraphic (2580, 320, FlxColor.BLACK);
		topBars.screenCenter();
		topBars.y -= 850;
		add(topBars);
					
		bottomBars = new FlxSprite().makeGraphic (2580, 320, FlxColor.BLACK);
		bottomBars.screenCenter();
		bottomBars.y += 850;
		add(bottomBars);
		
		boyfriend = new FlxSprite();
		add(boyfriend);

		for (i in 0...bfSkins.length){
			Paths.getSparrowAtlas('characters/CC/extras/minus/' + bfSkins[i], 'shared');
		}
		
		changeBF();
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		if (!selectedSmth)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new FreeplayState());
			}
			else if (controls.ACCEPT)
			{
				selectedSmth = true;

				if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				boyfriend.animation.play('ye');
				trace(bfSkins[actualNum]);
				PlayState.amityChar = bfSkins[actualNum];
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
					FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
					{
						LoadingState.loadAndSwitchState(new PlayState());
					});
				});
				//PlayState.SONG.player1 = bfSkins[actualNum];
			}
			
			
			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeBF(1);
			}
			else if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeBF(-1);
			}
		}
		super.update(elapsed);
	}
	
	function changeBF(number:Int = 0)
	{
		actualNum += number;
		
		if (actualNum >= bfSkins.length)
			actualNum = 0;
		if (actualNum < 0)
			actualNum = bfSkins.length - 1;
			
		for (i in 0...bfSkins.length) boyfriend.frames = Paths.getSparrowAtlas('characters/CC/extras/minus/' + bfSkins[actualNum], 'shared'); //IT FUCKING FINALLY LOADED
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.9));
		boyfriend.screenCenter();
		boyfriend.antialiasing = ClientPrefs.globalAntialiasing;
		boyfriend.animation.addByPrefix('idle', 'BF idle dance', 24);
		boyfriend.animation.addByPrefix('ye', 'BF HEY!!', 24);
		boyfriend.animation.play('idle');
		
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