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
import openfl.Lib;
#if MODS_ALLOWED
import sys.FileSystem;
#end

import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import Shaders;

using StringTools;

class FreeplayMenu extends MusicBeatState
{
	public static var curSelected:Int = 0;
	var bg:FlxSprite;
	var scrollingThing:FlxBackdrop;
	var vignette:FlxSprite;
	var freeplayMenuText:FlxSprite;
	var littleBar:FlxSprite;
	var infoBar:FlxSprite;
	var folderGroup:FlxTypedGroup<FlxSprite>;
	var spikes1:FlxBackdrop;
	var spikes2:FlxBackdrop;
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
	var finishedZoom = false;
	var menuText:FlxText;
	var yellowSquare:FlxSpriteExtra;

	public static var crtShader = new CRTShader();
	var shaderFilter = new ShaderFilter(crtShader);

	override function create()
	{
		Paths.clearStoredMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		Lib.application.window.title = "Computerized Conflict - Freeplay Menu - Theme by: DangDoodle";

		FlxG.camera.zoom = 1.5;

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
		
		spikes1 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes1.y -= 60;
		spikes1.scrollFactor.set(0, 0);
		spikes1.flipY = true;
		add(spikes1);

		spikes2 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes2.y += 630;
		spikes2.scrollFactor.set(0, 0);
		add(spikes2);

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

		var leftBar:FlxSpriteExtra = new FlxSpriteExtra().makeSolid(50, 720, FlxColor.WHITE);
		leftBar.scrollFactor.set();
		add(leftBar);

		yellowSquare = new FlxSpriteExtra(0, 0).makeSolid(50, 50, 0xFFfeff95);
		yellowSquare.scrollFactor.set();
		add(yellowSquare);

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

		menuText = new FlxText(0, 0, FlxG.width, '', 29);
		menuText.setFormat(Paths.font("phantommuff.ttf"), 26, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
		menuText.angle -= 1.5;
		add(menuText);

		FlxG.camera.follow(camFollowPos, null, 1);

		changeItem();

		Paths.clearUnusedMemory();

		if (ClientPrefs.shaders) FlxG.camera.setFilters([shaderFilter]);

		super.create();

		addTouchPad("UP_DOWN", "A_B");
	        addTouchPadCamera();

		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.expoIn});
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true, function()
		{
			finishedZoom = true;
		});
	}

	override function update(elapsed:Float)
	{
		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;
		
		spikes1.x -= 0.45 * 60 * elapsed;
		spikes2.x -= 0.45 * 60 * elapsed;

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

			spr.scale.x = FlxMath.lerp(spr.scale.x, a, lerpVal);
			spr.scale.y = spr.scale.x;

			spr.updateHitbox();
		});

		//folderGroup.forEach(function(folderItem:FlxSprite) folderItem.x = 150);

		if (!selectedSmth && finishedZoom)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
			else if (controls.UI_DOWN_P)
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
				FlxTween.tween(FlxG.camera, {zoom: -2}, 1.5, {ease: FlxEase.expoIn});
				FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
				{
					MusicBeatState.switchState(new MainMenuState());
				});
			}
			else if (controls.ACCEPT)
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

						FlxTween.tween(FlxG.camera, {zoom: 3}, 1.5, {ease: FlxEase.expoIn});
						FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
						{
							MusicBeatState.switchState(new FreeplayState(weeks[curSelected]));
						});
					}
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

		switch(folders[curSelected])
		{
			case 'story':
				menuText.text = '
				Rap Battle Against The Chosen One and\n
				other characters from the\n
				"Animator vs. Animation" Series!
				';
				yellowSquare.y = 210;
			case 'extra':
				menuText.text = '
				Want more than this mod can offer?\n
				This folder is made for you!
				';
				yellowSquare.y = 310;
			case 'cover':
				menuText.text = '
				Are you looking for the collab songs?\n
				Or the covers?\n
				All of them are here!
				';
				yellowSquare.y = 410;
		    case 'old':
				menuText.text = '
				Feeling to play the legacy songs, huh?\n
				This folder section is for ya!
				';
				yellowSquare.y = 510;
		}

		menuText.x = FlxG.width - menuText.width - 3;
		menuText.screenCenter(Y);
		menuText.scrollFactor.set(0,0);
		menuText.y += 30;

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
