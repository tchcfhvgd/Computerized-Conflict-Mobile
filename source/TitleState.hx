package;

#if desktop
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.display.BlendMode;
import FlxSpriteExtra;

using StringTools;
typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var spikes1:FlxBackdrop;
	var spikes2:FlxBackdrop;
	var chosenOne:FlxSprite;
	var darkLord:FlxSprite;
	var socialItems:FlxTypedGroup<FlxSprite>;
	var alanSpr:FlxSprite;
	public static var instance:TitleState;

	var socialMedia:Array<String> = [
		'gamebanana',
		'x',
		'gamejolt'
	];
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var smite:FlxSprite;
	var doNotZoom:Bool = false;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var wackyImage:FlxSprite;

	var titleJSON:TitleData;

	var curWacky:Array<String> = [];

	public static var updateVersion:String = '';

	var optionShortCut:FlxSprite;

	public var titleOptions:Bool = false;
	var bump:Bool = false;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		// DEBUG BULLSHIT

		curWacky = FlxG.random.getObject(getIntroTextShit());

		instance = this;

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		
		//FlxG.save.data.flashing == null && !FlashingState.leftState
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var bg:FlxSprite;
	var bg2:FlxSprite;
	var vignette:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.changeBPM(126);
		persistentUpdate = true;

		bg = new FlxSprite();

		bg.loadGraphic(Paths.image('title/background'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.alpha = 0;
		add(bg);

		bg2 = new FlxSprite();
		bg2.frames = Paths.getSparrowAtlas('title/background2');
		bg2.antialiasing = ClientPrefs.globalAntialiasing;
		bg2.animation.addByPrefix('anim', 'Símbolo 1', 60, true);
		bg2.animation.play('anim');
		bg2.screenCenter();
		bg2.alpha = 0;
		bg2.blend = MULTIPLY;
		add(bg2);

		vignette = new FlxSprite().loadGraphic(Paths.image('title/vignetteThings'));
		vignette.alpha = 0;
		add(vignette);

		chosenOne = new FlxSprite(0, 800).loadGraphic(Paths.image('title/chosenOne'));
		chosenOne.alpha = 0;
		chosenOne.antialiasing = ClientPrefs.globalAntialiasing;
		add(chosenOne);

		darkLord = new FlxSprite((FlxG.width / 2), 800).loadGraphic(Paths.image('title/darkLord'));
		darkLord.alpha = 0;
		darkLord.antialiasing = ClientPrefs.globalAntialiasing;
		add(darkLord);

		smite = new FlxSprite();
		smite.frames = Paths.getSparrowAtlas('title/thing');
		smite.antialiasing = ClientPrefs.globalAntialiasing;
		smite.animation.addByPrefix('do', 'yo', 24, true);
		smite.animation.play('do');
		smite.setGraphicSize(Std.int(smite.width * 0.8));
		smite.screenCenter();
		smite.alpha = 0;
		add(smite);

		logoBl = new FlxSprite(-1280, -55).loadGraphic(Paths.image('title/logo'));
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.45));
		add(logoBl);

		titleText = new FlxSprite().loadGraphic(Paths.image('title/startText'));
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.setGraphicSize(Std.int(titleText.width * 0.5));
		titleText.screenCenter();
		titleText.y += 200;
		titleText.alpha = 0;
		add(titleText);
		
		spikes1 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes1.y -= 60;
		spikes1.scrollFactor.set(0, 0);
		spikes1.flipY = true;
		add(spikes1);

		spikes2 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes2.y += 630;
		spikes2.scrollFactor.set(0, 0);
		add(spikes2);

		socialItems = new FlxTypedGroup<FlxSprite>();
		add(socialItems);

		for (i in 0...socialMedia.length)
		{
			var socialItem:FlxSprite = new FlxSprite(500, 650);
			socialItem.loadGraphic(Paths.image('title/' + socialMedia[i]));
			socialItem.ID = i;
			socialItem.x += i * 100;
			socialItem.alpha = 0;
			socialItem.setGraphicSize(Std.int(socialItem.width * 0.85));
			socialItems.add(socialItem);
			socialItem.antialiasing = ClientPrefs.globalAntialiasing;
		}

		optionShortCut = new FlxSprite(1200, 15).loadGraphic(Paths.image('title/optionsShortcut'));
		optionShortCut.alpha = 0;
		optionShortCut.setGraphicSize(Std.int(optionShortCut.width * 0.85));
		add(optionShortCut);
		optionShortCut.antialiasing = ClientPrefs.globalAntialiasing;

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSpriteExtra().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		alanSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('title/alanCursor'));
		add(alanSpr);
		alanSpr.visible = false;
		alanSpr.setGraphicSize(Std.int(alanSpr.width * 0.8));
		alanSpr.updateHitbox();
		alanSpr.screenCenter(X);
		alanSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		FlxG.watch.addQuick("beatShit", curBeat);

		for (i in 0...socialMedia.length)
		{
			if (socialItems != null)
			{
				checkIfClicked(socialItems.members[i], i);
			}
		}

		if(optionShortCut != null && FlxG.mouse.overlaps(optionShortCut) && FlxG.mouse.justPressed)
		{
			FlxG.sound.play(Paths.sound('mouseClick'));
			MusicBeatState.switchState(new options.OptionsState());
			titleOptions = true;
			bump = false;
			closedState = true;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
				bump = false;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if(pressedEnter)
			{
				titleText.alpha = 1;

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 0.7);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				FlxG.camera.shake(0.0045, 1);
				FlxTween.tween(FlxG.camera, {zoom: 3}, 1.5, {ease: FlxEase.expoIn});
				FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
				{
				    MusicBeatState.switchState(new MainMenuState());
					titleOptions = false;
					bump = false;
					doNotZoom = false;
				});

				FlxG.mouse.visible = false;
				closedState = true;
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if (initialized)
		{	
			spikes1.x -= 0.45 * 60 * elapsed;
			spikes2.x -= 0.45 * 60 * elapsed;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:FlxText = new FlxText(0, 0, FlxG.width, textArray[i], 48);
			money.setFormat("vcr.ttf", 48, FlxColor.WHITE, CENTER);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			money.alpha =  0.00001;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
				FlxTween.tween(money, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:FlxText = new FlxText(0, 0, FlxG.width, text, 48);
			coolText.setFormat("vcr.ttf", 48, FlxColor.WHITE, CENTER);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			coolText.alpha =  0.00001;
			FlxTween.tween(coolText, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if (!closedState && !doNotZoom) FlxTween.tween(FlxG.camera, {zoom:1.02}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
		if(!closedState && bump)
		{
			if (chosenOne != null)  FlxTween.tween(chosenOne, { y: -7.3 }, Conductor.crochet * 0.1000 * 2, { type: FlxTween.LOOPING, ease: FlxEase.quadInOut});
			if (darkLord != null)  FlxTween.tween(darkLord, { y: -7.3 }, Conductor.crochet * 0.1000 * 2, { type: FlxTween.LOOPING, ease: FlxEase.quadInOut});
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(['A lot of people'], 15);
				case 3:
					addMoreText('proudly presents...', 15);
				case 4:
					deleteCoolText();
					createCoolText(['A stickfigure mod'], 15);
				case 5:
					addMoreText('very cool huh?', 15);
				case 6:
					deleteCoolText();
					createCoolText(['el pepe'], 15);
				case 7:
					deleteCoolText();
					createCoolText(['Animation vs.'], 15);
				case 8:
					addMoreText('by: Alan Becker', 15);
					alanSpr.visible = true;
				case 9:
					alanSpr.visible = false;
					deleteCoolText();
					createCoolText(['Mod is meant to'], 15);
				case 10:
					addMoreText('be played with shaders', 15);
				case 11:
					deleteCoolText();
					createCoolText(['Timeline FNF'], 15);
				case 12:
					addMoreText('cool song', 15);
				case 13:
					deleteCoolText();
					createCoolText(['Guys sorry'], 15);
				case 14:
					addMoreText('for the 1 year waiting', 15);
				case 15:
					deleteCoolText();
					createCoolText(['so retro...'], 15);
				case 16:
					addMoreText('do you guys like this title screen?', 15);
				case 17:
					deleteCoolText();
					createCoolText(['you should also play'], 15);
				case 18:
					addMoreText('(insert mod name here)', 15);
				case 19:
					deleteCoolText();
					createCoolText(['idk what to put here'], 15);
				case 20:
					addMoreText('anymore :(((', 15);
				case 21:
					deleteCoolText();
					createCoolText([curWacky[0]]);
				case 22:
					addMoreText(curWacky[1]);
				case 23:
					deleteCoolText();
					createCoolText(['Vs. The Chosen One?'], 15);

			    case 24:
					addMoreText('More like...', 15);
				case 25:
					if (credGroup != null) remove(credGroup);
					if (logoBl != null) FlxTween.tween(logoBl, {x: 166}, 2, { type: FlxTween.ONESHOT, ease: FlxEase.backInOut});
				case 28:
					if(!skippedIntro)
						{
							doNotZoom = true;
							FlxTween.tween(FlxG.camera, {zoom: 0.7}, 3, {ease: FlxEase.backInOut, onComplete: function(tween:FlxTween){
								FlxG.camera.zoom = 1;
							}});
						}
				case 30:
					if(!skippedIntro) FlxG.cameras.fade(FlxColor.WHITE, 1, false);
				case 33:
					FlxG.cameras.fade(FlxColor.WHITE, 0, true);
					skipIntro();
					FlxG.camera.zoom = 1;
					if (darkLord != null) FlxTween.tween(darkLord, {y: 0}, 1, { type: FlxTween.ONESHOT, ease: FlxEase.backInOut, startDelay: 0.5});
					if (chosenOne != null) FlxTween.tween(chosenOne, {y: 0}, 1, { type: FlxTween.ONESHOT, ease: FlxEase.backInOut, startDelay: 0.5, onComplete: function(tween:FlxTween){
						//
					}});
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (playJingle) //Ignore deez
			{
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch(easteregg)
				{
					case 'RIVER':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHUBS':
						sound = FlxG.sound.play(Paths.sound('JingleShubs'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));

					default: //Go back to normal ugly ass boring GF
					    remove(alanSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 0.7);
						skippedIntro = true;
						playJingle = false;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if(easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
					});
				}
				else
				{
					remove(alanSpr);
					remove(credGroup);
					FlxG.camera.flash(FlxColor.WHITE, 0.7);
					sound.onComplete = function() {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
					};
				}
				playJingle = false;
			}
			else //Default! Edit this one!!
			{
				remove(alanSpr);
				if (credGroup != null) remove(credGroup);
				logoBl.screenCenter();
				FlxG.camera.flash(FlxColor.WHITE, 1.2);
				vignette.alpha = 1;
				bg.alpha = 1;
				bg2.alpha = 1;
				titleText.alpha = 1;
				smite.alpha = 1;
				FlxG.cameras.fade(FlxColor.WHITE, 0, true);
				FlxG.camera.zoom = 1;
				chosenOne.alpha = 1;
				darkLord.alpha = 1;
				chosenOne.y = 0;
				darkLord.y = 0;
				doNotZoom = false;

				socialItems.forEach(function(socialItem:FlxSprite) socialItem.alpha = 1);
				optionShortCut.alpha = 1;

				FlxG.mouse.visible = true;

				FlxG.mouse.load(Paths.image("EProcess/alt", 'chapter1').bitmap, 1.5, 0);

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if(easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
					if(FreeplayState.vocals != null)
					{
						FreeplayState.vocals.fadeOut();
					}
				}
				#end
			}
			skippedIntro = true;
		}
	}

	function checkIfClicked(object:FlxSprite, id:Int) //the tag is the thing used for the select void
	{
		if(!FlxG.mouse.justPressed) return;
		if(!FlxG.mouse.overlaps(object)) return;

		trace(object);

		FlxG.sound.play(Paths.sound('mouseClick'));

		switch(id)
		{
			case 0:
				CoolUtil.browserLoad('https://gamebanana.com/mods/340817');
			case 1:
				CoolUtil.browserLoad('https://x.com/Vs_TheChosenOne');
			case 2:
				CoolUtil.browserLoad('https://gamejolt.com/games/VsTheChosenOne/687592');
		}
	}
}
