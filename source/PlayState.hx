package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import DialogueScript;
import Conductor.Rating;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.text.FlxTypeText;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import lime.app.Application;


//0.5.1 shaders

import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import Shaders;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#else import vlc.MP4Handler; #end
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public static var timeTravelHP:Float;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camLYRICS:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camBars:FlxCamera;
	public var camChar:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;
	var ScriptdialogueJson:ScriptDialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var ratingTween:FlxTween;
	var comboTween:FlxTween;
	var numScoreTween:FlxTween;
	var judgementTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;
	var actualSongLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];
	
	//MOD THINGS LOL!!!!!!!!!!
	//week 1:
	    //adobe:
			var Crowd:BGSprite;
			var Background1:BGSprite;
			//var shine:BGSprite;
			var Floor:BGSprite;
			var spotlightdad:FlxSprite;
	        var spotlightbf:FlxSprite;
		
		
		//t.c.o:
			var ScaredCrowd:BGSprite;
			var redthing:FlxSprite;
			var fires1:BGSprite;
			var fires2:BGSprite;
			var extraFires:BGSprite;
			
			var bsod:BGSprite;
			var stickpage:BGSprite;
			var stickpageFloor:BGSprite;
			
			//lossing health mechanic
				var lossingHealth:Bool = false;
				var lossingHealthPlus:Bool = false;
		
		//end process:
			var newgroundsBurn:FlxSprite;
			var twitterBurn:FlxSprite;
			var googleBurn:FlxSprite;
			
			var virabot1:BGSprite;
			var virabot2:BGSprite;
			var virabot3:BGSprite;
			var virabot4:BGSprite;
			
			var endProcessChrom:Float = 0.0045;
			
			//corrupted bgs:
				var corruptBG:BGSprite;
				var corruptFloor:BGSprite;
				
			//bsod 2 and rsod + conflict bsod:
				var bsodStatic:BGSprite;
				var rsod:BGSprite;
				var confBsod:BGSprite;
			
			//Popup Mechanic:
				var popUp:FlxSprite;
				var closePopup:FlxSprite;
				public var popUpTimer:FlxTimer;
	
	//end
	
	//Old week 1:
	
	var oldCrowd:BGSprite;
	var oldScaredCrowd:BGSprite;
	var oldSongs:Bool = false; //for the song transition if is story mode
	
	//extras:
	
	    //Blank BG:
		    var whiteScreen:FlxSprite;
	    //trojan:
			var tscseeing:BGSprite;
			var alanBG:BGSprite;
			var daFloor:BGSprite;
			var adobeWindow:BGSprite;
			var sFWindow:BGSprite;
			var scroll:FlxBackdrop;
			var vignettMid:FlxSprite;
			
			//kaboom effect
			var angleshit = 1;
			var anglevar = 1;
			var intensity = 0;
			var intensity2 = 3;
			var kaboomEnabled:Bool = false;
			
			var dodged:Bool;
			var babyArrowCamGame:Bool = false;
			
			//public var trojanShader:Shaders.Glitch02Effect = new Glitch02Effect(8, 6, 3);
			public var testShader3D:Shaders.Test3DEffect = new Test3DEffect(); //fuck
			public var fishEyeShader:Shaders.FishEyeShader = new FishEyeShader(); //fuck
			
		//conflict:
			public var endingShader:Shaders.Glitch02Effect = new Glitch02Effect(4, 3, 3);
		//unfaithful:
			var unfaithFRONT:BGSprite;
			var unfaithBACK:BGSprite;
			var unfaithBG:FlxSprite;
			var colorShad:ColorSwap;
			var morbinTime:Bool = false;
			public var wavShader:Shaders.WavyV1Effect = new WavyV1Effect(8, 0.05);
			public var rainbowShader:Shaders.RainbowEffect = new RainbowEffect();
			var overlayUnfaith:BGSprite;
		
		//time travel:
			var brickfloor:FlxSprite;
			var theHOGOVERLAYOMG:BGSprite;
			public var nightTimeShader:Shaders.NightTimeEffect = new NightTimeEffect();
			
			public static var timeTraveled:Bool;
			public static var funnyArray:Array<Int>;
			public static var ratingPercentTT:Float;
			var textLyrics:FlxTypeText; //the dialog text
		
		//dashpulse:
			var otakuBG:BGSprite;
			public var NTSCshader:Shaders.NTSCEffect = new NTSCEffect(); //fuck
			
		//kickstarter:
			var bgKickstarter:BGSprite; //changed it to here becuse it gets dark later or something 
		    var leftSide:Bool = false;
			var overlayKick:BGSprite;
			
		//cubify:
		    var overlayCubify:BGSprite;
			
		//messenger:
		    var aolBG:BGSprite;
			var aolBack:BGSprite;
			var aolFloor:BGSprite;
			var particleEmitter:FlxEmitter;
			var veryEpicVignette:BGSprite;
			
		//tune in:
		    var bf2:Boyfriend = null;
			var bf3:Boyfriend = null;
			var iconP3:HealthIcon;
			var iconP4:HealthIcon;
			var songHasOtherPlayer:Bool = false;
			var songHasOtherPlayer2:Bool = false;
			var bf2Name:String = "";
			var bf3Name:String = "";
			var radialLine:BGSprite;
			var ytBG:BGSprite;
			var ytBGVideo:BGSprite;
			var videoTI:MP4Handler;
			var skipMoveCam:Bool = false;
			
		//rombie:
		    var rombieBecomesUncanny:BGSprite;
			var rombBG:BGSprite;
			public var distortShader:Shaders.DistortedTVEffect = new DistortedTVEffect();
			public var distortShaderHUD:Shaders.DistortedTVEffectHUD = new DistortedTVEffectHUD(); //fuck
			var zoomTweenStart:FlxTween;
			
		//enmity:
		    var tcoPlataform:BGSprite;
			var tcoPlataform2:BGSprite;
			var bfGfPlataform:BGSprite;
			
		//phantasm:
		    var controlDad:Bool = false;
			public var barDirection:FlxBarFillDirection = LEFT_TO_RIGHT;
			
		//aurora:
		    var auroraLight:BGSprite;
			var auroraTrees:BGSprite;
			
	//end
	
	//Misc. things:
	
	var tweenZoomEvent:FlxTween;
	var LightsColors:Array<FlxColor>; //for the vignette changing color
	public var oldVideoResolution:Bool = false; // simulate 4:3 resolution like Alan old videos
	var judgementCounter:FlxText; //the combo counter that appears in the left of your screen
	var needsBlackBG:Bool = false; //for songs that need to have a black bg (not hiding bf or dad)
	
	var textNoTween:FlxText; //the dialog text (no tween)
	
	var bestPart:Bool = false;
	var bestPart2:Bool = false; //VIGNETTES HANDLER
	
	var noCurLight:Bool = false;
	
	var blackBG:FlxSprite; //the bg for the needblackbg bool
	
	var ondaCutscene:Bool = false; //handler so  player can't use the arrows
	
	public static var amityChar:String;
	
		//sonic.exe mod beat zooms type:
			var zoomType1:Bool = false;
			var zoomType2:Bool = false;
			var zoomType3:Bool = false;
			
		//cutscene shit
			var topBars:FlxSprite;
			var bottomBars:FlxSprite;
			
			var topBarsALT:FlxSprite; //THESE ONES AREN'T THE ONES WITH TWEEN
			var bottomBarsALT:FlxSprite; //THIS TOO
			
		//vignettes type:
		    var vignetteTrojan:FlxSprite; //USED IN TROJAN AND OTHER COOL SONGS
			var coolShit:FlxSprite; //USED IN TROJAN AND OTHER COOL SONGS
			var vignetteSTI:BGSprite; //USED IN ADOBE
			
		//things from the 0.5.1
		public var camGameShaders:Array<ShaderEffect> = [];
		public var camHUDShaders:Array<ShaderEffect> = [];
		public var camOtherShaders:Array<ShaderEffect> = [];
		public var shaderUpdates:Array<Float->Void> = [];
	
	var resW:Int = FlxG.width;
	var resH:Int = FlxG.height;
	public static var weekNames:String = "";

	//special game over
	public var gameOverType:String = 'default';
	public var countDownType:String = 'default';

	//custom health bars wowie
	public var uiType:String = 'default';

	//thingyyyy for the uhh stop using shaders thing
	var timeWithLowerFps:Float;
	var laggyText:FlxText;

	//tdl note
	var slashing:Bool = false;

	//demonetization note
	var strikes:Int = 0;
	var strikesTxt:FlxText;

	//trying to do events for dashpulse
	var notesFunny1:Array<Bool> = [false, false];
	var normalThingOrShit:Array<Float> = [];

	//remove the lyrics
	var lyricsDestroyTimer:FlxTimer;
	var textTween:FlxTween;
	var textTweenAlpha:FlxTween;

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camLYRICS = new FlxCamera();
		camOther = new FlxCamera();
		camBars = new FlxCamera();
		camChar = new FlxCamera();
		
		camHUD.bgColor.alpha = 0;
		camLYRICS.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camBars.bgColor.alpha = 0;
		camChar.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		
		if (SONG.song.toLowerCase() == 'amity' || SONG.song.toLowerCase() == 'trojan') FlxG.cameras.add(camChar, false);
		
		FlxG.cameras.add(camBars, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camLYRICS, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('practice time');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + weekNames;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				case 'amity':
					SONG.player1 = amityChar; //ni idea de por qué no funciona
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 0
				{
					var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
					add(bg);
					
					var stageFront:BGSprite = new BGSprite('stagefront', -650, 200, 0.9, 0.9);
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					add(stageFront);
					
					if (!ClientPrefs.lowQuality) {
						var stageLight:BGSprite = new BGSprite('stage_thing', -125, 10, 0.9, 0.9);
						stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
						stageLight.updateHitbox();
						add(stageLight);
						var stageLight:BGSprite = new BGSprite('stage_thing', 1225, 10, 0.9, 0.9);
						stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
						stageLight.updateHitbox();
						stageLight.flipX = true;
						add(stageLight);
						
						var stageCurtains:BGSprite = new BGSprite('stagecurtains', -700, -100, 1.3, 1.3);
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 1.2));
						stageCurtains.updateHitbox();
						add(stageCurtains);
					}
					
					topBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					add(bottomBars);
					
					needsBlackBG = true;
					
					if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(new BloomShader())]);
				}
				
			case 'adobe': //Week 1
				{
					defaultCamZoom = 0.7;
					
					whiteScreen = new FlxSpriteExtra(0, 0).makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					whiteScreen.scrollFactor.set();
					whiteScreen.screenCenter();
					add(whiteScreen);
					
					Background1 = new BGSprite('bg', 'chapter1', -600, -600, 0.9, 0.9);
					//Background1.setGraphicSize(Std.int(Background1.width * 1.1));
					Background1.antialiasing = ClientPrefs.globalAntialiasing;
					add(Background1);
					
					whiteScreen.color = Background1.color;
					
					/*shine = new BGSprite('shine', 'chapter1', 0, 0, 1, 1);
					shine.screenCenter();*/
				
					switch(SONG.song.toLowerCase())
					{
						case 'adobe':
							
							noCurLight = true;
							
							Crowd = new BGSprite('theBGGuyz', 'chapter1', -400, 7, 0.95, 0.95, ['BG  Guys']);
							Crowd.setGraphicSize(Std.int(Crowd.width * 1.1));
							Crowd.updateHitbox();
							Crowd.antialiasing = ClientPrefs.globalAntialiasing;
							add(Crowd);
							
                            spotlightdad = new FlxSprite();
                            spotlightdad.loadGraphic(Paths.image("LSEspotlight"));
                            spotlightdad.alpha = 0;

                            spotlightbf = new FlxSprite();
                            spotlightbf.loadGraphic(Paths.image("LSEspotlight"));
                            spotlightbf.alpha = 0;
							
							LightsColors = [0xFFE5BE01, 0xFF00AAE4, 0xFF76BD17, 0xFFFF0000, 0xFFFF8000];
							
							vignetteSTI = new BGSprite('STIvignette', 'chapter1', -650, -500, 0.9, 0.9);
							vignetteSTI.cameras = [camHUD];
							vignetteSTI.screenCenter();
							vignetteSTI.alpha = 0;
							add(vignetteSTI);
							
							if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(0.0005));
					
						case 'outrage' | 'phantasm':
							
							if(songName == 'outrage') addCharacterToList('stick-bf', 0);
							
							FlxG.camera.fade(FlxColor.BLACK, 0, false);
							
							fires1 = new BGSprite('victim/BGFire', 'chapter1', 870, -240, 0.9, 0.9, ['Symbol 1 instance 1'], true);
							fires1.setGraphicSize(Std.int(fires1.width * 1.4));
							fires1.visible = false;
							add(fires1);
							
							extraFires = new BGSprite('victim/BGFire', 'chapter1', 1370, -240, 0.9, 0.9, ['Symbol 1 instance 1'], true);
							extraFires.setGraphicSize(Std.int(extraFires.width * 1.4));
							extraFires.visible = false;
						
							fires2 = new BGSprite('victim/BGFire', 'chapter1', -1600, -240, 0.9, 0.9, ['Symbol 1 instance 1'], true);
							fires2.setGraphicSize(Std.int(fires2.width * 1.4));
							fires2.visible = false;
							add(fires2);
							
							stickpage = new BGSprite('victim/distorted_stickpage_bg', 'chapter1', -650, -500, 0.9, 0.9);
							stickpage.setGraphicSize(Std.int(stickpage.width * 1.1));
							stickpage.alpha = 0;
							
							stickpageFloor = new BGSprite('victim/dsp_floor', 'chapter1', -750, -360, 1, 1);
							stickpageFloor.setGraphicSize(Std.int(stickpageFloor.width * 1.2));
							stickpageFloor.screenCenter();
							stickpageFloor.alpha = 0;

							ScaredCrowd = new BGSprite('theBGGuyz', 'chapter1', -400, 200, 0.95, 0.95, ['BG Guys Scared'], true);
							ScaredCrowd.setGraphicSize(Std.int(ScaredCrowd.width * 1.1));
							ScaredCrowd.antialiasing = ClientPrefs.globalAntialiasing;
							if(songName == 'outrage') add(ScaredCrowd);
							
							bsod = new BGSprite('victim/error', 'chapter1', -650, -500, 1, 1);
							bsod.setGraphicSize(Std.int(bsod.width * 1.1));
							bsod.antialiasing = ClientPrefs.globalAntialiasing;
							if (ClientPrefs.shaders) bsod.shader = new CRTShader();
							bsod.alpha = 0;
							
							redthing = new FlxSprite(0, 0).loadGraphic(Paths.image('victim/vignette', 'chapter1'));
							redthing.antialiasing = ClientPrefs.globalAntialiasing;
							redthing.cameras = [camOther];
							redthing.alpha = 0;
							add(redthing);
							
							needsBlackBG = true;
							
						
						case 'end process':
							
							FlxG.mouse.visible = true;
							FlxG.mouse.unload();
							FlxG.mouse.load(Paths.image("EProcess/alt", 'chapter1').bitmap, 1.5, 0);
						
							fires1 = new BGSprite('victim/BGFire', 'chapter1', 870, -240, 0.9, 0.9, ['Symbol 1 instance 1'], true);
							fires1.setGraphicSize(Std.int(fires1.width * 1.4));
							add(fires1);
						
							fires2 = new BGSprite('victim/BGFire', 'chapter1', -1500, -240, 0.9, 0.9, ['Symbol 1 instance 1'], true);
							fires2.setGraphicSize(Std.int(fires2.width * 1.4));
							add(fires2);
							
					    	virabot1 = new BGSprite('EProcess/virabop', 'chapter1', -50, 455, 0.9, 0.9, ['ViraBop']);
							virabot1.setGraphicSize(Std.int(virabot1.width * 1.3));
					    	add(virabot1);
							
					    	virabot4 = new BGSprite('EProcess/virabop', 'chapter1', -650, 455, 0.9, 0.9, ['ViraBop']);
							virabot4.setGraphicSize(Std.int(virabot1.width * 1.3));
					    	add(virabot4);
					
					    	virabot2 = new BGSprite('EProcess/virabop', 'chapter1', 1250, 455, 0.9, 0.9, ['ViraBop']);
							virabot2.setGraphicSize(Std.int(virabot2.width * 1.3));
							virabot2.flipX = true;
					   	 	add(virabot2);
	
					    	virabot3 = new BGSprite('EProcess/virabop', 'chapter1', 1750, 455, 0.9, 0.9, ['ViraBop']);
							virabot3.setGraphicSize(Std.int(virabot3.width * 1.3));
							virabot3.flipX = true;
					    	add(virabot3);
							
							googleBurn = new FlxSprite(0, -100);
							googleBurn.frames = Paths.getSparrowAtlas('EProcess/GoogleBurning', 'chapter1');
							googleBurn.animation.addByPrefix('idle', 'Symbol 2 instance 10', 16, true);
							googleBurn.animation.play('idle');
							googleBurn.scale.set(0.7, 0.7);
							googleBurn.screenCenter();
							googleBurn.x += 250;
							googleBurn.angle = -4;
							add(googleBurn);
							//FlxTween.tween(googleBurn, {y: googleBurn.y + 30}, 1, {ease:FlxEase.smoothStepInOut, type: PINGPONG});
							FlxTween.angle(googleBurn, googleBurn.angle, 4, 2, {ease: FlxEase.quartInOut, type: PINGPONG});
							
							twitterBurn = new FlxSprite(1300, -320); //thank to god the most toxic social media is on fire
							twitterBurn.frames = Paths.getSparrowAtlas('EProcess/TwitterBurning', 'chapter1');
							twitterBurn.animation.addByPrefix('idle', 'Symbol 4 instance 10', 16, true);
							twitterBurn.animation.play('idle');
							twitterBurn.scale.set(0.7, 0.7);
							twitterBurn.angle = -4;
							add(twitterBurn);
							//FlxTween.tween(twitterBurn, {y: twitterBurn.y + 30}, 1, {ease:FlxEase.smoothStepInOut, type: PINGPONG});
							FlxTween.angle(twitterBurn, twitterBurn.angle, 4, 2, {ease: FlxEase.quartInOut, type: PINGPONG});
							
							newgroundsBurn = new FlxSprite(-1000, 220);
							newgroundsBurn.frames = Paths.getSparrowAtlas('EProcess/NewgroundsBurning', 'chapter1');
							newgroundsBurn.animation.addByPrefix('idle', 'Symbol 3 instance 10', 16, true);
							newgroundsBurn.animation.play('idle');
							newgroundsBurn.scale.set(0.7, 0.7);
							newgroundsBurn.angle = -4;
							add(newgroundsBurn);
							//FlxTween.tween(newgroundsBurn, {y: newgroundsBurn.y + 30}, 1, {ease:FlxEase.smoothStepInOut, type: PINGPONG});
							FlxTween.angle(newgroundsBurn, newgroundsBurn.angle, 4, 2, {ease: FlxEase.quartInOut, type: PINGPONG});
							
							corruptBG = new BGSprite('bgCorrupted', 'chapter1', -650, -600, 0.9, 0.9);
							corruptBG.setGraphicSize(Std.int(corruptBG.width * 1.1));
							corruptBG.color = 0xFF7B6CAD;
							corruptBG.alpha = 0;
							if (ClientPrefs.shaders) corruptBG.shader = new CRTShader();
			
							corruptFloor = new BGSprite('floorCorrupted', 'chapter1', -750, -405, 1, 1);
							corruptFloor.setGraphicSize(Std.int(corruptFloor.width * 1.2));
							corruptFloor.color = 0xFF7B6CAD;
							corruptFloor.alpha = 0;
							if (ClientPrefs.shaders) corruptFloor.shader = new CRTShader();
			
							bsodStatic = new BGSprite('EProcess/error_3rdsong', 'chapter1', -650, -500, 1, 1);
							bsodStatic.setGraphicSize(Std.int(bsodStatic.width * 1.1));
							bsodStatic.antialiasing = ClientPrefs.globalAntialiasing;
							bsodStatic.alpha = 0;
							if (ClientPrefs.shaders) bsodStatic.shader = new CRTShader();
							
							rsod = new BGSprite('EProcess/rsod', 'chapter1', -650, -500, 1, 1);
							rsod.setGraphicSize(Std.int(rsod.width * 1.1));
							rsod.antialiasing = ClientPrefs.globalAntialiasing;
							rsod.alpha = 0;
							if (ClientPrefs.shaders) rsod.shader = new CRTShader();
						
							FlxG.camera.fade(FlxColor.BLACK, 0, false);
							
							//chromHandler = 0.0045;
						    if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(endProcessChrom));
					}
					
					Floor = new BGSprite('floor', 'chapter1', -750, -360, 1, 1);
					Floor.setGraphicSize(Std.int(Floor.width * 1.2));
					add(Floor);
					
					topBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					add(bottomBars);	
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camBars];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					if(SONG.song.toLowerCase() != 'end process') topBarsALT.alpha = 0;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camBars];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					if(SONG.song.toLowerCase() != 'end process') bottomBarsALT.alpha = 0;
					add(bottomBarsALT);
					
					if (songName == 'phantasm') defaultCamZoom = 1.8;
					
					oldSongs = false;
					
				}
				
			case 'alan': //Freeplay Song.
				{
					whiteScreen = new FlxSpriteExtra(0, 0).makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					whiteScreen.scrollFactor.set();
					whiteScreen.screenCenter();
					add(whiteScreen);
					
					needsBlackBG = true;
				}
				
			case 'whiteSpace': //Placeholder
				{
					whiteScreen = new FlxSpriteExtra(0, 0).makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					whiteScreen.scrollFactor.set();
					whiteScreen.screenCenter();
					add(whiteScreen);
				}
				
			case 'kickstarter': //kickstart
				{
					bgKickstarter = new BGSprite('win7/Windows7_Bg', -30, 0, 0.9, 0.9);
					bgKickstarter.setGraphicSize(Std.int(bgKickstarter.width * 1.5));
					bgKickstarter.screenCenter();
					add(bgKickstarter);
					
					var solitarie:BGSprite = new BGSprite('win7/solitaire_floor', -30, 0, 1, 1);
					solitarie.setGraphicSize(Std.int(solitarie.width * 2));
					solitarie.screenCenter();
					solitarie.y += 500;
					solitarie.antialiasing = false;
					add(solitarie);
					
					overlayKick = new BGSprite('win7/overlay', 0, 0, 1, 1);
					overlayKick.setGraphicSize(Std.int(overlayKick.width * 1.5));
					overlayKick.screenCenter();

					topBars = new FlxSpriteExtra().makeSolid(2700, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					topBars.x -= 10;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2700, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					bottomBars.x -= 10;
					add(bottomBars);

					camBars.x += 0.5;

					
					leftSide = true;
					
						if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(nightTimeShader.shader)]);
						//if (ClientPrefs.shaders) camHUD.setFilters([new ShaderFilter(nightTimeShader.shader)]);
				}
				
			case 'rombieBG': //the joe rombie is real
				{
					camZooming = true;
					rombBG = new BGSprite('rombie/rombie_bg', -1050 , -1140, 1, 1);
					rombBG.setGraphicSize(Std.int(rombBG.width * 1.2));
					rombBG.antialiasing = ClientPrefs.globalAntialiasing;
					add(rombBG);
					
					/*
				⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠄⢠⡾⢳⣿⣿⠿⠦⣤⣼⠿⠿⠆⣰⣿⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠀⠀⠀⠀⣰⢉⣠⣿⠶⠋⠁⠀⠀⠀⠀⠀⠀⠠⠤⠤⠬⠙⠳⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠀⠀⠀⢀⡗⣰⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢉⣉⣒⡚⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠀⠀⠀⢸⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠤⠒⠊⠉⢁⡀⠀⠉⠙⢿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠀⠀⢀⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠀⠀⠀⠀⠈⠀⠀⠀⠀⠈⠻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠀⡴⡾⠀⠀⠀⠀⠀⣀⡠⠄⠒⠉⠁⣠⡇⠀⠀⠀⠀⣼⣾⣿⣿⡿⠦⣄⢹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⢰⢻⡇⠀⠀⠀⡠⠊⠁⠀⢀⣠⣴⣿⠟⡀⠀⠀⠀⢠⣿⣿⣿⢿⡀⠀⠈⢻⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⣿⣾⠃⠀⣠⠎⠀⣠⣴⣾⠿⣿⡿⠃⠀⢣⠀⠀⠀⢸⣿⣿⠿⠻⣿⣆⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⢰⣫⣾⠀⠀⢁⣴⣾⣿⠿⠾⠻⠻⠅⠀⠀⠘⡆⠀⠀⣿⣿⣿⣀⣀⣨⣿⡄⠀⢹⡇⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⢸⢺⡿⠀⣠⣿⡷⢟⡥⢶⣾⣿⡝⢺⡄⠀⠀⢧⠀⠀⣿⣿⣿⣿⣿⡏⠙⣷⠀⡘⣷⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⢸⠀⡇⢰⡯⠋⡀⠙⠤⣘⠿⠿⢃⡿⠁⠀⠀⣽⠀⠀⣿⣿⣿⡟⠿⠥⠴⠋⢰⡏⢻⡆⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠸⠸⡇⠀⠀⡀⠈⠓⠒⠲⠒⠚⠉⠀⢰⡿⢤⢹⠀⠀⣿⣿⣿⠁⠠⠤⠤⠞⠋⢀⣼⣿⣷⣄⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⢰⡇⠀⠀⠈⠓⠦⠤⠴⠂⠀⠀⡴⢹⠁⠀⢹⠀⠀⣿⣿⣿⠀⠀⠀⠀⣀⠴⠚⢻⣿⣿⣿⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⣼⠁⢀⠀⠀⠀⠀⣠⣀⣶⡴⠋⠁⠸⠶⣤⣄⣀⣀⣿⣿⣿⠀⣄⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀
				⣧⠀⠀⣸⢻⠀⠸⡄⠀⠰⢿⡟⠛⠙⠦⣀⠀⠀⠀⠀⠉⠻⣿⣿⣿⣿⡀⠈⣻⣷⣦⠀⠀⢸⢿⣿⡿⠀⠀⠀⠀⠀
				⠘⠦⣄⣧⡏⠀⠀⣇⠀⠀⠸⠀⠀⠀⠀⠀⠉⠑⠒⠤⠤⠤⠤⠭⠽⠿⠗⠒⠻⠧⡛⠀⠀⢸⢸⣿⠁⠀⠀⠀⠀⠀
				⠀⠀⠀⣹⠉⠀⠀⠼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡄⠀⢸⠸⣿⠀⠀⠀⠀⠀⠀
				⠀⠀⢀⡇⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡀⠀⠀⢿⡆⠀⠀⠀⠀⠀
				⠀⠀⢸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡇⠀⠀⢸⡇⠀⠀⠀⠀⠀
⠀				⠀⠜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀
⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣆⠀⠀⠀⠀
				⠀⠀⠀⠘⢦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢰⠇⠿⡄⠀⠀⠀
⠀				⠀⠀⠀⠈⢷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡟⠈⣴⠏⠹⣆⠀⠀
				⠀⠀⠀⠀⠀⠀⠙⠶⣴⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣴⣿⣧⣾⣿⡇⠀⠘⢦⡀ */
				
					

					whiteScreen = new FlxSpriteExtra(0, 0).makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					whiteScreen.scrollFactor.set();
					whiteScreen.screenCenter();
					whiteScreen.alpha = 0;
					add(whiteScreen);
					
					topBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					add(bottomBars);	
					
					if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(distortShader.shader)]);
					if (ClientPrefs.shaders) camHUD.setFilters([new ShaderFilter(distortShaderHUD.shader)]);
					
					oldVideoResolution = true;

					skipCountdown = true;
					
				}
				
			case 'cubify-stage':
				{
					var bg:BGSprite =  new BGSprite('cubify/cubify_bg', 0 , 0, 1, 1);
					bg.setGraphicSize(Std.int(bg.width * 1.2));
					bg.screenCenter();
					add(bg);
					
					overlayCubify =  new BGSprite('cubify/overlay', 0 , 0, 1, 1);
					overlayCubify.setGraphicSize(Std.int(overlayCubify.width * 1.2));
					overlayCubify.screenCenter();
					
					whiteScreen = new FlxSpriteExtra(0, 0).makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					whiteScreen.scrollFactor.set();
					whiteScreen.screenCenter();
					whiteScreen.alpha = 0;
					add(whiteScreen);
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camBars];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camBars];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
					
				}
				
			case 'garden':
				{
					
					var bg:BGSprite =  new BGSprite('amity-bg', 0 , 0, 1, 1);
					bg.setGraphicSize(Std.int(bg.width * 2.5));
					bg.screenCenter();
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camBars];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camBars];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
					
					if (songName == 'amity')
					{
						FlxG.camera.fade(FlxColor.BLACK, 0, false);
						camHUD.alpha = 0;
					}
					
					needsBlackBG = true;
					
					
					if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(nightTimeShader.shader), new ShaderFilter(new BBPANZUBloomShader())]);
				}
				
			case 'bbpanzu-stage': //bbpanzu stickfigure
				{
					otakuBG = new BGSprite('dashpulse_bg', 0 , 0, 1, 1);
					otakuBG.setGraphicSize(Std.int(otakuBG.width * 2.2));
					otakuBG.screenCenter();
					otakuBG.x -= 150;
					otakuBG.antialiasing = false;
					add(otakuBG);
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camBars];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camBars];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
					
					vignetteTrojan = new FlxSprite(0, 0).loadGraphic(Paths.image('trojan/vignette', 'extras'));
					vignetteTrojan.antialiasing = ClientPrefs.globalAntialiasing;
					vignetteTrojan.cameras = [camOther];
					vignetteTrojan.scale.set(0.7, 0.7);
					vignetteTrojan.screenCenter();
					vignetteTrojan.alpha = 0;
					vignetteTrojan.color = FlxColor.CYAN;
					//vignetteTrojan.blend = LIGHTEN;
					add(vignetteTrojan);
					
					oldVideoResolution = true;
					noCurLight = true;
					cameraSpeed = 1.2;
					if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(new CRTShader()), new ShaderFilter(NTSCshader.shader)]);
					if (ClientPrefs.shaders) camHUD.setFilters([new ShaderFilter(new CRTShader())]);
				}
			
			case 'alan-pc-virabot': //Virabot song
				{
					LightsColors = [0xFFE5BE01, 0xFF00AAE4, 0xFF76BD17, 0xFFFF0000, 0xFFFF8000];
					
					alanBG = new BGSprite('trojan/alan_desktop', -80, -1800, 1, 1);
					alanBG.setGraphicSize(Std.int(alanBG.width * 1.5));
					//if (ClientPrefs.shaders) alanBG.shader = new FishEyeShader();
					
					adobeWindow = new BGSprite('trojan/XD', -80, -1800, 1, 1);
					adobeWindow.setGraphicSize(Std.int(adobeWindow.width * 2));
					adobeWindow.screenCenter();
					adobeWindow.y -= 900;
					adobeWindow.x += 1500;
					
					//if (ClientPrefs.shaders) adobeWindow.shader = new FishEyeShader();
					
					sFWindow = new BGSprite('trojan/stickFightwindow', -80, -1800, 1, 1);
					sFWindow.screenCenter();
					sFWindow.y -= 900;
					sFWindow.x += 900;
					sFWindow.setGraphicSize(Std.int(sFWindow.width * 1.5));
					//if (ClientPrefs.shaders) sFWindow.shader = new FishEyeShader();
					
					daFloor = new BGSprite('trojan/floor', -80, -1800, 1, 1);
					daFloor.screenCenter();
					daFloor.y += 28;
					daFloor.x += 2300;

					tscseeing = new BGSprite('trojan/turi', 0, 0, 1, 1, ['turi']);
					tscseeing.setGraphicSize(Std.int(tscseeing.width * 0.9));
					tscseeing.screenCenter();
					tscseeing.updateHitbox();
					tscseeing.x += 2500;
					tscseeing.y += 180;
					tscseeing.antialiasing = ClientPrefs.globalAntialiasing;
					
					
					topBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					add(bottomBars);
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camBars];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camBars];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
					
					vignetteTrojan = new FlxSprite(0, 0).loadGraphic(Paths.image('trojan/vignette', 'extras'));
					vignetteTrojan.antialiasing = ClientPrefs.globalAntialiasing;
					vignetteTrojan.cameras = [camBars];
					vignetteTrojan.scale.set(0.7, 0.7);
					vignetteTrojan.screenCenter();
					vignetteTrojan.alpha = 0;
					//vignetteTrojan.blend = LIGHTEN;
					add(vignetteTrojan);
					
					coolShit = new FlxSprite(0, 0).loadGraphic(Paths.image('trojan/cool', 'extras'));
					coolShit.antialiasing = ClientPrefs.globalAntialiasing;
					coolShit.cameras = [camBars];
					coolShit.scale.set(20, 20);
					coolShit.screenCenter();
					coolShit.alpha = 0;
					//coolShit.blend = LIGHTEN;
					add(coolShit);
					
					add(alanBG);
					add(adobeWindow);
					add(sFWindow);
					add(daFloor);
					add(tscseeing);
					
					particleEmitter = new FlxEmitter(0, 1000);
                    particleEmitter.launchMode = FlxEmitterMode.SQUARE;
                    particleEmitter.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
                    particleEmitter.scale.set(2, 2, 2, 2, 0, 0, 0, 0);
                    particleEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
                    particleEmitter.width = 2787.45;
                    //particleEmitter.alpha.set(0, 0);
                    particleEmitter.lifespan.set(1.9, 4.9);
					
                    particleEmitter.loadParticles(Paths.image('particle'), 500, 16, true);
					particleEmitter.color.set(FlxColor.YELLOW, FlxColor.YELLOW);

                    particleEmitter.start(false, FlxG.random.float(.01097, .0308), 1000000);
                    add(particleEmitter);
					
					scroll = new FlxBackdrop(Paths.image('trojan/scrollmidsong', 'extras'), XY, 0, 0);
					scroll.setGraphicSize(Std.int(scroll.width * 0.8));
					scroll.cameras = [camChar];
					add(scroll);
					
					vignettMid = new FlxSprite(0, 0).loadGraphic(Paths.image('trojan/vignettemidsong', 'extras'));
					vignettMid.antialiasing = ClientPrefs.globalAntialiasing;
					vignettMid.cameras = [camChar];
					add(vignettMid);
					
					//for (i in 0...4) babyArrowBG = new StrumNote(0,  0, i, playerHandler);
					//babyArrowBG.screenCenter();
					//opponentStrums.add(babyArrowBG);
					
					//strumLineNotes.add(babyArrowBG);
					//babyArrowBG.postAddedToGroup();
					
					/*if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(trojanShader.shader), new ShaderFilter(new FishEyeShader())]);
			        if (ClientPrefs.shaders) camHUD.setFilters([new ShaderFilter(trojanShader.shader)]);*/
					
				}
				
			case 'alan-pc-conflict': //Alt for conflict song.
				{				
					alanBG = new BGSprite('trojan/alan_desktop', -80, -1800, 1, 1);
					alanBG.setGraphicSize(Std.int(alanBG.width * 1.5));
					
					daFloor = new BGSprite('trojan/floor', -80, -1800, 1, 1);
					daFloor.screenCenter();
					daFloor.y += 28;
					daFloor.x += 2300;
					
					fires1 = new BGSprite('victim/BGFire', 'chapter1', 1230, -240, 0.9, 0.9, ['Symbol 1 instance 1'], true);
					fires1.setGraphicSize(Std.int(fires1.width * 1.6));
						
					fires2 = new BGSprite('victim/BGFire', 'chapter1', -400, -240, 0.9, 0.9, ['Symbol 1 instance 1'], true);
					fires2.setGraphicSize(Std.int(fires2.width * 1.6));
					
				    bsod = new BGSprite('error_conflict', 'extras', 0, 0, 1, 1);
					bsod.setGraphicSize(Std.int(bsod.width * 1.25));
					bsod.screenCenter();
					bsod.x += 1250;
					bsod.antialiasing = ClientPrefs.globalAntialiasing;
					bsod.alpha = 0;
					
					redthing = new FlxSprite(0, 0).loadGraphic(Paths.image('victim/vignette', 'chapter1'));
					redthing.antialiasing = ClientPrefs.globalAntialiasing;
					redthing.cameras = [camBars];
					add(redthing);
					
					topBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2580, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					add(bottomBars);
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camBars];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camBars];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
							
					if (ClientPrefs.shaders) bsod.shader = new CRTShader();
					
                    if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(0.0045));
					
					needsBlackBG = true;
					
					add(alanBG);
					add(fires1);
					add(fires2);
					add(daFloor);
					add(bsod);
					
				}
				
			case 'alan-pc-song': //Alt for alan song.
				{				
					alanBG = new BGSprite('trojan/alan_desktop', -150, -1800, 1, 1);
					alanBG.setGraphicSize(Std.int(alanBG.width * 1.5));
					
					daFloor = new BGSprite('trojan/floor', -80, -1800, 1, 1);
					daFloor.screenCenter();
					daFloor.y += 28;
					daFloor.x += 2300;
					
					adobeWindow = new BGSprite('trojan/XD', -80, -1800, 1, 1);
					adobeWindow.setGraphicSize(Std.int(adobeWindow.width * 2));
					adobeWindow.screenCenter();
					adobeWindow.y -= 900;
					adobeWindow.x += 1500;
					
					needsBlackBG = true;
					
					
					add(alanBG);
					add(daFloor);
					add(adobeWindow);
					
				}
				
			case 'contrivance': //Contrivance song
				{
					var bg:BGSprite = new BGSprite('contrivance_bg', -800, -500, 1, 1);
					//bg.screenCenter();
					bg.updateHitbox();
					add(bg);

					topBars = new FlxSpriteExtra().makeSolid(2700, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					topBars.x -= 10;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2700, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					bottomBars.x -= 10;
					add(bottomBars);

					camBars.x += 0.5;
					
					if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(0.0008));
				}
				
			case 'yt': //YT song
				{
					ytBG = new BGSprite('yt_bg', 0, 0, 1, 1);
					ytBG.setGraphicSize(Std.int(ytBG.width * 1.5));
					ytBG.screenCenter();
					ytBG.updateHitbox();
					if (ClientPrefs.shaders) ytBG.shader = new CRTShader();
					add(ytBG);

					ytBGVideo = new BGSprite('yt_bg', 500, 0, 1, 1);
					ytBGVideo.setGraphicSize(Std.int(ytBGVideo.width * 1.5));
					ytBGVideo.alpha = 0;
					add(ytBGVideo);

					precacheList.set('tunein_vidbg', 'video');
					
					redthing = new FlxSprite(0, 0).loadGraphic(Paths.image('victim/vignette', 'chapter1'));
					redthing.antialiasing = ClientPrefs.globalAntialiasing;
					redthing.cameras = [camOther];
					redthing.color = 0xFFD13C21;
					add(redthing);
					
					if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(0.0015));
					
					songHasOtherPlayer = true;
					songHasOtherPlayer2 = true;
					bf2Name = "tsc-yt";
					bf3Name = "green-yt";
					
					var char:Character = boyfriend;
					
					GameOverSubstate.characterName = 'yt-gameover';
					GameOverSubstate.deathSoundName = 'tsc_green_loss_sfx';
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camHUD];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camHUD];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
					
					/*radialLine = new BGSprite('radial line', 'extras', 0, 0, 1, 1, ['Símbolo 2'], true);
					radialLine.cameras = [camHUD];
					radialLine.screenCenter();
					add(radialLine);
					radialLine.alpha = 0;*/
					
					if(CoolUtil.difficultyString() == 'INSANE'){
						strikesTxt = new FlxText(0, 0, FlxG.width, "Strikes: 0", 20);
						strikesTxt.setFormat(Paths.font("phantommuff.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						strikesTxt.borderSize = 2;
						strikesTxt.visible = !ClientPrefs.hideHud;
						strikesTxt.cameras = [camHUD];
						add(strikesTxt);
					}
				}
				
			case 'carykh': //CARYKH
				{	
					gameOverType = 'Time Travel';
					countDownType = 'Time Travel';

					var bg:BGSprite = new BGSprite('time-travel/timetravel_bg', 0, 0, 0.9, 0.9);
					bg.screenCenter();
					bg.setGraphicSize(Std.int(bg.width * 1.2));
					bg.updateHitbox();
					bg.x -= 150;
					add(bg);
					
					brickfloor = new FlxSprite( -450, 280).loadGraphic(Paths.image('time-travel/timetravel_floor'));
					brickfloor.setGraphicSize(Std.int(brickfloor.width * 1.5));
					//brickfloor.screenCenter();
					brickfloor.updateHitbox();
					//brickfloor.x -= 800;
					//brickfloor.x += 700;
					//brickfloor.blend = ADD;
					if (ClientPrefs.shaders) brickfloor.shader = new Shader3D();
					add(brickfloor);
					
					theHOGOVERLAYOMG = new BGSprite('time-travel/overlay', -800, -300, 1.1, 0.9);
                	theHOGOVERLAYOMG.scale.x = 1.25;
                	theHOGOVERLAYOMG.scale.y = 1.25;
					theHOGOVERLAYOMG.blend = LIGHTEN;
					theHOGOVERLAYOMG.alpha = 0;

					topBars = new FlxSpriteExtra().makeSolid(2700, 320, FlxColor.BLACK);
					topBars.cameras = [camBars];
					topBars.screenCenter();
					topBars.y -= 850;
					topBars.x -= 10;
					add(topBars);
					
					bottomBars = new FlxSpriteExtra().makeSolid(2700, 320, FlxColor.BLACK);
					bottomBars.cameras = [camBars];
					bottomBars.screenCenter();
					bottomBars.y += 850;
					bottomBars.x -= 10;
					add(bottomBars);

					camBars.x += 0.5;
					
					if (ClientPrefs.shaders) if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(new BBPANZUBloomShader())]);
					//if (ClientPrefs.shaders) addShaderToCamera('camhud', new ChromaticAberrationEffect(0.0015));
					
					
					skipArrowStartTween = true;
					ondaCutscene = true;
					
					if(SONG.song.toLowerCase() == 'time travel') camGame.alpha = 0;

					var soundCaryArray:Array<String> = FileSystem.readDirectory('assets/sounds/carykh/');
					for (i in 0...soundCaryArray.length){
						precacheList.set(soundCaryArray[i], 'sound');
					}
				}
				
			case 'unfaith-BG': //ash
				{
					unfaithBG = new FlxSprite(0, 0).loadGraphic(Paths.image('unfaithful/unfaithful_bg'));
					unfaithBG.setGraphicSize(Std.int(unfaithBG.width * 1.25));
					unfaithBG.screenCenter();
					unfaithBG.updateHitbox();
					if (ClientPrefs.shaders) unfaithBG.shader = wavShader.shader;
					add(unfaithBG);
					
					unfaithBACK = new BGSprite('unfaithful/unfaithful_back', 0, 0, 0.85, 0.85);
					unfaithBACK.screenCenter();
					unfaithBACK.updateHitbox();
					unfaithBACK.x += 250;
					add(unfaithBACK);
					
					FlxTween.tween(unfaithBACK, {y: unfaithBACK.y + 50}, 2, {ease:FlxEase.smoothStepInOut, type: PINGPONG});
					
					var unfaithFloor:BGSprite = new BGSprite('unfaithful/unfaithful_floor', 0, 0, 1, 1);
					unfaithFloor.setGraphicSize(Std.int(unfaithFloor.width * 1.85));
					unfaithFloor.screenCenter();
					unfaithFloor.y += 550;
					//unfaithFloor.x += 150;
					unfaithFloor.updateHitbox();
					add(unfaithFloor);
					
					unfaithFRONT = new BGSprite('unfaithful/unfaithful_front', 0, 0, 1.3, 1.3);
					unfaithFRONT.setGraphicSize(Std.int(unfaithFRONT.width * 1.8));
					unfaithFRONT.screenCenter();
					unfaithFRONT.x -= 500;
					unfaithFRONT.y -= 750;
					unfaithFRONT.updateHitbox();
					
					FlxTween.tween(unfaithFRONT, {y: unfaithFRONT.y + 50}, 2, {ease:FlxEase.smoothStepInOut, type: PINGPONG});
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camHUD];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camHUD];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
					
					LightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
					vignetteTrojan = new FlxSprite(0, 0).loadGraphic(Paths.image('trojan/vignette', 'extras'));
					vignetteTrojan.antialiasing = ClientPrefs.globalAntialiasing;
					vignetteTrojan.cameras = [camOther];
					vignetteTrojan.scale.set(0.7, 0.7);
					vignetteTrojan.screenCenter();
					vignetteTrojan.alpha = 0;
					//vignetteTrojan.blend = LIGHTEN;
					add(vignetteTrojan);
					
					overlayUnfaith = new BGSprite('unfaithful/overlay', 0, 0, 1, 1);
					overlayUnfaith.setGraphicSize(Std.int(overlayUnfaith.width * 1.25));
					overlayUnfaith.screenCenter();
					
					//colorShad = new ColorSwap();
					
					if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(nightTimeShader.shader)]);
				}
				
			case 'aol': //ava 2
				{
					camZooming = true;
					aolBG = new BGSprite('aol/messenger_bg', 0, 0, 1, 1);
					aolBG.screenCenter();
					aolBG.updateHitbox();
					add(aolBG);
					
					aolBack = new BGSprite('aol/messenger_back', 0, 0, 1, 1);
					aolBack.setGraphicSize(Std.int(aolBack.width * 3));
					aolBack.screenCenter();
					aolBack.x += 980;
					aolBack.updateHitbox();
					add(aolBack);
					
					particleEmitter = new FlxEmitter(0, 1000);
                    particleEmitter.launchMode = FlxEmitterMode.SQUARE;
                    particleEmitter.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
                    particleEmitter.scale.set(2, 2, 2, 2, 0, 0, 0, 0);
                    particleEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
                    particleEmitter.width = 2787.45;
                    particleEmitter.alpha.set(0, 0);
                    particleEmitter.lifespan.set(1.9, 4.9);
					
                    particleEmitter.loadParticles(Paths.image('particle'), 500, 16, true);
					particleEmitter.color.set(FlxColor.YELLOW, FlxColor.YELLOW);

                    particleEmitter.start(false, FlxG.random.float(.01097, .0308), 1000000);
                    add(particleEmitter);
					
					aolFloor = new BGSprite('aol/messenger_floor', 0, 0, 1, 1);
					//floor.setGraphicSize(Std.int(floor.width * 2)); fuck this
					aolFloor.scale.set(2.5, 2);
					aolFloor.screenCenter();
					aolFloor.y += 625;
					aolFloor.x -= 200;
					aolFloor.updateHitbox();
					add(aolFloor);
					
					veryEpicVignette = new BGSprite('epic', 0, 0, 1, 1);
					veryEpicVignette.screenCenter();
					veryEpicVignette.updateHitbox();
					veryEpicVignette.alpha = 0;
					veryEpicVignette.color = FlxColor.YELLOW;
					veryEpicVignette.setGraphicSize(Std.int(veryEpicVignette.width * 2));
					
					oldVideoResolution = true;
					
					GameOverSubstate.characterName = 'tco-aol-dead';
					GameOverSubstate.deathSoundName = 'tco_loss_sfx';
					
					if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(0.0008));
				}
				
			case 'World 1':
				{
					var bg:BGSprite = new BGSprite('world1/fancy_bg', 0, 0, 0.9, 0.9);
					bg.setGraphicSize(Std.int(bg.width * 1.25));
					bg.screenCenter();
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					bg.updateHitbox();
					add(bg);
					
					var floor:BGSprite = new BGSprite('world1/fancy_floor', 0, 0, 1, 1);
					floor.setGraphicSize(Std.int(floor.width * 1.25));
					floor.screenCenter();
					floor.antialiasing = ClientPrefs.globalAntialiasing;
					floor.updateHitbox();
					add(floor);
					
					if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(0.0008));
				}
				
			case 'flashBG': //showdown collab
				{
					var bg:BGSprite = new BGSprite('collab/showdown/flashBg', 0, 0, 1, 1);
					bg.setGraphicSize(Std.int(bg.width * 2));
					bg.screenCenter();
					bg.y -= 100;
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);
					
					tcoPlataform = new BGSprite('collab/showdown/platform_tco', 0, 0, 1, 1);
					tcoPlataform.screenCenter();
					tcoPlataform.x -= 800;
					tcoPlataform.y -= 100;
					tcoPlataform.antialiasing = ClientPrefs.globalAntialiasing;
					add(tcoPlataform);
					
					tcoPlataform2 = new BGSprite('collab/showdown/platform_tco', 0, 0, 1, 1);
					tcoPlataform2.screenCenter();
					tcoPlataform2.x -= 650;
					tcoPlataform2.y += 100;
					tcoPlataform2.antialiasing = ClientPrefs.globalAntialiasing;
					add(tcoPlataform2);
					
					bfGfPlataform = new BGSprite('collab/showdown/platform_bfgf', 0, 0, 1, 1);
					bfGfPlataform.screenCenter();
					bfGfPlataform.x += 500;
					bfGfPlataform.y -= 80;
					bfGfPlataform.antialiasing = ClientPrefs.globalAntialiasing;
					add(bfGfPlataform);
					
		            bf2 = new Boyfriend(420, 190, "showdown-tco");
			        startCharacterPos(bf2);
					bf2.flipX = false;
					bf2.actuallyDad = true;

			        if (bf2 != null) dadGroup.add(bf2);
				}
				
			case 'aurora': //Cover 2
				{
					var bg:BGSprite = new BGSprite('aurora/wow_1', 0, 0, 1, 1);
					bg.setGraphicSize(Std.int(bg.width * 1.31));
					bg.screenCenter();
					bg.updateHitbox();
					add(bg);
					
					auroraTrees = new BGSprite('aurora/tree', 0, 0, 1, 1);
					auroraTrees.setGraphicSize(Std.int(auroraTrees.width * 1.31));
					auroraTrees.screenCenter();
					auroraTrees.updateHitbox();
					
					auroraLight = new BGSprite('aurora/light', 0, 0, 1, 1);
					auroraLight.setGraphicSize(Std.int(auroraLight.width * 1.31));
					auroraLight.screenCenter();
					auroraLight.updateHitbox();
					
					/*jumpScare = new FlxSprite().loadGraphic(Paths.image('aurora/auroraJumpScare', 'extras'));
					jumpScare.setGraphicSize(Std.int(FlxG.width * 1.15), Std.int(FlxG.height * 1.15));
					jumpScare.updateHitbox();
					jumpScare.screenCenter();
					add(jumpScare);
					jumpScare.visible = false;
					jumpScare.cameras = [camHUD];*/
					
					if (SONG.song.toLowerCase() == 'aurora')
					{
						camHUD.alpha = 0;
						FlxG.camera.fade(FlxColor.BLACK, 0, false);
						defaultCamZoom = 1.2;
					}
					
					GameOverSubstate.characterName = 'the-chosen-one-death';
					GameOverSubstate.deathSoundName = 'tco_loss_sfx';
				}
				
			case 'catto':
				{
					var bg:BGSprite = new BGSprite('Wong_Mau', 0, 0, 1, 1);
					bg.setGraphicSize(Std.int(bg.width * 3.5));
					bg.y += 250;
					bg.screenCenter();
					if(ClientPrefs.shaders) bg.shader = wavShader.shader;
					add(bg);
					
					topBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					topBarsALT.cameras = [camBars];
					topBarsALT.screenCenter();
					topBarsALT.y -= 450;
					add(topBarsALT);
			
					bottomBarsALT = new FlxSpriteExtra().makeSolid(2580,320, FlxColor.BLACK);
					bottomBarsALT.cameras = [camBars];
					bottomBarsALT.screenCenter();
					bottomBarsALT.y += 450;
					add(bottomBarsALT);
					
					camHUD.alpha = 0;
				}
				
			case 'animStage-old': //Old Stage
				{
					var backgroundAnim:BGSprite = new BGSprite('old/bg', -650, -500, 0.9, 0.9);
					backgroundAnim.setGraphicSize(Std.int(backgroundAnim.width * 1.1));
					add(backgroundAnim);
					
					var CrowdOld = new BGSprite('old/CheerCrowd', 450, 130, 0.9, 0.9, ['CheerCrowd'], true);
					CrowdOld.setGraphicSize(Std.int(CrowdOld.width * 2.8));
					add(CrowdOld);
					
					var pisoAnim:BGSprite = new BGSprite('old/floor', -750, -340, 0.9, 0.9);
					pisoAnim.setGraphicSize(Std.int(pisoAnim.width * 1.1));
					add(pisoAnim);
				}
			case 'red-zone-error':
				{
					rsod = new BGSprite('EProcess/rsod', 'chapter1', -650, -500, 1, 1);
					rsod.setGraphicSize(Std.int(rsod.width * 1.1));
					rsod.antialiasing = ClientPrefs.globalAntialiasing;
					if (ClientPrefs.shaders) rsod.shader = new CRTShader();

					add(rsod);
				}
		}

		if (leftSide) {
			healthGain*=-1;
			healthLoss*=-1;
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		switch(countDownType)
		{
			case 'Time Travel':
				introSoundsSuffix += '-cary'; //+= because if we also want custom pixel countdows or something
		}

		if(songName != 'phantasm') add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);
			
		switch(curStage)
		{
			case 'adobe':
				switch(SONG.song.toLowerCase())
				{
					case 'outrage':
						add(stickpage);
						add(stickpageFloor);
						add(bsod);
					case 'phantasm':
						add(bsod);
					case 'end process':
						add(corruptBG);
						add(corruptFloor);
						add(bsodStatic);
						add(rsod);
				}
		}
			
		if (needsBlackBG)
		{
			blackBG = new FlxSpriteExtra(-120, -120).makeSolid(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
			blackBG.scrollFactor.set();
        	blackBG.alpha = 0;
			blackBG.screenCenter();
			add(blackBG);
		}

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'adobe':
				switch(SONG.song.toLowerCase())
				{
					case 'adobe':
						add(spotlightbf);
						add(spotlightdad);
						//add(shine);
						
					case 'end process':
						//add(shine);
				}
			case 'unfaith-BG':
				add(unfaithFRONT);
				add(overlayUnfaith);
			case 'carykh':
				add(theHOGOVERLAYOMG);
			case 'kickstarter':
				add(overlayKick);
				
			case 'cubify-stage':
				add(overlayCubify);
				
			case 'aol':
				add(veryEpicVignette);
				
			case 'aurora':
				add(auroraTrees);
				add(auroraLight);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		
		if (songHasOtherPlayer)
		{
		    bf2 = new Boyfriend(270, 20, bf2Name);
			startCharacterPos(bf2);
			if (bf2 != null) boyfriendGroup.add(bf2);
		}

		if (songHasOtherPlayer2)
		{
			bf3 = new Boyfriend(670, 20, bf3Name);
			startCharacterPos(bf3);
			if (bf3 != null) boyfriendGroup.add(bf3);
		}


		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf') || dad.curCharacter.startsWith('animator-gf') && SONG.song.toLowerCase() == 'practice time') {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}
		
		var file:String = Paths.json(songName + '/dialogueScript'); //Checks for json/script dialogue
		if (OpenFlAssets.exists(file)) {
			ScriptdialogueJson = DialogueScript.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 9, 400, "", 32);
		timeTxt.setFormat(Paths.font("phantommuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		switch (uiType){
			default:
				timeBarBG = new AttachedSprite('healthBars/oldHealthBar');
				timeBarBG.x = timeTxt.x;
				timeBarBG.y = 10 + (timeTxt.height / 4);
				timeBarBG.scrollFactor.set();
				timeBarBG.alpha = 0;
				timeBarBG.visible = showTime;
				timeBarBG.color = FlxColor.BLACK;
				timeBarBG.xAdd = -4;
				timeBarBG.yAdd = -4;
				timeBarBG.setGraphicSize(Std.int(timeBarBG.width * 0.85));
				timeBarBG.screenCenter(X);
				add(timeBarBG);
				
				if (ClientPrefs.downScroll)
				{
					timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
				}

				timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, barDirection, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
					'songPercent', 0, 1);
				timeBar.scrollFactor.set();
				timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
				timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
				timeBar.alpha = 0;
				timeBar.visible = showTime;
				timeBar.setGraphicSize(Std.int(timeBar.width * 0.85));
				add(timeBar);
				reloadTimeBarColors();
				add(timeTxt);
				timeBarBG.sprTracker = timeBar;
		}

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		switch (uiType){
			default:
				healthBarBG = new AttachedSprite('healthBars/healthBar');
				healthBarBG.y = FlxG.height * 0.89;
				healthBarBG.screenCenter(X);
				healthBarBG.scrollFactor.set();
				healthBarBG.visible = !ClientPrefs.hideHud;
				healthBarBG.xAdd = -4;
				healthBarBG.yAdd = -4;
				healthBarBG.xAdd = -26;
				healthBarBG.yAdd = -12;
				healthBarBG.x += 150;
				//add(healthBarBG);
				if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 8, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 50), Std.int(healthBarBG.height - 28), this,
					'health', 0, 2);
				healthBar.scrollFactor.set();
				// healthBar
				healthBar.visible = !ClientPrefs.hideHud;
				healthBar.alpha = ClientPrefs.healthBarAlpha;
				healthBar.screenCenter(X);
				healthBar.x += 150;
				healthBar.y += 10;
				
				healthBar.scale.set(1.0, 0.7);
				healthBar.setGraphicSize(Std.int(healthBar.width * 0.8));
				healthBarBG.setGraphicSize(Std.int(healthBarBG.width * 0.8));
				
				add(healthBar);
				add(healthBarBG);
				healthBarBG.sprTracker = healthBar;
		}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 80;
		iconP1.x += 150;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);
		iconP1.setGraphicSize(Std.int(iconP1.width * 0.8));

		if (leftSide) iconP1.changeIcon(dad.healthIcon);
		
		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 80;
		iconP2.x += 150;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		iconP2.setGraphicSize(Std.int(iconP2.width * 0.8));

		if (bf2 != null) 
		{
			iconP3 = new HealthIcon(bf2.healthIcon, false);
			iconP3.y = healthBar.y - 80;
			iconP3.x += 150;
			iconP3.visible = !ClientPrefs.hideHud;
			iconP3.alpha = ClientPrefs.healthBarAlpha;
			add(iconP3);
			iconP3.setGraphicSize(Std.int(iconP3.width * 0.8));
		}

		if (bf3 != null) 
		{
			iconP4 = new HealthIcon(bf3.healthIcon, false);
			iconP4.y = healthBar.y - 80;
			iconP4.x += 150;
			iconP4.visible = !ClientPrefs.hideHud;
			iconP4.alpha = ClientPrefs.healthBarAlpha;
			add(iconP4);
			iconP4.setGraphicSize(Std.int(iconP4.width * 0.8));
		}
		
		if (leftSide) iconP2.changeIcon(boyfriend.healthIcon);
		
		reloadHealthBarColors();

		switch (uiType){
			default:
				scoreTxt = new FlxText(20, 0, 0, "", 20);
				scoreTxt.setFormat(Paths.font("phantommuff.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				scoreTxt.scrollFactor.set();
				scoreTxt.borderSize = 2;
				scoreTxt.visible = !ClientPrefs.hideHud;
				scoreTxt.screenCenter(Y);
				scoreTxt.y += 270;
				add(scoreTxt);
				
				if (ClientPrefs.downScroll) {
					scoreTxt.y -= 570;
				}
		}
		
		switch (uiType){
			default:
				judgementCounter = new FlxText(20, 0, 0, "", 20);
				judgementCounter.setFormat(Paths.font("phantommuff.ttf"), 28, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				judgementCounter.borderSize = 2;
				judgementCounter.borderQuality = 2;
				judgementCounter.scrollFactor.set();
				judgementCounter.screenCenter(Y);
				judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}';
				add(judgementCounter);
		}

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("phantommuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		if (iconP3 != null) iconP3.cameras = [camHUD];
		if (iconP4 != null) iconP4.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		judgementCounter.cameras = [camHUD];
		doof.cameras = [camHUD];
		
		/*if (leftSide)
		{
			healthBar.flipX = true;
		}*/
		
		healthBar.alpha = 0;
		healthBarBG.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		if (iconP3 != null) iconP3.alpha = 0;
		if (iconP4 != null) iconP4.alpha = 0;
		scoreTxt.alpha = 0;
		judgementCounter.alpha = 0;
		
		if (oldVideoResolution)
		{
		    timeBarBG.x -= 70;
			timeBar.x -= 70;
			healthBar.x -= 110;
		    healthBarBG.x -= 110;
			iconP1.x -= 110;
			iconP2.x -= 110;
			scoreTxt.x += 70;
			timeTxt.x -= 70;
			judgementCounter.x += 70;
			botplayTxt.x -= 70;
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case 'adobe':
					startDialogueScript(ScriptdialogueJson);
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');
		precacheList.set('throwMic', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		
		Lib.application.window.title = "Computerized Conflict - " + SONG.song + " - [" + CoolUtil.difficulties[storyDifficulty]
		+ "] - Composed by: " + SONG.composer;
		
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		callOnLuas('onCreatePost', []);
		
		if (curStage == 'alan-pc-conflict')
		{
			objectColor([boyfriend, alanBG, daFloor], 0xFF2C2425);
		}
		
		if (oldVideoResolution)
		{
			camOther.x -= 50; // Best fix ever 2022 (it's just for centering the camera lawl)
			camHUD.x -= 70;
			//timeBarBG.x += 70;
			//timeBar.x += 70;
			/*healthBar.x += 70;
			healthBarBG.x += 70;
			iconP1.x += 70;
			iconP2.x += 70;
			scoreTxt.x += 70;
			timeTxt.x += 70;*/
			
			Lib.application.window.resizable = false;
			FlxG.scaleMode = new StageSizeScaleMode();
			FlxG.resizeGame(960, 720);
			FlxG.resizeWindow(960, 720);
			camGame.width = 360;
			camGame.height = 720;

			playerStrums.forEach(function(spr:StrumNote) {
				spr.x -= 170;
			
				if (ClientPrefs.middleScroll)
				{
					spr.x += 100;
				}
			});
		}
		
		switch(SONG.song.toLowerCase())
		{
			case 'time travel':
				addCharacterToList('carykhTALK', 1);
				
			case 'amity':
				addCharacterToList('angry-minus-tco', 1);
			case 'rombie':
				dad.visible = false;
				iconP2.visible = false;
				healthBar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

				triggerEventNote('Camera Follow Pos', Std.string(boyfriend.getMidpoint().x + 100), Std.string(boyfriend.getMidpoint().y - 100));
			case 'redzone error':
				healthBar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

				for (i in 0...opponentStrums.length) opponentStrums.members[i].visible = false;
				iconP2.visible = false;
				dad.visible = false;
		}

		if (timeTraveled == true){
			timeTraveled = false;
			if(boyfriend.animation.getByName('hurt') != null) {
				boyfriend.playAnim('hurt', true);
				boyfriend.specialAnim = true;
			}
			trace(funnyArray);
			sicks = funnyArray[0];
			goods = funnyArray[1];
			bads = funnyArray[2];
			shits = funnyArray[3];
			songMisses = funnyArray[4];
			songScore = funnyArray[5];
			songHits = funnyArray[6];
			ratingPercent = ratingPercentTT;
			health = timeTravelHP;
			showHUDTween(1, 1);
			RecalculateRating();
			funnyArray = [];
		}


		super.create();

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				case 'video':
					Paths.video(key);
			}
		}
		Paths.clearUnusedMemory();
		
		CustomFadeTransition.nextCamera = camOther;
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		if (!leftSide){
			healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}else{
			healthBar.createFilledBar(FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]),
				FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
		}

		healthBar.updateBar();
	}
	
	public function reloadTimeBarColors() {
		timeBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
		timeBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}
	
	//MOD FUNCTIONS ALERT!!!!!! (very cringe)
	
	function cameraMovement(setMovementValue:Int)
	{
		var cameraX = 0;
		var cameraY = 0;
			
		switch(dad.animation.curAnim.name)
		{
			case 'singLEFT' | 'singLEFT-alt':
				cameraX -= setMovementValue;
			case 'singRIGHT' | 'singRIGHT-alt':
				cameraX += setMovementValue;
			case 'singUP' | 'singUP-alt':
				cameraY -= setMovementValue;
			case 'singDOWN' | 'singDOWN-alt':
				cameraY += setMovementValue;
		}
		
		var cameraXBF = 0;
		var cameraYBF = 0;
			
		switch(boyfriend.animation.curAnim.name)
		{
			case 'singLEFT' | 'singLEFT-alt':
				cameraXBF -= setMovementValue;
			case 'singRIGHT' | 'singRIGHT-alt':
				cameraXBF += setMovementValue;
			case 'singUP' | 'singUP-alt':
				cameraYBF -= setMovementValue;
			case 'singDOWN' | 'singDOWN-alt':
				cameraYBF += setMovementValue;
		}
		
			
		if (generatedMusic && !endingSong && !isCameraOnForcedPos && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.set(dad.getMidpoint().x + 150 + cameraX, dad.getMidpoint().y - 100 + cameraY);
				camFollow.x += dad.cameraPosition[0];
				camFollow.y += dad.cameraPosition[1];
			}
			else
			{
				camFollow.set(boyfriend.getMidpoint().x - 100 + cameraXBF, boyfriend.getMidpoint().y - 100 + cameraYBF);
				camFollow.x += boyfriend.cameraPosition[0];
				camFollow.y += boyfriend.cameraPosition[1];
			}
			
			if (bf2 != null || bf3 != null)
			{
				
				//var cameraXBF = 0;
				//var cameraYBF = 0;
			
				switch(bf2.animation.curAnim.name)
				{
					case 'singLEFT' | 'singLEFT-alt':
						cameraXBF -= setMovementValue;
					case 'singRIGHT' | 'singRIGHT-alt':
						cameraXBF += setMovementValue;
					case 'singUP' | 'singUP-alt':
						cameraYBF -= setMovementValue;
					case 'singDOWN' | 'singDOWN-alt':
						cameraYBF += setMovementValue;
				}
		
				//var cameraXBF = 0;
				//var cameraYBF = 0;
			
				if (bf3 != null) switch(bf3.animation.curAnim.name)
				{
					case 'singLEFT' | 'singLEFT-alt':
						cameraXBF -= setMovementValue;
					case 'singRIGHT' | 'singRIGHT-alt':
						cameraXBF += setMovementValue;
					case 'singUP' | 'singUP-alt':
						cameraYBF -= setMovementValue;
					case 'singDOWN' | 'singDOWN-alt':
						cameraYBF += setMovementValue;
				}
				
				if (SONG.notes[curSection].bf2Section)
				{
					if (!bf2.actuallyDad)
					{
						camFollow.set(bf2.getMidpoint().x - 100  + cameraXBF, bf2.getMidpoint().y - 100  + cameraYBF);
						camFollow.x -= bf2.cameraPosition[0];
					}
					else
					{
						camFollow.set(bf2.getMidpoint().x + 150 + cameraX, bf2.getMidpoint().y - 100 + cameraY);
						camFollow.x += bf2.cameraPosition[0];
					}
					camFollow.y += bf2.cameraPosition[1];
				}
				else if (SONG.notes[curSection].bf3Section)
				{
					camFollow.set(bf3.getMidpoint().x - 100  + cameraXBF, bf3.getMidpoint().y - 100  + cameraYBF);
					camFollow.x -= bf3.cameraPosition[0];
					camFollow.y += bf3.cameraPosition[1];
				}
			}
		}
	}
	
	public function dialogOnSong(dialog:String, duration:Float, color:FlxColor)
	{
		if (lyricsDestroyTimer != null) lyricsDestroyTimer.cancel();
		if (textTween != null) textTween.cancel();
		if (textTweenAlpha != null) textTweenAlpha.cancel();
		if (textLyrics != null) {remove(textLyrics); textLyrics.destroy();}
		textLyrics = new FlxTypeText(0, -40, FlxG.width, dialog, 24);
		textLyrics.setFormat(Paths.font("phantommuff.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textLyrics.cameras = [camLYRICS];
		textLyrics.screenCenter();
		textLyrics.y += 250;
		textLyrics.scrollFactor.set();
		textLyrics.color = color;
		add(textLyrics);
		textLyrics.alpha = 0;
			
		textLyrics.start(0.03, true);
		textTweenAlpha = FlxTween.tween(textLyrics, {alpha:1}, 0.5);
		
		lyricsDestroyTimer = new FlxTimer().start(duration, function(A:FlxTimer)
		{
			textTween = FlxTween.tween(textLyrics, {alpha: 0}, 0.5, {
		    ease: FlxEase.linear,
		    onComplete: function(twn:FlxTween) {
				remove(textLyrics);
				textLyrics.destroy();
			}});
		});
	}
	
	public function dialogOnSongNoTween(dialog:String, duration:Float, color:FlxColor)
	{
			textNoTween = new FlxText(0, -20, FlxG.width, dialog, 24);
			textNoTween.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			textNoTween.cameras = [camHUD];
			textNoTween.screenCenter();
			textNoTween.y += 200;
			textNoTween.scrollFactor.set();
			textNoTween.color = color;
			add(textNoTween);
			
			new FlxTimer().start(duration, function(A:FlxTimer)
			{
				if (textNoTween != null)
				{
					remove(textNoTween);
					textNoTween.destroy();
				}
			});
	}
	
	function blackBars(yes:Int)
	{
		if (topBars != null && bottomBars != null)
		{
			if (yes == 1)
			{
				FlxTween.tween(topBars, {y: -200}, 1, {ease: FlxEase.quadInOut});
				FlxTween.tween(bottomBars, {y: 550}, 1, {ease: FlxEase.quadInOut});
			}
			else
			{
				FlxTween.tween(topBars, {y: -650}, 0.5, {ease: FlxEase.quadInOut});
				FlxTween.tween(bottomBars, {y: 850}, 0.5, {ease: FlxEase.quadInOut});
			}
		}
	}
	
	function pushBlackBars2(yes:Int)
	{
		if (topBarsALT != null && bottomBarsALT != null)
		{
			if (yes == 1)
			{
				topBarsALT.alpha = 1;
				bottomBarsALT.alpha = 1;
			}
			else
			{
				topBarsALT.alpha = 0;
				bottomBarsALT.alpha = 0;
			}
		}
	}
	
	function flash(color:FlxColor, duration:Float)
	{
		if(ClientPrefs.flashing) FlxG.cameras.flash(color, duration);
	}
	
	function colorTween(object:Array<FlxSprite>, duration:Float, colorToSayGoodbye:FlxColor, colorToSayHello:FlxColor)
	{
		for (i in 0...object.length) FlxTween.color(object[i], duration, colorToSayGoodbye, colorToSayHello);
	}
	
	function objectColor(object:Array<FlxSprite>, shitColor:FlxColor)
	{
		for (i in 0...object.length) object[i].color = shitColor;
	}
	
	function alphaTween(object:Array<FlxSprite>, duration:Float, alpha:Float)
	{
		for (i in 0...object.length) FlxTween.tween(object[i], {alpha:duration}, alpha, {ease: FlxEase.sineInOut});
	}
	
	function setVisible(object:Array<FlxSprite>, visibility:Bool)
	{
		for (i in 0...object.length) object[i].visible = visibility;
	}
	
	function setAlpha(object:Array<FlxSprite>, visibility:Int)
	{
		for (i in 0...object.length) object[i].alpha = visibility;
	}
	
	function setCamShake(shit:Array<FlxCamera>, intensity:Float, duration:Float, intensityAlt:Float)
	{
		for (i in 0...shit.length)
		{
			if (SONG.notes[curSection].mustHitSection)
			{
				camGame.shake(intensityAlt, duration);
			}
			else
			{
				shit[i].shake(intensity, duration);
			}
		}
	}
	
	function setDance(object:Array<BGSprite>, dance:Bool)
	{
		for (i in 0...object.length) object[i].dance(dance);
	}
	
	function changeBetweenMinusTCO(angry:Bool)
	{
		if (!angry)
		{
			if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.BLACK, 0.50);
			triggerEventNote('Change Character', 'dad', 'minus-tco');
		}
		else
		{
			if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.RED, 0.50);
			triggerEventNote('Change Character', 'dad', 'angry-minus-tco');
		}
	}
	
	function healthDrainRates(simple:Float, hard:Float, insane:Float)
	{
		switch(CoolUtil.difficultyString())
		{
			case 'SIMPLE':
				health -= simple;
			case 'HARD':
				health -= hard;
			case 'INSANE':
				health -= insane;
		}
	}
	
	public function confBSODShake(intensity:Float = 1.0)
		{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				bsod.y += (10 * intensity);
			});
			new FlxTimer().start(0.05, function(tmr:FlxTimer)
			{
				bsod.y -= (15 * intensity);
			});
			new FlxTimer().start(0.10, function(tmr:FlxTimer)
			{
				bsod.y += (8 * intensity);
			});
			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				bsod.y -= (5 * intensity);
			});
			new FlxTimer().start(0.20, function(tmr:FlxTimer)
			{
				bsod.y += (3 * intensity);
			});
			new FlxTimer().start(0.25, function(tmr:FlxTimer)
			{
				bsod.y -= (1 * intensity);
			});
		}
	
	function tcoBSOD(fuck:Bool)
	{
		if (fuck)
		{
			if (bsod != null) alphaTween([bsod], 1, 1);
			if (bsod != null) colorTween([boyfriend], 1, 0xFF2C2425, FlxColor.WHITE);
			if(CoolUtil.difficultyString() == 'INSANE') lossingHealthPlus = true;
		}
		else
		{
			if (bsod != null) alphaTween([bsod], 0, 1);
			if (bsod != null) colorTween([boyfriend], 1, FlxColor.WHITE, 0xFF2C2425);
			if(CoolUtil.difficultyString() == 'INSANE') lossingHealthPlus = false;
		}
	}
	
	function tcoStickPage(show:Bool)
	{
		if (stickpage != null) setAlpha([stickpage, stickpageFloor], 1);
		if (stickpage != null) triggerEventNote('Change Character', 'bf', 'stick-bf');
		if (stickpage != null) boyfriend.color = 0xFF2C2425;
		if (stickpage != null) redthing.color = 0xFF000000;
		
		if (!show && bsod != null && stickpage != null)
		{
			setAlpha([stickpage, stickpageFloor], 0);
			remove(stickpage);
			stickpage.destroy();
			stickpage = null;
			
			triggerEventNote('Change Character', 'bf', 'animator-bf-stressed');
			redthing.color = 0xFFFFFFFF;
		}
	}
	
	function endProcessBSODS(fuck:Bool, type:Int)
	{
		switch(type)
		{
			case 1:
				if (fuck && bsodStatic != null) alphaTween([bsodStatic], 1, 1);
				else alphaTween([bsodStatic], 0, 1);
			case 2:
				if (fuck && rsod != null) alphaTween([rsod], 1, 1);
				else alphaTween([rsod], 0, 1);
		}
	}
	
	function showUpCorruptBackground(fuck:Bool)
	{
		if (fuck)
		{
			if (corruptBG != null) setAlpha([corruptBG, corruptFloor], 1);
		}
		else
		{
			if (corruptBG != null) setAlpha([corruptBG, corruptFloor], 0);
		}
	}
	
	function showHUDTween(duration:Float, alpha:Float)
	{
		if(!ClientPrefs.hideHud) {
			alphaTween([healthBar, healthBarBG, iconP1, iconP2, scoreTxt, judgementCounter, botplayTxt], duration, alpha);
			if (iconP3 != null) alphaTween([iconP3], duration, alpha);
			if (iconP4 != null) alphaTween([iconP4], duration, alpha);
		}
		
		if(ClientPrefs.timeBarType != 'Disabled') {
	    	alphaTween([timeBar, timeBarBG, timeTxt], duration, alpha);
		}
		
		for (i in 0...playerStrums.length) alphaTween([playerStrums.members[i]], duration, alpha);
		
		if (ClientPrefs.middleScroll && alpha <= 0.35)
		{
			for (i in 0...opponentStrums.length) alphaTween([opponentStrums.members[i]], duration, 0.35);
		}
		else
		{
			for (i in 0...opponentStrums.length) alphaTween([opponentStrums.members[i]], duration, alpha);
		}
	}
	
	function showCamOtherTween(duration:Float, alpha:Float)
	{
		FlxTween.tween(camOther, {alpha:alpha}, duration);
	}
	
	//end
	
	//0.5.1 shaders functions:
	
	public function addShaderToCamera(cam:Array<String>, effect:ShaderEffect)//STOLE FROM ANDROMEDA
	{
		for (i in 0...cam.length)
		{
			switch(cam[i].toLowerCase())
			{
				case 'camhud' | 'hud':
					camHUDShaders.push(effect);
					var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for (i in camHUDShaders)
					{
						newCamEffects.push(new ShaderFilter(i.shader));
					}
					
					camHUD.setFilters(newCamEffects);
				
				case 'camother' | 'other':
					camOtherShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for (i in camOtherShaders)
					{
						newCamEffects.push(new ShaderFilter(i.shader));
					}
				
					camOther.setFilters(newCamEffects);
				
				case 'camgame' | 'game':
					camGameShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for (i in camGameShaders)
					{
						newCamEffects.push(new ShaderFilter(i.shader));
					}
				
					camGame.setFilters(newCamEffects);
				
				default:
					if (modchartSprites.exists(cam[i]))
					{
						Reflect.setProperty(modchartSprites.get(cam[i]),"shader",effect.shader);
					}
					else if (modchartTexts.exists(cam[i]))
					{
						Reflect.setProperty(modchartTexts.get(cam[i]),"shader",effect.shader);
					}
					else
					{
						var OBJ = Reflect.getProperty(PlayState.instance, cam[i]);
						Reflect.setProperty(OBJ,"shader", effect.shader);
					}
			}
		}
	}
	
	public function removeShaderFromCamera(cam:Array<String>, effect:ShaderEffect)
	{
		for (i in 0...cam.length)
		{
			switch(cam[i].toLowerCase())
			{
				case 'camhud' | 'hud':
					camHUDShaders.remove(effect);
					var newCamEffects:Array<BitmapFilter> = [];
					for (i in camHUDShaders)
					{
						newCamEffects.push(new ShaderFilter(i.shader));
					}
				
					camHUD.setFilters(newCamEffects);
				
				case 'camother' | 'other': 
					camOtherShaders.remove(effect);
					var newCamEffects:Array<BitmapFilter> = [];
					for (i in camOtherShaders)
					{
						newCamEffects.push(new ShaderFilter(i.shader));
					}
				
					camOther.setFilters(newCamEffects);
				
				default:
					camGameShaders.remove(effect);
					var newCamEffects:Array<BitmapFilter> = [];
					for (i in camGameShaders)
					{
						newCamEffects.push(new ShaderFilter(i.shader));
					}
				
					camGame.setFilters(newCamEffects);
			}
		}
	}
	
	public function clearShaderFromCamera(cam:Array<String>)
	{
		for (i in 0...cam.length)
		{
			switch(cam[i].toLowerCase())
			{
				case 'camhud' | 'hud':
					camHUDShaders = [];
					var newCamEffects:Array<BitmapFilter> = [];
					camHUD.setFilters(newCamEffects);
				
				case 'camother' | 'other': 
					camOtherShaders = [];
					var newCamEffects:Array<BitmapFilter> = [];
					camOther.setFilters(newCamEffects);
				
				default:
					camGameShaders = [];
					var newCamEffects:Array<BitmapFilter> = [];
					camGame.setFilters(newCamEffects);
			}
		}
	}
		
	//end

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf') || char.curCharacter.startsWith('animator-gf') && SONG.song.toLowerCase() == 'practice time') { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	public var scriptDialogue:DialogueScript;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}
	
	public function startDialogueScript(dialogueFile:ScriptDialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(scriptDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			scriptDialogue = new DialogueScript(dialogueFile, song);
			scriptDialogue.scrollFactor.set();
			if(endingSong) {
				scriptDialogue.finishThing = function() {
					scriptDialogue = null;
					endSong();
				}
			} else {
				scriptDialogue.finishThing = function() {
					scriptDialogue = null;
					startCountdown();
				}
			}
			scriptDialogue.nextDialogueThing = startNextDialogue;
			scriptDialogue.skipDialogueThing = skipDialogue;
			scriptDialogue.cameras = [camHUD];
			add(scriptDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
		introAssets.set('cary', ['cary/tt_ready', 'cary/tt_set', 'cary/tt_GO']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		if(SONG.song.toLowerCase() == 'time travel') introAlts = introAssets.get('cary');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
				normalThingOrShit.push(playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
				normalThingOrShit.push(opponentStrums.members[i].y);
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}
			
			if (SONG.song.toLowerCase() == 'tune in')
			{
				iconP3.alpha = 0;
				iconP4.alpha = 0;
				bf2.alpha = 0;
				bf3.alpha = 0;
				
				boyfriend.y = BF_Y - 160;
			}
			
			//shit
			switch(SONG.song.toLowerCase())
			{
				case 'adobe': //code was took from the lse mod bcs im veryy lazyy pls play LSE mod and support  the devs: 
			        //https://gamebanana.com/mods/358645
					
					spotlightdad.x = dad.x - 400;
					spotlightdad.y = dad.y + dad.height - 1150;
					
					spotlightbf.x = boyfriend.x - 355;
					spotlightbf.y = boyfriend.y + boyfriend.height - 1350;
					
				case 'time travel':
					
					opponentStrums.forEach(function(spr:StrumNote) {
						spr.alpha = 0;
					});
					
					playerStrums.forEach(function(spr:StrumNote) {
						spr.alpha = 0;
					});
					
				case 'tune in' | 'alan':
					
					opponentStrums.forEach(function(spr:StrumNote) {
						spr.x -= 1000;
					});
					
				case 'amity':
					
					isCameraOnForcedPos = true;
					camFollow.x = gf.getMidpoint().x + gf.cameraPosition[1] + girlfriendCameraOffset[1]; 
					camFollow.y = gf.getMidpoint().y + gf.cameraPosition[2] + girlfriendCameraOffset[2]; 
				
				case 'aurora':
					isCameraOnForcedPos = true;
					camFollow.x = 1150;
					camFollow.y = 150;
			}
			
			if (leftSide)
			{
				for (i in 0...playerStrums.length) {
					playerStrums.members[i].x = opponentStrums.members[i].x;
				}
					
				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].x -= ((FlxG.width / 2) * playerStrums.members[i].x);
				}
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', 'set', 'go']);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
			introAssets.set('cary', ['cary/tt_ready', 'cary/tt_set', 'cary/tt_GO']);

			var introAlts:Array<String> = introAssets.get('default');
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			if(isPixelStage) {
				introAlts = introAssets.get('pixel');
				antialias = false;
			}

			if(SONG.song.toLowerCase() == 'time travel') {
				introAlts = introAssets.get('cary');
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}
				
				if (bf2 != null || bf3 != null)
				{
					if (tmr.loopsLeft % bf2.danceEveryNumBeats == 0 && bf2.animation.curAnim != null && !bf2.animation.curAnim.name.startsWith('sing') && !bf2.stunned)
					{
						bf2.dance();
					}
					if (bf3 != null && tmr.loopsLeft % bf3.danceEveryNumBeats == 0 && bf3.animation.curAnim != null && !bf3.animation.curAnim.name.startsWith('sing') && !bf3.stunned)
					{
						bf3.dance();
					}
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.cameras = [camHUD];
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));
							
						if(SONG.song.toLowerCase() == 'time travel') countdownReady.setGraphicSize(Std.int(countdownReady.width * 0.5));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						insert(members.indexOf(notes), countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.cameras = [camHUD];
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));
							
						if(SONG.song.toLowerCase() == 'time travel') countdownSet.setGraphicSize(Std.int(countdownSet.width * 0.5));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						insert(members.indexOf(notes), countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.cameras = [camHUD];
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));
							
						if(SONG.song.toLowerCase() == 'time travel') countdownGo.setGraphicSize(Std.int(countdownGo.width * 0.5));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		switch(ClientPrefs.language)
		{
			case 'Español':
				
				scoreTxt.text = 'Puntuación: ' + songScore
				+ '\nFallos de Combo: ' + songMisses
				+ '\nPrecisión: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ' + (ratingName != 'N/A' ? '(' + ratingFC + ')' : '');
				
			case 'Portuguese':
				
				scoreTxt.text = 'Pontuação: ' + songScore
				+ '\nFalhas de combinação: ' + songMisses
				+ '\nPrecisão: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ' + (ratingName != 'N/A' ? '(' + ratingFC + ')' : '');
				
			default:
				
				scoreTxt.text = 'Score: ' + songScore
				+ '\nCombo Breaks: ' + songMisses
				+ '\nAccuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ' + (ratingName != 'N/A' ? '(' + ratingFC + ')' : '');
		}

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	function startSong():Void
	{
		startingSong = false;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		actualSongLength = songLength;
		
		if (SONG.song.toLowerCase() != 'time travel')
		{
			
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		
			FlxTween.tween(healthBar, {alpha:1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(healthBarBG, {alpha:1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(iconP1, {alpha:1}, 0.5, {ease: FlxEase.circOut});
	    	FlxTween.tween(iconP2, {alpha:1}, 0.5, {ease: FlxEase.circOut});
			if (iconP3 != null) FlxTween.tween(iconP3, {alpha:1}, 0.5, {ease: FlxEase.circOut});
	    	if (iconP4 != null) FlxTween.tween(iconP4, {alpha:1}, 0.5, {ease: FlxEase.circOut});

			FlxTween.tween(scoreTxt, {alpha:1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(judgementCounter, {alpha:1}, 0.5, {ease: FlxEase.circOut});
		
		}

		switch(SONG.song.toLowerCase())
		{
			case 'time travel':
				songLength = 110000;
				camGame.alpha = 1;
				theHOGOVERLAYOMG.alpha = 1;
				blackBars(1);
				triggerEventNote('Change Character', 'dad', 'carykhTALK');
				triggerEventNote('Play Animation', 'cutsceneTALK', 'dad');

			case 'tune in':
				iconP3.visible = false;
				iconP4.visible = false;

			case 'rombie':
				zoomTweenStart = FlxTween.tween(FlxG.camera, {zoom: 1}, 3 * playbackRate, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn)
					{
						defaultCamZoom = 1;
					},
				});
		}

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		notes.active = false;
		add(notes);

		var noteData:Array<SwagSection> = songData.notes;
		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				noteTypeMap.set(swagNote.noteType, true);
			}
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		eventPushedMap.set(event.event, true);
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var targetAlpha:Float = 1;
		if (player < 1)
		{
			if(!ClientPrefs.opponentStrums) targetAlpha = 0;
			else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
		}

		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			if (videoTI != null) videoTI.resume();
			if (zoomTweenStart != null) zoomTweenStart.active = true;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		callOnLuas('onUpdate', [elapsed]);

		if (ClientPrefs.cameraMovement)
		{
			switch(curStage)
			{
				case 'adobe' | 'bbpanzu-stage' | 'alan-pc-virabot' | 'alan-pc-conflict':
					cameraMovement(40);
				default:
					cameraMovement(25);
			}
		}
		
		if (curStage == 'alan-pc-conflict')
		{
			confBSODShake(1.0);
		}
		
		switch(curStage)
		{
			case 'unfaith-BG' | 'catto':
				wavShader.shader.iTime.value[0] += elapsed;
			case 'rombieBG':
				distortShader.shader.iTime.value[0] += elapsed;
				distortShaderHUD.shader.iTime.value[0] += elapsed;
			case 'alan-pc-conflict':
				endingShader.shader.uTime.value[0] += elapsed;
			/*case 'alan-pc-virabot':
				trojanShader.shader.uTime.value[0] += elapsed;*/
			case 'bbpanzu-stage':
				NTSCshader.shader.iTime.value[0] += elapsed;
			case 'garden':
				nightTimeShader.shader.iTime.value[0] += elapsed;
		}
		rainbowShader.shader.iTime.value[0] += elapsed;
		
		
		testShader3D.shader.iTime.value[0] += elapsed;
		
		/*if (SONG.song.toLowerCase() == 'trojan')
		{
			if (!dodged && FlxG.keys.justPressed.SPACE)
			{
				dodged = true;
			}
		}*/

		if (whiteScreen != null) whiteScreen.scale.set(Std.int(FlxG.width/FlxG.camera.zoom) + 50, Std.int(FlxG.height/FlxG.camera.zoom) + 50);
		if (whiteScreen != null && SONG.song.toLowerCase() == 'rombie') whiteScreen.scale.set(Std.int(FlxG.width*2/FlxG.camera.zoom), Std.int(FlxG.height*2/FlxG.camera.zoom));

		if (ytBGVideo != null && videoTI != null) ytBGVideo.loadGraphic(videoTI.bitmapData);

		if (strikesTxt != null) {
			strikesTxt.x = FlxG.width / 1.5 - strikesTxt.width;
			strikesTxt.y = FlxG.height / 12;
			if(ClientPrefs.downScroll) strikesTxt.y = FlxG.height - FlxG.height / 8;
		}

		if (strikes >= 3) {
			vocals.volume = 0;
			health = -1;
		}

		if(dad.curCharacter == 'cursor'){
			var test:Float = (Conductor.songPosition/3000)*(SONG.bpm/30);

			dad.x = DAD_X + dad.positionArray[0] + 800*Math.sin(test);
			dad.y = DAD_Y + dad.positionArray[1] + 600*Math.sin(test/2);
		}
		
		if (oldVideoResolution)
		{
			FlxG.fullscreen = false;
		}
		
		if (health > 0.2 && lossingHealth && CoolUtil.difficultyString() != 'SIMPLE')
		{
			health -= 0.0015 * 60 * elapsed;
		}

		//trace(1/elapsed +' ' + elapsed + ' ' + FlxG.updateFramerate + '   ' + timeWithLowerFps);

		if ((60 > 1/elapsed) && ClientPrefs.shaders){
			timeWithLowerFps += elapsed;
		}else{
			timeWithLowerFps = 0;
		}

		if(ClientPrefs.shaders) {
			if (timeWithLowerFps >= 5){
				if (laggyText != null){
					laggyText.alpha = 1;
					laggyText.screenCenter();
				}else{
					laggyText = new FlxText(0, 0, FlxG.width, "IF IT\'S TOO LAGGY,\nGO TO THE OPTIONS MENU AND \nDISABLE SHADERS", 20);
					laggyText.setFormat(Paths.font("phantommuff.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					laggyText.borderSize = 2;
					laggyText.visible = !ClientPrefs.hideHud;
					laggyText.cameras = [camOther];
					add(laggyText);
				}
			}else{
				if (laggyText != null) laggyText.alpha = 0;
			}
		}

		//TODO: rework
		//TODO: 440, 22
		if (popUp != null && closePopup != null) {
			FlxG.mouse.visible = true;
			if (FlxG.mouse.overlaps(closePopup, closePopup.cameras[1]) && FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('mouseClick'));
				
				//tweens are broken when 2 clicks in a row idk why xd
				
				//FlxTween.tween(popUp, {alpha:0}, 0.15, {onComplete: function(tween:FlxTween) {
					remove(popUp);
					popUp.destroy();
					popUp = null;
				//}});
				//FlxTween.tween(closePopup, {alpha:0}, 0.15, {onComplete: function(tween:FlxTween) {
					remove(closePopup);
					closePopup.destroy();
					closePopup = null;
				//}});
				popUpTimer.cancel();
				popUpTimer.destroy();
			}
		}

		switch (curStage)
		{

		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		
		switch (uiType){
			default:
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		}

		if (iconP3 != null) 
		{
			if (bf2.actuallyDad != true)
			{
				iconP3.scale.set(iconP1.scale.x - 0.3, iconP1.scale.y - 0.3);
				iconP3.x = iconP1.x + 50;
				iconP3.y = iconP1.y - 40;
				iconP3.flipX = !iconP1.flipX;
				iconP3.angle = iconP1.angle;
			}
			else
			{
				iconP3.scale.set(iconP2.scale.x - 0.3, iconP2.scale.y - 0.3);
				iconP3.x = iconP2.x - 50;
				iconP3.y = iconP2.y - 40;
				iconP3.flipX = iconP2.flipX;
				iconP3.angle = iconP2.angle;
			}
		}

		if (iconP4 != null) 
		{
			if (bf3.actuallyDad != true)
			{
				iconP4.scale.set(iconP1.scale.x - 0.3, iconP1.scale.y - 0.3);
				iconP4.x = iconP1.x + 50;
				iconP4.y = iconP1.y + 40;
				iconP4.flipX = !iconP1.flipX;
				iconP4.angle = iconP1.angle;
			}
			else
			{
				iconP4.scale.set(iconP2.scale.x - 0.3, iconP2.scale.y - 0.3);
				iconP4.x = iconP2.x - 50;
				iconP4.y = iconP2.y + 40;
				iconP4.flipX = iconP2.flipX;
				iconP4.angle = iconP2.angle;
			}
		}

		
		if (health > 2 && !leftSide)
			health = 2;
		if (health < 0 && leftSide)
			health = 0;

		if (healthBar.percent < 20){
			iconP1.animation.curAnim.curFrame = 1;
			if (iconP3 != null && bf2.actuallyDad != true) iconP3.animation.curAnim.curFrame = 1;
			if (iconP4 != null && bf3.actuallyDad != true) iconP4.animation.curAnim.curFrame = 1;
		}else{
			iconP1.animation.curAnim.curFrame = 0;
			if (iconP3 != null && bf2.actuallyDad != true) iconP3.animation.curAnim.curFrame = 0;
			if (iconP4 != null && bf3.actuallyDad != true) iconP4.animation.curAnim.curFrame = 0;
		}

		if (healthBar.percent > 80){
			iconP2.animation.curAnim.curFrame = 1;
			if (iconP3 != null && bf2.actuallyDad) iconP3.animation.curAnim.curFrame = 1;
			if (iconP4 != null && bf3.actuallyDad) iconP4.animation.curAnim.curFrame = 1;
		}else{
			iconP2.animation.curAnim.curFrame = 0;
			if (iconP3 != null && bf2.actuallyDad) iconP3.animation.curAnim.curFrame = 0;
			if (iconP4 != null && bf3.actuallyDad) iconP4.animation.curAnim.curFrame = 0;
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown)
		{
			Conductor.songPosition += elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			notes.update(elapsed);

			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strum = strumGroup.members[daNote.noteData];

					var strumX:Float = strum.x;
					var strumY:Float = strum.y;
					var strumAngle:Float = strum.angle;
					var strumDirection:Float = strum.direction;
					var strumAlpha:Float = strum.alpha;
					var strumScroll:Bool = strum.downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strum.sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if (!daNote.checkedSlash && (daNote.strumTime - Conductor.songPosition) < 180 && daNote.noteType == 'Tdl note') {
						if (!slashing){
							slashing = true;
							if(dad.animation.getByName('attack') != null) {
								dad.playAnim('attack', true);
								dad.specialAnim = true;
								trace('attack!');
								new FlxTimer().start(1, function(timer:FlxTimer)
								{
									slashing = false;
									dad.specialAnim = false;
								});
							}
						}

						daNote.checkedSlash = true;
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);

		for (i in shaderUpdates){
			i(elapsed);
		}

		//Paths.clearUnusedMemory();
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		
		if (SONG.song.toLowerCase() == 'end process' && popUpTimer != null) popUpTimer.active = false;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		if (videoTI != null) videoTI.pause();
		if (zoomTweenStart != null) zoomTweenStart.active = false;
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		var check:Bool = (skipHealthCheck && instakillOnMiss) || health <= 0;
		if (leftSide) check = (skipHealthCheck && instakillOnMiss) || health >= 2;
		if (check && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				
				switch(gameOverType){
					case 'Time Travel':
						var soundCaryArray:Array<String> = FileSystem.readDirectory('assets/sounds/carykh/');
						var chosenInt = FlxG.random.int(0, soundCaryArray.length-1);
						var shit:FlxSound = new FlxSound().loadEmbedded('assets/sounds/carykh/' + soundCaryArray[chosenInt]);
						FlxG.sound.music.stop();
						vocals.stop();
						shit.play(true);
						shit.onComplete = function() {PauseSubState.restartSong(true); }
					    camGame.alpha = 0;
						camHUD.alpha = 0;
						
					default:
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf') || dad.curCharacter.startsWith('animator-gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf') || !dad.curCharacter.startsWith('animator-gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
				reloadTimeBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}

			case 'Popup':
				if (!cpuControlled){
					if (popUp != null) {
						return;
					}

					FlxG.sound.play(Paths.sound("erro"));
					popUp = new FlxSprite(FlxG.random.int(0, 774), FlxG.random.int(0, 421)).loadGraphic(Paths.image('EProcess/popups/popup_' + FlxG.random.int(1, 7), 'chapter1'));
					popUp.cameras = [camGame];
					popUp.scrollFactor.set();
					popUp.updateHitbox();
					add(popUp);

					closePopup = new FlxSprite().loadGraphic(Paths.image('EProcess/popups/close_icon', 'chapter1'));
					closePopup.cameras = [camGame];
					closePopup.scale.set(0.20, 0.20);
					closePopup.x = popUp.x + 436;
					closePopup.y = popUp.y + 22;
					closePopup.scrollFactor.set();
					closePopup.updateHitbox();
					add(closePopup);
					
					var timeThing = 10;
					switch(CoolUtil.difficultyString())
					{
						case 'SIMPLE':
							timeThing = 20;
						case 'HARD':
							timeThing = 15;
					}

					popUpTimer = new FlxTimer();
					popUpTimer.start(timeThing, function(timer:FlxTimer) {
						health = -0.1;
					});
				}
				
			case 'zoomBeatType1':
				if(ClientPrefs.camZooms) zoomType1 = true;
			case 'zoomBeatType2':
				if(ClientPrefs.camZooms) zoomType2 = true;
			case 'zoomBeatType3':
				if(ClientPrefs.camZooms) zoomType3 = true;
				
				//stop beats
			case 'zoomBeatType1 Cancel':
				zoomType1 = false;
			case 'zoomBeatType2 Cancel':
				zoomType2 = false;
			case 'zoomBeatType3 Cancel':
				zoomType3 = false;
				
			case 'blackBars test':
				blackBars(1);
				
			case 'cancel blackbars':
				blackBars(0);
				
			case 'blackBars2 test':
				pushBlackBars2(1);
				
			case 'cancel blackbars2':
				pushBlackBars2(0);
				
			case 'defaultCamZoom':
			    var val1:Float = Std.parseFloat(value1);
				defaultCamZoom = val1;
				
			case 'Tween Zoom':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				
				tweenZoomEvent = FlxTween.tween(FlxG.camera, {zoom: val1}, val2 * playbackRate, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn)
					{
						defaultCamZoom = val1;
					},
				});
				
			case 'cancel Tween Zoom':
				
				if (tweenZoomEvent != null) tweenZoomEvent = null;
				
			case 'Flash Camera BLACK':
				var val2:Float = Std.parseFloat(value2);
				if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.BLACK, val2);
				
			case 'Flash Camera WHITE':
				var val2:Float = Std.parseFloat(value2);
				if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, val2);
				
			case 'Flash Camera RED':
				var val2:Float = Std.parseFloat(value2);
				if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.RED, val2);
				
			case 'Screen Flip X':
				camGame.angle = 270;
				camHUD.angle = 270;
				
			case 'Screen Flip Y':
				camGame.angle = 180;
				camHUD.angle = 180;
			case 'Xx_FancyPants_xX':
				punchFancy();
				
			case 'Virabot Attack':
				virabotAttack();
				
			case 'Kaboom':
				kaboomEnabled = true;

			case 'change notes type 1': //I need to fix this
				var silly = 2;
				if (value1 == 'bf') silly = 0;
				if (value1 == 'dad') silly = 1;
				if (silly != 2){
					notesFunny1[silly] = !notesFunny1[silly];
				}else{
					notesFunny1[0] = !notesFunny1[0];
					notesFunny1[1] = !notesFunny1[1];
				}

				var power = Std.parseInt(value2);
				switch(value1)
				{
					case 'dad':
						if (notesFunny1[silly] != true) power = -power;
						for (i in 0... opponentStrums.members.length)
						{
							opponentStrums.members[i].y = Std.int(normalThingOrShit[i+4] + power*Math.sin(i*100));
						}
					case 'bf':
						if (notesFunny1[silly] != true) power = -power;
						for (i in 0...playerStrums.members.length)
						{
							playerStrums.members[i].y = Std.int(normalThingOrShit[i] + power*Math.sin(i*100));
							trace(Std.int(normalThingOrShit[i] + power*Math.sin(i*100)));
						}
					default:
						for (i in 0... strumLineNotes.length)
						{
							if (i < 4){
								if (notesFunny1[0] != true) power = -power;
								strumLineNotes.members[i].y = Std.int(normalThingOrShit[i] + power*Math.sin(i*100));
							}else{
								if (notesFunny1[1] != true) power = -power;
								strumLineNotes.members[i].y = Std.int(normalThingOrShit[i] + power*Math.sin(i*100));
							}
						}
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true, skipMoveCam);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false, skipMoveCam);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool, ?skip:Bool = false)
	{
		if (!skip){
			if(isDad)
			{
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
				camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
				tweenCamIn();
			}
			else
			{
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
				
				if (bf2 != null || bf3 != null)
				{
					if (SONG.notes[curSection].bf2Section)
					{
						camFollow.set(bf2.getMidpoint().x - 100, bf2.getMidpoint().y - 100);
						camFollow.x -= bf2.cameraPosition[0];
						camFollow.y += bf2.cameraPosition[1];
					}
					else if (SONG.notes[curSection].bf3Section)
					{
						camFollow.set(bf3.getMidpoint().x - 100, bf3.getMidpoint().y - 100);
						camFollow.x -= bf3.cameraPosition[0];
						camFollow.y += bf3.cameraPosition[1];
					}
				}

				if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
				{
					cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
						function (twn:FlxTween)
						{
							cameraTwn = null;
						}
					});
				}
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.stop();
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		if (timeBar != null) timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		if(isStoryMode && storyPlaylist.length <= 1 && SONG.song.toLowerCase() == 'end process') {
			CoolUtil.songsUnlocked.data.mainWeek = true;

			CoolUtil.songsUnlocked.flush();
		}

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new TCOStoryState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					showHUDTween(0, 1);
					showCamOtherTween(1, 0);
					inCutscene = true;
					FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
					{
						cancelMusicFadeTween();
				
						LoadingState.loadAndSwitchState(new CutsceneState(SONG.song, true, function()
						{
							LoadingState.loadAndSwitchState(new CutsceneState(PlayState.storyPlaylist[0], false, function()
							{
								LoadingState.loadAndSwitchState(new PlayState());
							}), true);
							
						}));
					});

					if (oldSongs)
					{
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camGame];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camGame];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (combo > 9)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camGame];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);
				
			var scaleX = numScore.scale.x;
			var scaleY = numScore.scale.y;
			
		    numScore.scale.x *= 1.25;
			numScore.scale.y *= 0.75;

			if (ClientPrefs.scoreZoom) numScoreTween = FlxTween.tween(numScore, {"scale.x": scaleX, "scale.y": scaleY}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);
		
		var scaleX = rating.scale.x;
		var scaleY = rating.scale.y;
		
		rating.scale.scale(1.1);
		comboSpr.scale.scale(1.1);
		
		if(ratingTween != null) {
			ratingTween.cancel();
		}
		
		if(comboTween != null) {
			comboTween.cancel();
		}
		

		if (ClientPrefs.scoreZoom) ratingTween = FlxTween.tween(rating, {"scale.x": scaleX, "scale.y": scaleY}, 0.1 / playbackRate, {ease: FlxEase.quadOut});
				FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
					startDelay: Conductor.crochet * 0.001 / playbackRate
		});
		
		/*oh yeah the og code its from andromeda engine i didn't made it lol
		 * https://github.com/nebulazorua/andromeda-engine
		 * go support andromeda engine*/

		if (ClientPrefs.scoreZoom) comboTween = FlxTween.tween(comboSpr, {"scale.x": scaleX, "scale.y": scaleY}, 0.1 / playbackRate, {ease: FlxEase.quadOut});
		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped && modchartTimers["disable" + Std.string(epicNote.noteData)] == null) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit
				&& modchartTimers["disable" + Std.string(daNote.noteData)] == null) {
					goodNoteHit(daNote);
				}
			});

			if (parsedHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
			
			if (bf2 != null || bf3 != null)
			{
				if (bf2.animation.curAnim != null && bf2.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * bf2.singDuration && bf2.animation.curAnim.name.startsWith('sing') && !bf2.animation.curAnim.name.endsWith('miss'))
				{
					bf2.dance();
				}
				if (bf3 != null && bf3.animation.curAnim != null && bf3.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * bf3.singDuration && bf3.animation.curAnim.name.startsWith('sing') && !bf3.animation.curAnim.name.endsWith('miss'))
				{
					bf3.dance();
				}
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;

		if(daNote.noteType == 'Tdl note'){
			FlxG.sound.play(Paths.sound("darkLordAttack"));

			boyfriend.playAnim('hurt', true);
			boyfriend.specialAnim = true;
		}
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}
		if(daNote.tscNote) {
			char = bf2;
		}
		if(daNote.greenNote) {
			char = bf3;
		}

		if(char != null && (!daNote.noMissAnimation || char == bf2) && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), Std.string(daNote.noteData), daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;
			
		switch(dad.curCharacter)
		{
			case 'the-chosen-one':
				
				if ((!FlxG.fullscreen || !Application.current.window.maximized) && !SONG.notes[curSection].bf2Section) setCamShake([camHUD, camGame], 0.015, 0.05, 0.005);
				else if (!SONG.notes[curSection].bf2Section) setCamShake([camHUD, camGame, camBars, camOther], 0.015, 0.05, 0.0045);

				if (healthBar.percent > 10 && !SONG.notes[curSection].bf2Section) healthDrainRates(0, 0.02, 0.045);
				
			case 'angry-minus-tco':
				if (!FlxG.fullscreen || !Application.current.window.maximized) setCamShake([camGame], 0.015, 0.05, 0.005);
				else setCamShake([camGame, camBars, camOther], 0.015, 0.05, 0.005);
			case 'the-dark-lord':
				if (healthBar.percent > 10) healthDrainRates(0.005, 0.015, 0.023);
			case 'joe-rombie':
				var mult:Float = 1;
				if (note.isSustainNote) mult = 0.3;
				if (healthBar.percent > 10) healthDrainRates(0.01 * mult, 0.03 * mult, 0.04 * mult);
		}

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null && !slashing)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if(note.tscNote) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

			bf2.playAnim(animToPlay, true);
			bf2.holdTimer = 0;
		}
		
		switch(note.noteType)
		{
			case 'GF Lyric Note':
				switch(dad.animation.curAnim.name)
				{
					case 'singLEFT' | 'singLEFT-alt':
						if (textNoTween != null) remove(textNoTween);
						dialogOnSongNoTween('Left.', 2, FlxColor.PINK);
					case 'singRIGHT' | 'singRIGHT-alt':
						if (textNoTween != null) remove(textNoTween);
						dialogOnSongNoTween('Right.', 2, FlxColor.RED);
					case 'singUP' | 'singUP-alt':
						if (textNoTween != null) remove(textNoTween);
						dialogOnSongNoTween('Up.', 2, FlxColor.GREEN);
					case 'singDOWN' | 'singDOWN-alt':
						if (textNoTween != null) remove(textNoTween);
						dialogOnSongNoTween('Down.', 2, FlxColor.CYAN);
						
				}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
							
						case 'Fire Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
						case 'stopwatch':
							var funnyBackInTime:Int = Std.int(Math.max(12500, Conductor.songPosition - 10000));

							startOnTime = funnyBackInTime;
							timeTravelHP = health;
							timeTraveled = true;
							funnyArray = [sicks, goods, bads, shits, songMisses, songScore-3000, songHits];
							ratingPercentTT = ratingPercent;
							PauseSubState.restartSong(true);
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				if(note.greenNote)
				{
					if(bf3 != null)
					{
						bf3.playAnim(animToPlay + note.animSuffix, true);
						bf3.holdTimer = 0;
					}
				}
				else if (!controlDad || !note.tscNote && !note.greenNote)
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}
				
				if (controlDad)
				{
					dad.playAnim(animToPlay + note.animSuffix, true);
					dad.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(note.tscNote)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
				if(bf2 != null)
				{
					bf2.playAnim(animToPlay + note.animSuffix, true);
					bf2.holdTimer = 0;
				}
			}
			
			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}

			switch(note.noteType){
				case 'Tdl note':
					FlxG.sound.play(Paths.sound("darkLordAttack"));

					boyfriend.playAnim('dodge', true);
					boyfriend.specialAnim = true;
				case 'demonetization brah':
					strikes++;

					songScore -= 2500 * strikes;

					var char:Character = boyfriend; //fun fact: boyfriend is the only one getting strikes because it's his youitube channel

					if(char != null && (!note.noMissAnimation || char == bf2) && char.hasMissAnimations)
					{
						var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + 'miss' + note.animSuffix;
						char.playAnim(animToPlay, true);
						char.specialAnim = true;
					}

					if (strikesTxt != null) strikesTxt.text = 'Strikes: ' + strikes;
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}
		
		if (babyArrowCamGame)
		{
			opponentStrums.forEach(function(spr:StrumNote) {
			    spr.cameras = [camGame];
				spr.scrollFactor.set(1, 0);
				spr.angle -= 270;
			});
						
			for (note in unspawnNotes)
			{
				if (!note.mustPress)
				{
					note.cameras = [camGame];
					note.scrollFactor.set (1, 0);
					note.angle -= 270;
				}
			}
			for (note in notes)
			{
				if (!note.mustPress)
				{
					note.cameras = [camGame];
					note.scrollFactor.set (1, 0);
					note.angle -= 270;
				}
			}
		}
		
		switch (SONG.song.toLowerCase())
		{
			case 'cubify':
				switch(curStep)
				{
					case 640:
						whiteScreen.alpha = 1;
						boyfriendGroup.alpha = 0;
						iconP1.alpha = 0;
						playerStrums.forEach(function(spr:StrumNote) spr.alpha = 0);
						
					case 768:
						FlxTween.tween(dadGroup, {alpha:1}, 0.5);
						FlxTween.tween(boyfriendGroup, {alpha:0}, 0.5);
						FlxTween.tween(iconP1, {alpha:0}, 0.5);
						FlxTween.tween(iconP2, {alpha:1}, 0.5);
						opponentStrums.forEach(function(spr:StrumNote)  FlxTween.tween(spr, {alpha:1}, 0.5));
						playerStrums.forEach(function(spr:StrumNote)  FlxTween.tween(spr, {alpha:0}, 0.5));
						
					case 700 | 828:
						playerStrums.forEach(function(spr:StrumNote)  FlxTween.tween(spr, {alpha:1}, 0.5));
						
						
					case 704 | 832:
						FlxTween.tween(boyfriendGroup, {alpha:1}, 0.5);
						FlxTween.tween(dadGroup, {alpha:0}, 0.5);
						FlxTween.tween(iconP1, {alpha:1}, 0.5);
						FlxTween.tween(iconP2, {alpha:0}, 0.5);
						opponentStrums.forEach(function(spr:StrumNote)  FlxTween.tween(spr, {alpha:0}, 0.5));
					case 896:
						FlxG.camera.fade(FlxColor.BLACK, 1, false);
						FlxTween.tween(camHUD, {alpha:0}, 1.5, {ease: FlxEase.circOut});
					case 912:
						whiteScreen.alpha = 0;
						FlxG.camera.fade(FlxColor.BLACK, 0, true);
						dadGroup.alpha = 1;
						opponentStrums.forEach(function(spr:StrumNote) spr.alpha = 1);
						camHUD.alpha = 1;
				}
			case 'adobe':
				switch(curStep)
				{
					case 256:
						flash(0xFFFFFFFF, 1);
					case 576:
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5);
					case 768:
						flash(0xFFFFFFFF, 1);
						FlxG.camera.shake(0.0175, 0.15);
						blackBars(1);
						colorTween([gf, dad, Crowd, Background1, Floor], 0.7, FlxColor.WHITE, 0xFF191919);
						spotlightdad.alpha = 0.8;
						spotlightbf.alpha = 0.8;
						bestPart2 = true;
					case 1024:
						flash(0xFFFFFFFF, 1);
						colorTween([gf, dad, boyfriend, Crowd, Background1, Floor], 0.7, 0xFF191919, FlxColor.WHITE);
						blackBars(0);
						spotlightdad.alpha = 0;
						spotlightbf.alpha = 0;
						bestPart2 = false;
				}
				
			case 'outrage':
				switch(curStep)
				{
					case 1 | 8 | 16 | 32 | 40 | 48 | 64 | 72 | 80 | 96 | 104 | 112:
						if(ClientPrefs.flashing || !ClientPrefs.lowQuality) FlxG.camera.fade(FlxColor.BLACK, 0.5, false);
					case 120:
						FlxG.camera.fade(FlxColor.BLACK, 0, true);

					case 767:
						tcoBSOD(true);
						redthing.color = 0xFFFFFFFF;
					case 1392:
						defaultCamZoom = 1.45;
						alphaTween([blackBG], 1, 0.75);
					case 1406:
						tcoStickPage(false);
						tcoBSOD(true);
						bsod.alpha = 1; //fixing the bug
						setAlpha([blackBG], 0);
						flash(0xFFFFFFFF, 1);
					case 1025 | 1670:
						tcoBSOD(false);
				}
				
			case 'end process':
				switch(curStep)
				{
					case 192:
						FlxG.camera.fade(FlxColor.BLACK, 1, true);
					case 833:
						showUpCorruptBackground(true);
						dad.color = 0xFF7A006A;
						boyfriend.color = 0xFF7B6CAD;
					case 1025:
						endProcessBSODS(true, 1);
						FlxTween.color(dad, 1, 0xFF7A006A, FlxColor.WHITE);
						FlxTween.color(boyfriend, 1, 0xFF7B6CAD, FlxColor.WHITE);
					case 1050:
						showUpCorruptBackground(false);
					case 1086:
						endProcessBSODS(false, 1);
					case 1344:
						endProcessBSODS(true, 2);
					case 1470:
						endProcessBSODS(false, 2);
				}

			case 'time travel':
				switch(curStep)
				{
					case 1:
						dialogOnSong('You want to learn how to time travel, I can sense it.', 3.3, 0xFFFFB300);
					case 36:
						boyfriend.playAnim('singUP', true);
					case 64:
						dialogOnSong("Well, I've been time traveling for years, but you look too inexperienced.", 3, 0xFFFFB300);
					case 105:
						dialogOnSong('Sorry, kiddo.', 1, 0xFFFFB300);
						
					case 116:
						blackBars(0);
						showHUDTween(1, 1);

						trace(Conductor.songPosition + 1000);
						
					case 1136:
						FlxTween.tween(this, {songLength: actualSongLength, timeBar: 1}, 3);
				}

			case 'contrivance':
				switch(curStep) {
						case 412:
							blackBars(1);
						case 416:
							FlxTween.tween(camHUD, {alpha: 0}, 1);
						case 418:
							dialogOnSong("So, you never give shit about what you do?", 7, 0xFF3A3A3A);
						case 446:
							dialogOnSong("Rapping out on randoms like you've never met them in life?", 7, 0xFF3A3A3A);
							for (i in 0...opponentStrums.length) {
								opponentStrums.members[i].visible = false;
								opponentStrums.members[i].x -= 1200;
							}
						case 476:
							blackBars(0);
							FlxTween.tween(camHUD, {alpha: 1}, 1);
							boyfriend.playAnim('hey', true);
							boyfriend.specialAnim = true;
						case 482:
							dialogOnSong("Well, I'll tell you what", 1, 0xFF3A3A3A);
						case 494:
							dialogOnSong("ya better get off track.", 1.5, 0xFF3A3A3A);
						case 496:
							for (i in 0...opponentStrums.length) {
								opponentStrums.members[i].alpha = 0;
								opponentStrums.members[i].visible = true;
							}
						case 504:
							for (i in 0...opponentStrums.length) {
								if (!ClientPrefs.middleScroll) {
									FlxTween.tween(opponentStrums.members[i], {alpha: 1}, 1);
									FlxTween.tween(opponentStrums.members[i], {x: opponentStrums.members[i].x + 1200}, 2, {ease: FlxEase.sineInOut});
								}else{
									FlxTween.tween(opponentStrums.members[i], {alpha: 0.35}, 1);
									opponentStrums.members[i].x += 1200;
								}
							}
						case 1384:
							for (i in 0...opponentStrums.length) {
								FlxTween.tween(opponentStrums.members[i], {alpha: 0}, 1);
							}
						case 1392:
							dialogOnSong("AAA *helicopter noises*", 3, 0xFF3A3A3A);
						case 1416:
							dialogOnSong("Fuck this shit I'm off to read out error messages in my computer.", 7, 0xFF3A3A3A);
						case 1454:
							dialogOnSong("Now,", 2, 0xFF3A3A3A);
						case 1466:
							dialogOnSong("get out!", 7, 0xFF3A3A3A);
				}

			case 'messenger':
				switch(curStep)
				{
					case 640 | 784:
						colorTween([aolBG, aolBack, aolFloor], 0.8, FlxColor.WHITE, 0xFF2C2425);
					case 656:
						aolBG.color = FlxColor.WHITE;
						aolFloor.color = FlxColor.WHITE;
						aolBack.color = FlxColor.WHITE;
					case 792 | 920 | 1112:
						moveCamera(true);
					case 858 | 984:
						moveCamera(false);
						
					case 1184:
						aolBG.color = 0xFF2C2425;
						aolFloor.color = 0xFF2C2425;
						aolBack.color = 0xFF2C2425;
						particleEmitter.alpha.set(1, 1);
						veryEpicVignette.alpha = 1;
					case 1312:
						camFollow.x = 1150;
						camFollow.y = 550;
						isCameraOnForcedPos = true;
					case 1376:
						isCameraOnForcedPos = false;
					case 1440:
						colorTween([aolBG, aolBack, aolFloor], 0.8, 0xFF2C2425, FlxColor.WHITE);
						particleEmitter.alpha.set(0, 0);
						veryEpicVignette.alpha = 0;
				}
			case 'phantasm':
				switch(curStep)
				{
					case 1:
						FlxG.camera.fade(FlxColor.BLACK, 15, true);
						triggerEventNote('Tween Zoom', '0.7', '15');
						isCameraOnForcedPos = true;
						camFollow.x = boyfriendCameraOffset[0] + 1200;
						camFollow.y -= 50;
						
					case 112:
						FlxG.camera.fade(FlxColor.BLACK, 0, false);
						
					case 128:
						FlxG.camera.fade(FlxColor.BLACK, 0, true);
						isCameraOnForcedPos = false;
						defaultCamZoom = 0.7;
						
					case 384 | 768 | 1151 | 1172 | 1282 | 1536 | 1922 | 1937 | 1943 | 1956:
						controlDad = true;
						
						barDirection = RIGHT_TO_LEFT;
						objectColor([Floor, Background1, whiteScreen], 0xFF2C2425);
						setAlpha([redthing], 1);
						setVisible([fires1, fires2], true);
						
					case 640 | 1024 | 1154 | 1176 | 1408 | 1792 | 1926 | 1940 | 1946 | 1960:
						controlDad = false;
						
						barDirection = LEFT_TO_RIGHT;
						objectColor([Floor, Background1, whiteScreen], FlxColor.WHITE);
						setAlpha([redthing], 0);
						setVisible([fires1, fires2], false);
				}
				
			case 'fancy funk':
				switch(curStep)
				{
					case 448:
						iconP2.alpha = 1;
					case 507 | 571 | 1595 | 1659:
						showHUDTween(0, 0.3);
						//dadGroup.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
						//dadGroup.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
					case 511 | 575 | 1599 | 1663:
						showHUDTween(1, 0.3);
					case 704 | 1920:
						showHUDTween(0, 1);
						FlxG.camera.fade(FlxColor.BLACK, 1, false);
					case 768:
						FlxG.camera.fade(FlxColor.BLACK, 1, true);
						showHUDTween(1, 1);
				}
			case 'tune in':
				switch(curStep)
				{
					case 639:
						//thanks ne_eo
						skipMoveCam = true;

						triggerEventNote('Camera Follow Pos', Std.string(dad.getMidpoint().x + 600), Std.string(dad.getMidpoint().y + 150));

						ytBGVideo.alpha = 1;

						videoTI = new MP4Handler();
						videoTI.playVideo(Paths.video('tunein_vidbg'), true);
						videoTI.visible = false;
						videoTI.volume = 0;
						FlxG.stage.removeEventListener('enterFrame', @:privateAccess videoTI.update);
				}
		}
		
		if (kaboomEnabled)
		{
			if (curStep % 4 == 0)
			{
				FlxTween.tween(camHUD, {y: -6 * intensity2}, Conductor.stepCrochet * 0.002, {ease: FlxEase.circOut});
				FlxTween.tween(camGame.scroll, {y: 12}, Conductor.stepCrochet * 0.002, {ease: FlxEase.sineIn});
			}
			if (curStep % 4 == 2)
			{
				FlxTween.tween(camHUD, {y: 0}, Conductor.stepCrochet * 0.002, {ease: FlxEase.sineIn});
				FlxTween.tween(camGame.scroll, {y: 0}, Conductor.stepCrochet * 0.002, {ease: FlxEase.sineIn});
			}
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}
		
		if (zoomType1)
		{
			FlxG.camera.zoom += 0.06;
			camHUD.zoom += 0.08;
		}
		
		if (curBeat % 2 == 0 && zoomType2)
		{
			FlxG.camera.zoom += 0.06;
			camHUD.zoom += 0.08;
		}

		if (curBeat % 1 == 0 && zoomType3)
		{
			FlxG.camera.zoom += 0.06;
			camHUD.zoom += 0.08;
		}
		
		if (curBeat % 1 == 0 && bestPart2)
		{
			if (SONG.song.toLowerCase() != 'adobe')
			{
				vignetteTrojan.alpha = 1;
				FlxTween.tween(vignetteTrojan, {alpha:0}, 0.2, {ease: FlxEase.quadInOut});
				
				if (curSong == 'trojan')
				{
					coolShit.alpha = 1;
					FlxTween.tween(coolShit, {alpha:0}, Conductor.crochet * 5, {ease: FlxEase.sineIn});
				}
			}
			else
			{
				vignetteSTI.alpha = 1;
				FlxTween.tween(vignetteSTI, {alpha:0}, 0.2);
			}
		}

		switch(SONG.song.toLowerCase())
		{
			case 'outrage':
				switch(curBeat)
				{
					case 32:
						flash(FlxColor.RED, 0.5);
						if (ClientPrefs.shaders) addShaderToCamera(['camgame', 'camhud'], new ChromaticAberrationEffect(0.0045));
						FlxG.camera.shake(0.01, 0.20);
						objectColor([boyfriend, gf, Floor, Background1, ScaredCrowd, whiteScreen], 0xFF2C2425);
						setAlpha([redthing], 1);
						setVisible([fires1, fires2], true);
						if (CoolUtil.difficultyString() != 'SIMPLE') lossingHealth = true;
						
					case 288:
						tcoStickPage(true);
						
					case 424:
						flash(FlxColor.WHITE, 0.5);
						FlxG.camera.shake(0.01, 0.20);
						colorTween([boyfriend, gf, Floor, Background1, ScaredCrowd, whiteScreen], 0.8, 0xFF2C2425, FlxColor.WHITE);
						lossingHealth = false;
				}
			case 'end process':
				switch(curBeat)
				{
					case 80:
						FlxTween.tween(newgroundsBurn, {y:newgroundsBurn.y +1000}, 2, {type:LOOPING});
						FlxTween.tween(twitterBurn, {y:twitterBurn.y +1000}, 2, {type:LOOPING});
						FlxTween.tween(googleBurn, {y:googleBurn.y +1000}, 2, {type:LOOPING});
					case 140:
						FlxG.sound.play(Paths.sound('intro3'), 0.6);
					case 141:
					//	ready();
					case 142:
					//	set();
					case 143:
					//	go();	
					/*case 400:
						generateStaticArrows(0);
						generateStaticArrows(1);
						skipArrowStartTween = true;*/
					case 448:
						camFollow.x = 750;
						camFollow.y = 350;
						isCameraOnForcedPos = true;
						defaultCamZoom = 0.6;
						FlxTween.tween(camHUD, {alpha:0}, 1);
					case 456:
						FlxG.camera.fade(FlxColor.BLACK, 2, false);
				}
			case 'trojan':
				switch(curBeat)
				{
					case 64 | 224 | 320:
						bestPart2 = true;
						//blackBars(1);
						colorTween([gf, alanBG, tscseeing, sFWindow, adobeWindow, daFloor], 0.1, FlxColor.WHITE, 0xFF191919);
						/*babyArrowCamGame = true;
						opponentStrums.forEach(function(spr:StrumNote) {
							spr.x = 1050 + 112 * spr.ID;
						});*/
						
					case 96 | 256:
						vignetteTrojan.alpha = 0;
						coolShit.alpha = 0;
						bestPart2 = false;
						//blackBars(0);
						colorTween([gf, alanBG, tscseeing, sFWindow, adobeWindow, daFloor], 0.8, 0xFF191919, FlxColor.WHITE);
						/*babyArrowCamGame = false;
						FlxG.camera.filtersEnabled = false;

						opponentStrums.forEach(function(spr:StrumNote) {
							spr.angle = 0;
						});
									
						for (note in unspawnNotes)
						{
							if (!note.mustPress)
							{
								note.angle = 0;
							}
						}
						for (note in notes)
						{
							if (!note.mustPress)
							{
								note.angle = 0;
							}
						}*/
					case 384:
						colorTween([gf, alanBG, tscseeing, sFWindow, adobeWindow, daFloor], 0.8, 0xFF191919, FlxColor.WHITE);
						//blackBars(0);
				}
				
			case 'conflict':
				switch(curBeat)
				{
					case 1:
						lossingHealth = true;
					case 96:
						tcoBSOD(true);
					case 192:
						blackBG.alpha = 0;
						tcoBSOD(true);
						clearShaderFromCamera(['camgame', 'camhud']);
						if (ClientPrefs.shaders) camGame.setFilters([new ShaderFilter(endingShader.shader)]);
					    if (ClientPrefs.shaders) camHUD.setFilters([new ShaderFilter(endingShader.shader)]);
						redthing.alpha = 1;
						
					case 128 | 324:
						tcoBSOD(false);
					case 325:
						FlxTween.tween(camHUD, {alpha:0}, 1, {ease: FlxEase.sineInOut});
					case 188:
						alphaTween([blackBG], 1, 0.3);
						colorTween([boyfriend], 0.3, 0xFF191919, FlxColor.WHITE);
						FlxTween.tween(redthing, {alpha:0}, 0.3, {ease: FlxEase.sineInOut});
					case 332:
						FlxG.camera.fade(FlxColor.BLACK, 0, false);
						camBars.flash(FlxColor.WHITE, 0.85);
						redthing.alpha = 0;
				}
				
			case 'dashpulse':
				switch(curBeat)
				{
					case 28 | 84:
						FlxTween.tween(FlxG.camera, {zoom:1.3}, 1.5, {ease: FlxEase.sineInOut});
					case 99:
						FlxTween.tween(FlxG.camera, {zoom:FlxG.camera.zoom - 0.2}, 3, {ease: FlxEase.sineInOut});
					case 256:
						colorTween([gf, otakuBG], 0.7, FlxColor.WHITE, 0xFF191919);
						defaultCamZoom = 1.1;
						bestPart2 = true;
						
					case 320:
						colorTween([gf, otakuBG], 1, 0xFF191919, FlxColor.WHITE);
						defaultCamZoom = 0.7;
						bestPart2 = false;
				}
				
			case 'amity':
				switch(curBeat)
				{
					case 1:
						FlxG.camera.fade(FlxColor.BLACK, 3, true);
						triggerEventNote('Tween Zoom', '0.65', '10');
						
					case 32:
						isCameraOnForcedPos = false;
						FlxTween.tween(camHUD, {alpha:1}, 1); //showhud shit doesn't work
					case 128 | 160 | 384 | 416:
						changeBetweenMinusTCO(true);
					case 144 | 192 | 400 | 444:
						changeBetweenMinusTCO(false);
					case 448:
						camChar.fade(FlxColor.BLACK, 1, true);
						dadGroup.cameras = [camChar];
						boyfriendGroup.cameras = [camChar];
						clearShaderFromCamera(['camgame']);
						if (ClientPrefs.shaders) camChar.setFilters([new ShaderFilter(nightTimeShader.shader), new ShaderFilter(new BBPANZUBloomShader())]);
						setAlpha([blackBG], 1);
						
						boyfriend.y -= 170;
						dad.y += 20;
						
						boyfriend.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
						dad.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
						
					case 480:
						boyfriend.acceleration.y = FlxG.random.int(200, 300) * playbackRate;
						boyfriend.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
						
						dad.acceleration.y = FlxG.random.int(200, 300) * playbackRate;
						dad.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
						
						FlxTween.tween(dad, {alpha:0}, 1.5);
						FlxTween.tween(boyfriend, {alpha:0}, 1.5);
						FlxTween.tween(camHUD, {alpha:0}, 1);
				}
				
			case 'aurora':
				switch(curBeat)
				{
					case 1:
						FlxG.camera.fade(FlxColor.BLACK, 2, true);
						triggerEventNote('Tween Zoom', '0.53', '5.3');
						
					case 16:
						FlxTween.tween(camHUD, {alpha:1}, 1);
						isCameraOnForcedPos = false;
				}
				
			case 'tune in':
				switch(curBeat)
				{
					case 40:
						iconP3.visible = true;
						iconP4.visible = true;
						bf2.alpha = 1;
						bf3.alpha = 1;

					case 159:
						

					case 160:
						//radialLine.alpha = 1;
						colorTween([ytBG], 0.8, FlxColor.WHITE, 0xFF2C2425);
						redthing.alpha = 0;

					case 224:
						ytBGVideo.alpha = 0;

						triggerEventNote('Camera Follow Pos', '', '');
				}
			case 'unfaithful':
				switch(curBeat)
				{
					case 160:
						//if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(rainbowShader.shader)]);
						//if (ClientPrefs.shaders) camHUD.setFilters([new ShaderFilter(rainbowShader.shader)]);
						bestPart2 =  true;
					case 224:
						FlxG.camera.fade(FlxColor.BLACK, 1, false);
					case 240:
						FlxG.camera.fade(FlxColor.BLACK, 1, true);
						clearShaderFromCamera(['camgame', 'camhud']);
				}
			case 'rombie':
				switch(curBeat)
				{
					case 8:
						dad.visible = true;
						iconP2.visible = true;
						reloadHealthBarColors();

						triggerEventNote('Camera Follow Pos', '', '');

					case 168:
						colorTween([rombBG, boyfriend, dad], 0.45, FlxColor.WHITE, 0xFF1F3054);
					case 296:
						colorTween([boyfriend, dad], 0.85, 0xFF1F3054, FlxColor.WHITE);
					case 360:
						objectColor([boyfriend, dad, iconP1, iconP2], FlxColor.BLACK);
						setAlpha([whiteScreen], 1);
						healthBar.createFilledBar(FlxColor.WHITE, FlxColor.WHITE);
					case 392:
						objectColor([boyfriend, dad], 0xFF1F3054);
						objectColor([iconP1, iconP2], 0xFFFFFFFF);
						setAlpha([whiteScreen], 0);
						reloadHealthBarColors();
				}
			case 'catto':
				switch(curBeat)
				{
					case 96:
						FlxTween.tween(camHUD, {alpha:1}, 1);
						FlxTween.tween(topBarsALT, {y: topBarsALT.y - 450}, 0.4, {ease:FlxEase.smoothStepInOut});
						FlxTween.tween(bottomBarsALT, {y: bottomBarsALT.y + 450}, 0.4, {ease:FlxEase.smoothStepInOut});
					case 156:
						opponentStrums.forEach(function(spr:StrumNote) FlxTween.tween(spr, {alpha:0}, 1));
						FlxTween.tween(topBarsALT, {y: topBarsALT.y + 450}, 0.4, {ease:FlxEase.smoothStepInOut});
						FlxTween.tween(bottomBarsALT, {y: bottomBarsALT.y - 450}, 0.4, {ease:FlxEase.smoothStepInOut});
						
					case 160:
						opponentStrums.forEach(function(spr:StrumNote) FlxTween.tween(spr, {alpha:1}, 1));
						
					case 260:
						topBarsALT.alpha = 0;
						bottomBarsALT.alpha = 0;
				}
			case 'kickstarter':
				switch(curBeat)
				{
					case 576:
						if (ClientPrefs.shaders) colorTween([bgKickstarter], 0.7, FlxColor.WHITE, 0xFF6E6E6E); //it looks bad without shaders
					case 384:
						blackBars(1);
					case 448:
						blackBars(0);
				}
		}

		if (curBeat % 4 == 0) // icon bop coollll shittt t t t t 
		{
			FlxTween.angle(iconP1, -30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.angle(iconP2, -30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
		}
		
		var funny:Float = (healthBar.percent * 0.01) + 0.01;

		iconP1.setGraphicSize(Std.int(iconP1.width + (50 * funny)),Std.int(iconP2.height - (25 * funny)));
		iconP2.setGraphicSize(Std.int(iconP1.width + (50 * funny)), Std.int(iconP2.height - (25 * funny)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			case 'adobe':
				if(!ClientPrefs.lowQuality) {
					switch (SONG.song.toLowerCase())
					{
						case 'adobe':
							if (curBeat % 1 == 0 && Crowd != null) setDance([Crowd], true);
						case 'end process':
							if (curBeat % 2 == 0 && virabot1 != null && virabot2 != null && virabot3 != null
							&& virabot4 != null) setDance([virabot1, virabot2, virabot3, virabot4], true);
					}
				}
				
			case 'alan-pc-virabot':
				if (!ClientPrefs.lowQuality) {
					if (curBeat % 2 == 0) setDance([tscseeing], true);
				}
				
			case 'yt':
				if (curBeat % bf2.danceEveryNumBeats == 0 && bf2.animation.curAnim != null && !bf2.animation.curAnim.name.startsWith('sing') && !bf2.stunned)
				{
					bf2.dance();
				}
				if (curBeat % bf3.danceEveryNumBeats == 0 && bf3.animation.curAnim != null && !bf3.animation.curAnim.name.startsWith('sing') && !bf3.stunned)
				{
					bf3.dance();
				}
				
			case 'flashBG':
				if (curBeat % bf2.danceEveryNumBeats == 0 && bf2.animation.curAnim != null && !bf2.animation.curAnim.name.startsWith('sing') && !bf2.stunned)
				{
					bf2.dance();
				}
				
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}
		
		if (bestPart2 && curBeat % 1 == 0 && !noCurLight)
		{
			curLight = FlxG.random.int(0, LightsColors.length - 1, [curLight]);
			vignetteTrojan.color = LightsColors[curLight];
			
			if(curSong == 'trojan') coolShit.color = LightsColors[curLight];
		}


		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		
		if (kaboomEnabled)
		{
			if (curBeat % 2 == 0)
			{
				angleshit = anglevar;
			}
			else
			{
				angleshit = -anglevar;
			}
			
			camHUD.angle = angleshit * intensity2;
			camGame.angle = angleshit * intensity2;
			FlxTween.tween(camHUD, {angle: angleshit * intensity}, Conductor.stepCrochet * 0.002, {ease: FlxEase.circOut});
			FlxTween.tween(camHUD, {x: -angleshit * intensity}, Conductor.crochet * 0.001, {ease: FlxEase.linear});
			FlxTween.tween(camGame, {angle: angleshit * intensity}, Conductor.stepCrochet * 0.002, {ease: FlxEase.circOut});
			FlxTween.tween(camGame, {x: -angleshit * intensity}, Conductor.crochet * 0.001, {ease: FlxEase.linear});
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}';
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ !ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end
	
	override function switchTo(state:FlxState){
		// DO CLEAN-UP HERE!!
		if(curSong == 'end process'){
			FlxG.mouse.unload();
			FlxG.mouse.visible = false;
		}

		if(oldVideoResolution){
			Lib.application.window.resizable = true;
			FlxG.scaleMode = new RatioScaleMode(false);
			FlxG.resizeGame(1280, 720);
			FlxG.resizeWindow(1280, 720);
			camGame.width = 1280;
			camGame.height = 720;
		}

		return super.switchTo(state);
	}

	function punchFancy(){
		boyfriend.playAnim('pre-attack', true);
		boyfriend.specialAnim = true;
		FlxTween.tween(boyfriend, {x: boyfriend.x - dad.x}, 0.3, {ease: FlxEase.sineInOut,
			onComplete: function(twn:FlxTween)
			{
				boyfriend.playAnim('attack', true);
				dad.playAnim('dou', true);
				boyfriend.specialAnim = true;
				dad.specialAnim = true;
				
				FlxG.sound.play(Paths.sound('throwMic'));
				
				FlxTween.tween(dad, {x: dad.x - 150}, 0.75, {ease: FlxEase.sineInOut});
				
				FlxTween.angle(dad, 0, 0, 0.5, {ease: FlxEase.cubeInOut});
				
				FlxTween.tween(boyfriend, {x: boyfriend.x + 400}, 0.7, {ease: FlxEase.sineInOut});

				FlxTween.tween(dad, {y: dad.y - 450}, 0.3, {ease: FlxEase.sineInOut,
					onComplete: function(twn:FlxTween)
					{
						//boyfriend.playAnim('attack', true);
						FlxTween.tween(dad, {y: dad.y + 450}, 0.4, {ease: FlxEase.sineInOut,
							onComplete: function(twn:FlxTween)
							{
								dad.specialAnim = false;
							}
					    });
					}
				});
			}
		});
	}
	
	function virabotAttack()
	{
		dodged = false;
		
		dad.playAnim('throw', true);
		dad.specialAnim = true;
		
		if (dad.animation.curAnim.finished)	dad.specialAnim = false;
		
		new FlxTimer().start(0.4, function(timer:FlxTimer)
		{
			if (dodged)
			{
		        boyfriend.playAnim('dodge');
			    boyfriend.specialAnim = true;
			
			    if (boyfriend.animation.curAnim.finished) boyfriend.specialAnim = false;
			}
			else
			{
				health -= 0.5;
			}
			
		});
	}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
