package;

import flixel.addons.text.FlxTypeText;
import flixel.util.FlxSave;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.Lib;
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxAssets.FlxShader;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import Shaders;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import openfl.system.System;

using StringTools;

class NewMainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camGF:FlxCamera;

	var optionShit:Array<String> = [
		'storymode',
		'credits',
		#if !web 'art_gallery', #end //I know that this mod is not getting ported to web but uh I was bored
		'options'
	];

	var optionShit_NO_STORY:Array<String> = [
		#if !web 'art_gallery', #end
		'storymode',
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var scrollingThing:FlxBackdrop;
	var spikes1:FlxBackdrop;
	var spikes2:FlxBackdrop;
	var colorTween:FlxTween;
	var bg:FlxSprite;
	var vignette:FlxSprite;
	public var camHUD:FlxCamera;
	var typin:String;
	var KONAMI:String = 'up up down down left right left right b a ';
	var codeClearTimer:Float;

	public static var showTyping:Bool = false;
	var typinText:FlxText;
	var menuText:FlxText;
	var itemsText:FlxText;
	var shaderFloat:Float = 0;

	public var camGameShaders:Array<ShaderEffect> = [];

	var recentMouseOption:Int;

	var newToTheMod:Bool = false;

	var gfPopup:FlxSprite;
	var blackThingIG:FlxSpriteExtra;
	var textPopup:FlxText;
	public static var POPUP_TEXT = 'Hey!, Would you like to sing with me on my new Tutorial song?, before starting a new game of course. \n\n Press enter to play the tutorial or escape to continue normally';
	public static var gfMoment:Bool;
	var targetAlphaCamPopup:Int = 0;

	var chrom:ChromaticAberrationEffect;
	public static var crtShader = new CRTShader();
	var shaderFilter = new ShaderFilter(crtShader);
	var finishedZoom = false;
	var comeToOld = false;

	var colorsMap:Map<String, FlxColor> =
	[
		'storymode' => FlxColor.ORANGE,
		'freeplay' => FlxColor.CYAN,
		'credits' => 0xFF3de66f,
		'art_gallery' => FlxColor.YELLOW,
		'vault' => FlxColor.BLACK,
		'options' => FlxColor.WHITE,
	];

	var starThingOpened = false;

	override function create()
	{
        var save:FlxSave = new FlxSave();
        save.bind('funkin', 'ConflictSequel');
        comeToOld = save.data.comeToOld;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camGF = new FlxCamera();
		camGF.bgColor.alpha = 0;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camGF, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		camGF.alpha = targetAlphaCamPopup;


		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

	    Lib.application.window.title = "Computerized Conflict 2: The Sequel - Main Menu - Theme by: DangDoodle";

		FlxG.camera.zoom = 5;

		bg = new FlxSprite(-80, 75).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		scrollingThing = new FlxBackdrop(Paths.image('mainmenu/scroll'), XY, 0, 0);
		scrollingThing.alpha = 0.9;
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.7));
		add(scrollingThing);

		var circVignette:FlxSprite = new FlxSprite();
		circVignette.loadGraphic(Paths.image('mainmenu/circVig'));
		circVignette.scrollFactor.set();
		add(circVignette);

		vignette = new FlxSprite();
		vignette.loadGraphic(Paths.image('mainmenu/vignette'));
		vignette.scrollFactor.set();
		add(vignette);


		spikes1 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes1.y -= 60;
		spikes1.scrollFactor.set();
		spikes1.flipY = true;
		add(spikes1);

		spikes2 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes2.y += 630;
		spikes2.scrollFactor.set();
		add(spikes2);

		menuText = new FlxText(0, 0, FlxG.width, 'MAIN MENU', 29);
		menuText.setFormat(Paths.font("phantommuff.ttf"), 39, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
		menuText.x -= 630;
		menuText.y -= 340;
		add(menuText);

		itemsText = new FlxText(0, 0, FlxG.width, '', 18);
		itemsText.setFormat(Paths.font("phantommuff.ttf"), 34, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
		itemsText.y += 300;
		itemsText.x -= 630;
		add(itemsText);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.mouse.visible = true;

		#if !web FlxG.mouse.load(Paths.image("alt", 'shared').bitmap, 1.5, 0); #end

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(50, 50); //with this the positions will never work
			menuItem.loadGraphic(Paths.image('mainmenu/' + optionShit[i]));
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.2));

			var off = 0;
			var off_NO_STORY = 0;
			var fuckOPTIONS = 0;
			off_NO_STORY = -50;
			fuckOPTIONS = 250;

			switch(i)
			{
				case 0:
					menuItem.x = 100 + off_NO_STORY;
					menuItem.y = 100 + off;
				case 1:
					menuItem.x = 500 + off_NO_STORY;
					menuItem.y = 150 + off;
				case 2:
					menuItem.x = 930 + off_NO_STORY;
					menuItem.y = 130 + off;
				case 3:
					menuItem.x = 245 + off + off_NO_STORY + fuckOPTIONS;
					menuItem.y = 385 + off;
				case 4:
					menuItem.x = 610 + off;
					menuItem.y = 385 + off;
				case 5:
					menuItem.x = 950 + off;
					menuItem.y = 385 + off;
			}

			menuItem.scale.x = 0.25;
			menuItem.scale.y = 0.25;

			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		if (showTyping){
			typinText = new FlxText(0, FlxG.height / 16, 0, "", 12);
			typinText.scrollFactor.set();
			typinText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(typinText);
		}

		chrom = new ChromaticAberrationEffect(0);

		addShaderToCamera('camgame', chrom);
		//chrom.setChrome(shaderFloat);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		FlxG.camera.setFilters([shaderFilter]);

		super.create();
		
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.expoIn});
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true, function()
		{
			finishedZoom = true;
		});
	}

	//no achievements, go away

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;

		scrollingThing.alpha = 0.9;

		spikes1.x -= 0.45 * 60 * elapsed;
		spikes2.x -= 0.45 * 60 * elapsed;

		menuItems.forEach(function(menuItem:FlxSprite){
			/*var off = 0;
			var off_NO_STORY = 0;
			var fuckOPTIONS = 0;
			if(CoolUtil.songsUnlocked.data.mainWeek) off = -100;
			else {off_NO_STORY = -50; fuckOPTIONS = 250;}

			switch(menuItem.ID){
				case 0:
					menuItem.x = 100 + off_NO_STORY;
					menuItem.y = 100 + off;
				case 1:
					menuItem.x = 500 + off_NO_STORY;
					menuItem.y = 150 + off;
				case 2:
					menuItem.x = 930 + off_NO_STORY;
					menuItem.y = 130 + off;
				case 3:
					menuItem.x = 245 + off + off_NO_STORY + fuckOPTIONS;
					menuItem.y = 385 + off;
				case 4:
					menuItem.x = 610 + off;
					menuItem.y = 385 + off;
				case 5:
					menuItem.x = 950 + off;
					menuItem.y = 385 + off;
			}*/
			menuItem.updateHitbox();
		});

		if (!selectedSomethin && finishedZoom)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenuNew'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenuNew'));
				changeItem(1);
			}

			if (controls.UI_UP_P || controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenuNew'));
				var targetOption:Int = curSelected + 3;
				if (curSelected > 2) targetOption = curSelected - 3;
					if(curSelected == 3) //options menu
					{
						targetOption = 1;
					}
					else
					{
						targetOption = 3;
					}

				changeItem(targetOption-curSelected);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxTween.tween(FlxG.camera, {zoom: -2}, 1.5, {ease: FlxEase.expoIn});
				FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
				{
					MusicBeatState.switchState(new TitleState());
				});
				FlxG.sound.play(Paths.sound('cancelMenuNew'));
			}

			if (controls.ACCEPT)
			{
				loadState();
			}
			#if debug
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (FlxG.mouse.overlaps(spr) && !selectedSomethin && spr.ID != recentMouseOption)
				{
					curSelected = spr.ID;

					changeItem();
					recentMouseOption = curSelected;
				}

				if (FlxG.mouse.justPressed){
					FlxG.sound.play(Paths.sound('mouseClick'));
					loadState();
				}

				spr.alpha = 0.5;
				spr.updateHitbox();


				if (spr.ID != curSelected){
					spr.scale.x += (0.23-spr.scale.x)/(250*elapsed);
					spr.scale.y = spr.scale.x;
				}else{
					spr.alpha = 1;

					spr.scale.x += (0.26-spr.scale.x)/(250*elapsed);
					spr.scale.y = spr.scale.x;

					spr.centerOffsets();
				}

				if (optionShit[curSelected] == 'vault')
				{
					FlxG.camera.shake(0.0035, 0.15);
					FlxG.camera.zoom = FlxMath.lerp(1.2, FlxG.camera.zoom, 0.7);
					FlxTween.tween(bg, {alpha:0}, 0.4);
					FlxTween.tween(vignette, {alpha:0}, 0.4);

					shaderFloat += elapsed * 0.0015;
					chrom.setChrome(shaderFloat);
				    if (shaderFloat > 0.0085) shaderFloat = 0.0085;

					FlxG.sound.music.fadeIn(1, 0, 1);
				}
				else
				{
					FlxG.camera.zoom = 1;
					FlxTween.tween(bg, {alpha:1}, 0.4);
					FlxTween.tween(vignette, {alpha:1}, 0.4);
					shaderFloat -= elapsed * 0.0015;
					if (shaderFloat < 0) shaderFloat = 0;
					chrom.setChrome(shaderFloat);

					FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume * 1);
				}
			});

			if(codeClearTimer>0)codeClearTimer-=elapsed;
			if(codeClearTimer<=0)typin='';
			if(codeClearTimer<0)codeClearTimer=0;

			if(FlxG.keys.firstJustPressed()!=-1){
				var key:FlxKey = FlxG.keys.firstJustPressed();
				key = key.toString();

				typin += key + ' ';

				trace(key + ' // ' + typin);

				codeClearTimer = 1;
			}

			if (typinText != null){
				typinText.text = typin.toLowerCase() + '_';
				typinText.screenCenter(X);
				typinText.y = FlxG.height / 16;
			}
		}

		super.update(elapsed);
	}

	function loadState()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenuNew'));

		menuItems.forEach(function(spr:FlxSprite)
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
			else
			{
                var save:FlxSave = new FlxSave();
                save.bind('funkin', 'ConflictSequel');
				save.data.comeToOld = true;
                FlxG.save.flush();
				FlxG.log.add("Settings saved!");

				trace(save.data.comeToOld);

				new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					var daChoice:String = optionShit[curSelected];

					switch (daChoice)
					{
						default:
							Application.current.window.alert('The application has encountered a fatal error, please restart the application again.');
							System.exit(0);
					}
				});
			}
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		if(colorTween != null) {
			colorTween.cancel();
		}

		var nameOfOptionSelected:String = optionShit[curSelected];

		colorTween = FlxTween.color(scrollingThing, 1, scrollingThing.color, colorsMap.get(nameOfOptionSelected), {
			onComplete: function(twn:FlxTween) {
				colorTween = null;
			}
		});

		colorTween = FlxTween.color(vignette, 1, vignette.color, colorsMap.get(nameOfOptionSelected), {
			onComplete: function(twn:FlxTween) {
				colorTween = null;
			}
		});

		itemsText.text = textChange(nameOfOptionSelected);
	}

    public function addShaderToCamera(cam:String, effect:ShaderEffect){//STOLE FROM ANDROMEDA

		switch(cam.toLowerCase()) {
			case 'camgame' | 'game':
					camGameShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camGameShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camGame.setFilters(newCamEffects);
		}
	}

	public function removeShaderFromCamera(cam:String, effect:ShaderEffect){
		switch(cam.toLowerCase()) {
			case 'camgame' | 'game':
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camGameShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
		}
	}

	function textChange(tag:String)
	{
		switch(tag)
		{
			case 'storymode': return 'Face off against Alan Becker stick figures with the power of music!';

			case 'freeplay': return 'Play bonus songs and meet other stick figures, will you recognize them?';

			case 'credits': return 'Meet the people behind this mod!';

			case 'art_gallery': return 'Look at some art made by our followers!';

			case 'options': return 'Configure your controls and more to your preference!';
			
			case 'vault': return '...';
		}

		return '';
	}
}