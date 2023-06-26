package;

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
import flixel.graphics.frames.FlxAtlasFrames;
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
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxAssets.FlxShader;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import Shaders;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'freeplay',
		'storymode',
		'credits',
		'art_gallery',
		'vault',
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
	public var repeatAxes:FlxAxes = XY;
	var bg:FlxSprite;
	var vignette:FlxSprite;
	public var camHUD:FlxCamera;
	var typin:String;
	var KONAMI:String = 'up up down down left right left right b a ';
	var codeClearTimer:Float;

	public static var showTyping:Bool = false;
	var typinText:FlxText;
	var blackBG:FlxSprite;
	var menuText:FlxText;
	var itemsText:FlxText;
	var glitchBG:BGSprite;
	var shaderFloat:Float = 0;
	
	public var camGameShaders:Array<ShaderEffect> = [];

	var recentMouseOption:Int;
	var chrom:ChromaticAberrationEffect;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);


		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80, 75).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		scrollingThing = new FlxBackdrop(Paths.image('mainmenu/scroll'), repeatAxes, 0, 0);
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
		spikes1.scrollFactor.set(0, 0);
		spikes1.flipY = true;
		add(spikes1);

		spikes2 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes2.y += 630;
		spikes2.scrollFactor.set(0, 0);
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

		FlxG.mouse.load(Paths.image("EProcess/alt", 'chapter1').bitmap, 1.5, 0);

		if (CoolUtil.songsUnlocked == null){
			trace('null null null');
			CoolUtil.songsUnlocked = new FlxSave();
			CoolUtil.songsUnlocked.bind("Computarized-Conflict");

			if (CoolUtil.songsUnlocked.data.songs == null) {
				CoolUtil.songsUnlocked.data.songs = new Map<String, Bool>();
				for (i in 0...VaultState.codesAndShit.length){
					CoolUtil.songsUnlocked.data.songs.set(VaultState.codesAndShit[i][1], false);
				}
			}

			if (CoolUtil.songsUnlocked.data.mainWeek == null) {
				CoolUtil.songsUnlocked.data.mainWeek = false;
			}
			trace(CoolUtil.songsUnlocked.data.mainWeek);

			CoolUtil.songsUnlocked.flush();
		}

		if (!CoolUtil.songsUnlocked.data.mainWeek)
		{
			optionShit.remove('freeplay');
			optionShit.remove('vault');
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionShit.length)
		{
			//var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(50, 50); //with this the positions will never work
			menuItem.loadGraphic(Paths.image('mainmenu/' + optionShit[i]));
			menuItem.ID = i;
			menuItem.x += i * 450 ;//with this the positions will never work
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.2));
			var off = 0;
			if(CoolUtil.songsUnlocked.data.mainWeek) off = -100;
			switch(i){
				case 0:
					menuItem.x = 50;
					menuItem.y = 50 + off;
					
				case 1:
					menuItem.x = 450;
					menuItem.y = 50 + off;
					
				case 2:
					menuItem.x = 850;
					menuItem.y = 100 + off;
					
				case 3:
					menuItem.x = 245 + off;
					menuItem.y = 400 + off;
					
				case 4:
					menuItem.x = 645 + off;
					menuItem.y = 600 + off;
				case 5:
					menuItem.x = 1045 + off;
					menuItem.y = 400 + off;
			}
			menuItem.updateHitbox();
		}

		/*for (i in 0...VaultState.codesAndShit.length){
			CoolUtil.songsUnlocked.data.songs.set(VaultState.codesAndShit[i][1], false);
		}
		CoolUtil.songsUnlocked.flush();*/

		FlxG.camera.follow(camFollowPos, null, 1);
		
		blackBG = new FlxSpriteExtra(-120, -120).makeSolid(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
		blackBG.scrollFactor.set();
		blackBG.alpha = 0;
		blackBG.screenCenter();
		add(blackBG);

		if (showTyping){
			typinText = new FlxText(0, FlxG.height / 16, 0, "", 12);
			typinText.scrollFactor.set();
			typinText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(typinText);
		}
		
		glitchBG = new BGSprite('vault/newGlitchBG', 450, 215, 0.9, 0.9, ['g'], true);
		glitchBG.cameras = [camHUD];
		glitchBG.screenCenter();
		glitchBG.antialiasing = ClientPrefs.globalAntialiasing;
		glitchBG.alpha = 0;
		add(glitchBG);
		
		chrom = new ChromaticAberrationEffect(0);
		
		if (ClientPrefs.shaders) addShaderToCamera('camgame', chrom);
		//chrom.setChrome(shaderFloat);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;
		
		scrollingThing.alpha = 0.9;

		spikes1.x -= 0.45 * 60 * elapsed;
		spikes2.x -= 0.45 * 60 * elapsed;

		menuItems.forEach(function(menuItem:FlxSprite){
			var off = 0;
			if(CoolUtil.songsUnlocked.data.mainWeek) off = -100;
			switch(menuItem.ID){
				case 0:
					menuItem.x = 50;
					menuItem.y = 100 + off;
				case 1:
					menuItem.x = 500;
					menuItem.y = 250 + off;
				case 2:
					menuItem.x = 930;
					menuItem.y = 130 + off;
				case 3:
					menuItem.x = 245 + off;
					menuItem.y = 385 + off;
				case 4:
					menuItem.x = 645 + off;
					menuItem.y = 385 + off;
				case 5:
					menuItem.x = 930 + off;
					menuItem.y = 385 + off;
			}
			menuItem.updateHitbox();
		});

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.UI_UP_P || controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				var targetOption:Int = curSelected + 3;
				if (curSelected > 2) targetOption = curSelected - 3;
				if (curSelected == 1 || curSelected == 2 && !CoolUtil.songsUnlocked.data.mainWeek) targetOption = 4;

				changeItem(targetOption-curSelected);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				loadState();
			}

			#if desktop
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
					FlxG.camera.shake(0.035, 0.15);
					FlxG.camera.zoom = FlxMath.lerp(1.6, FlxG.camera.zoom, 0.7);
					FlxTween.tween(bg, {alpha:0}, 0.4);
					FlxTween.tween(vignette, {alpha:0}, 0.4);
					
					shaderFloat += elapsed * 0.0015;
					chrom.setChrome(shaderFloat);
				    if (shaderFloat > 0.0085) shaderFloat = 0.0085;
					
					FlxG.sound.music.fadeIn(4, 0, 1);
				}
				else
				{
					FlxG.camera.zoom = 1;
					FlxTween.tween(bg, {alpha:1}, 0.4);
					FlxTween.tween(vignette, {alpha:1}, 0.4);
					shaderFloat -= elapsed * 0.0015;
					if (shaderFloat < 0) shaderFloat = 0;
					chrom.setChrome(shaderFloat);
					
					FlxG.sound.music.fadeOut();
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

			if (typin.toLowerCase() == KONAMI){
				CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
				selectedSomethin = true;
				typin = 'LOADING REDZONE ERROR';
				PlayState.storyDifficulty = 2;
				PlayState.SONG = Song.loadFromJson('redzone-error-insane', 'redzone-error');
				LoadingState.loadAndSwitchState(new PlayState(), true);
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
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.5);

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
				
				if (optionShit[curSelected] == 'vault')
				{
					glitchBG.alpha = 1;
					var shit:FlxSound = new FlxSound().loadEmbedded(Paths.sound('glitch'));
					shit.play(true);
					shit.onComplete = function() {
						FlxG.switchState(new VaultState());
					}
				}

				new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					var daChoice:String = optionShit[curSelected];

					switch (daChoice)
					{
						case 'storymode':
							openSubState(new MessageSubstate());
							//MusicBeatState.switchState(new TCOStoryState());
						case 'freeplay':
							MusicBeatState.switchState(new FreeplayMenu());
						case 'awards':
							MusicBeatState.switchState(new AchievementsMenuState());
						case 'art_gallery':
							MusicBeatState.switchState(new FanArtState());
						case 'credits':
							MusicBeatState.switchState(new TCOCreditsState());
						case 'options':
							LoadingState.loadAndSwitchState(new options.OptionsState());
					}
				});
			}

			/*if (curSelected == spr.ID)
			{
				spr.acceleration.y = 5550;
				spr.velocity.y -= 5550;
			}*/
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

		switch(optionShit[curSelected])
		{
			case 'storymode':

				colorTween = FlxTween.color(scrollingThing, 1, scrollingThing.color, FlxColor.ORANGE, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				colorTween = FlxTween.color(vignette, 1, vignette.color, FlxColor.ORANGE, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				itemsText.text = 'Face off against Alan Becker stick figures with the power of music!';

			case 'freeplay':

				colorTween = FlxTween.color(scrollingThing, 1, scrollingThing.color, FlxColor.CYAN, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				colorTween = FlxTween.color(vignette, 1, vignette.color, FlxColor.CYAN, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				itemsText.text = 'Play bonus songs and meet other stick figures, will you recognize them?';

			case 'credits':

				colorTween = FlxTween.color(scrollingThing, 1, scrollingThing.color, 0xFF3de66f, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				colorTween = FlxTween.color(vignette, 1, vignette.color, 0xFF3de66f, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				itemsText.text = 'Meet the people behind this mod!';

			case 'art_gallery':

				colorTween = FlxTween.color(scrollingThing, 1, scrollingThing.color, FlxColor.YELLOW, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				colorTween = FlxTween.color(vignette, 1, vignette.color, FlxColor.YELLOW, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				itemsText.text = 'Look at some art made by our followers!';

			case 'options':

				colorTween = FlxTween.color(scrollingThing, 1, scrollingThing.color, FlxColor.WHITE, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				colorTween = FlxTween.color(vignette, 1, vignette.color, FlxColor.WHITE, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
			    });
				
				itemsText.text = 'Configure your controls and more to your preference!';

			case 'vault':

				colorTween = FlxTween.color(scrollingThing, 0.5, scrollingThing.color, FlxColor.BLACK, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});
				
				itemsText.text = '...';
		}
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
}