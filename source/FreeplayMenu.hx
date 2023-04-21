package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayMenu extends MusicBeatState
{
	public static var curSelected:Int = 0;
	var bg:FlxSprite;
	var scrollingThing:FlxBackdrop;
	var scrollingText1:FlxBackdrop;
	var scrollingText2:FlxBackdrop;
	var vignette:FlxSprite;
	var freeplayMenuText:FlxSprite;
	var littleBar:FlxSprite;
	var infoBar:FlxSprite;
	var folderGroup:FlxTypedGroup<FlxSprite>;
	var folders:Array<String> = [
		'story',
		'extra',
		'cover',
		'old'
	];
	
	var weeks:Array<Array<String>> = [
		['Chapter 1'],
		['Tutorial Week', 'Extras', 'Secret'],
		['Covers'],
		['Old']
	];
	var selectedSmth:Bool = false;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	
	
	override function create()
	{
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		
		bg = new FlxSprite().loadGraphic(Paths.image('freeplayArt/selectMenu/bgAngled'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		scrollingThing = new FlxBackdrop(Paths.image('Main_Checker'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.alpha = 0.8;
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.4));
		add(scrollingThing);
		
		vignette = new FlxSprite();
		vignette.loadGraphic(Paths.image('freeplayArt/selectMenu/vignette'));
		vignette.scrollFactor.set();
		add(vignette);
		
		folderGroup = new FlxTypedGroup<FlxSprite>();
		add(folderGroup);
		
		for (i in 0...folders.length)
		{
			var folderItem:FlxSprite = new FlxSprite(150, (i * 330)  + 70);
			folderItem.loadGraphic(Paths.image('freeplayArt/selectMenu/' + folders[i] + '-folder'));
			folderItem.ID = i;
			folderItem.scrollFactor.set(0, 1);
			folderGroup.add(folderItem);
			folderItem.antialiasing = ClientPrefs.globalAntialiasing;
			
			switch(i)
			{
				case 2:
					folderItem.x = 70;
			}
			folderItem.updateHitbox();
		}
		
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		
		scrollingText1 = new FlxBackdrop(Paths.image('mainmenu/text1'), X, 0, 0);
		scrollingText1.scale.set(0.55, 0.55);
		scrollingText1.y -= 20;
		scrollingText1.scrollFactor.set(0, 0);
		add(scrollingText1);
		
		scrollingText2 = new FlxBackdrop(Paths.image('mainmenu/text2'), X, 0, 0);
		scrollingText2.scale.set(0.55, 0.55);
		scrollingText2.y += 660;
		scrollingText2.scrollFactor.set(0, 0);
		add(scrollingText2);
		
		littleBar = new FlxSprite();
		littleBar.loadGraphic(Paths.image('freeplayArt/selectMenu/bar'));
		littleBar.scrollFactor.set();
		add(littleBar);
		
		freeplayMenuText = new FlxSprite();
		freeplayMenuText.loadGraphic(Paths.image('freeplayArt/selectMenu/freeplay-text'));
		freeplayMenuText.scrollFactor.set();
		add(freeplayMenuText);
		
		infoBar = new FlxSprite();
		infoBar.loadGraphic(Paths.image('freeplayArt/selectMenu/textShit'));
		infoBar.scrollFactor.set();
		add(infoBar);
		
		FlxG.camera.follow(camFollowPos, null, 1);
		
		changeItem();
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		scrollingThing.x -= 0.45;
		scrollingThing.y -= 0.16;
		
		scrollingText1.x -= 0.45;
		scrollingText2.x -= 0.45;
		
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		
		folderGroup.forEach(function(spr:FlxSprite){
			switch(spr.ID){
				case 0:
					spr.x = 150;
					spr.y = 70;
				case 1:
					spr.x = 150;
					spr.y = 400;
				case 2:
					spr.x = 70;
					spr.y = 730;
				case 3:
					spr.x = 150;
					spr.y = 1060;
			}

			var a:Float;
			if (spr.ID == curSelected){
				a = 1;
			}else{
				a = 0.85;
			}
			spr.scale.x += (a-spr.scale.x)/(250*elapsed);
			spr.scale.y = spr.scale.x;

			spr.updateHitbox();
		});
		
		//folderGroup.forEach(function(folderItem:FlxSprite) folderItem.x = 150);
		
		if (!selectedSmth)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeItem(-FlxG.mouse.wheel);
			}

			if (controls.BACK)
			{
				selectedSmth = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			
			if (controls.ACCEPT)
			{
				selectedSmth = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				folderGroup.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						MusicBeatState.switchState(new FreeplayState(weeks[curSelected]));
					});
				});
		    }
		}
			
		super.update(elapsed);
	}
	
	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= folderGroup.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = folderGroup.length - 1;
			

		folderGroup.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0.5;
			//spr.updateHitbox();
			
			if (spr.ID == curSelected)
			{
				spr.alpha = 1;
				var add:Float = 0;
				
				if(folderGroup.length > 4) {
					add = folderGroup.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}