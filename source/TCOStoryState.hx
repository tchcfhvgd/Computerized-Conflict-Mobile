package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import Shaders;
import flixel.math.FlxMath;
import openfl.Lib;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import WeekData;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class TCOStoryState extends MusicBeatState
{
	var scoreText:FlxText;
	var weekName:FlxText;
	var bgSprite:FlxSprite;
	var fires:FlxSprite;
	var scrollingThing:FlxBackdrop;
	var upperBar:FlxSprite;
	var downBar:FlxSprite;
	var circleTiles:FlxSprite;
	var songsBG:FlxSprite;
	var weekImages:FlxSprite;
	var diff:String;
	var txtTracklist:FlxText;
	var sprDifficulty:FlxSprite;
	var spikes1:FlxBackdrop;
	var spikes2:FlxBackdrop;

	public var camGame:FlxCamera;
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUD:FlxCamera;

	var selectedSmth:Bool = false;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 0;
	//var curDifficulty2:Int = 0;
	var onInsane:Bool =  false;
	var outline:FlxSprite;
	public static var crtShader = new CRTShader();
	var shaderFilter = new ShaderFilter(crtShader);

	var difficulties:Array<String> = [
	    'Simple',
		'Hard',
		'Insane'
	];

	var checkpointSystemON:Bool;

	var blackThing:FlxSpriteExtra;
	var text:FlxText;

	var weeks:Array<WeekInfo> = [];

	var chapterThingyText:FlxText;

	var finishedZoom:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode", null);
		#end

		weeks = [
			new WeekInfo('week 1', ['Adobe', 'Outrage', 'End Process'], 'Episode 1: Computer Breakdown'),
		];

		PlayState.isStoryMode = true;

		Lib.application.window.title = "Computerized Conflict - Story Menu - Theme by: DangDoodle";

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.add(camHUD, false);

		checkpointSystemON = FlxG.save.data.checkpoint != null;
		trace(checkpointSystemON);
		trace(FlxG.save.data.checkpoint);

		FlxG.camera.zoom = 1.5;
		camHUD.zoom = 1.5;

		bgSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/week1BG'));
		bgSprite.updateHitbox();
		bgSprite.screenCenter();
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		
		scrollingThing = new FlxBackdrop(Paths.image('storymenu/scroll'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.8));
		scrollingThing.alpha = 0.85;
		
		circleTiles = new FlxSprite().loadGraphic(Paths.image('storymenu/circlesTiles'));
		circleTiles.updateHitbox();
		circleTiles.screenCenter();
		circleTiles.antialiasing = ClientPrefs.globalAntialiasing;
		
		fires = new FlxSprite();
		fires.frames = Paths.getSparrowAtlas('storymenu/StoryMenuFire');
		fires.animation.addByPrefix('tCoGoesInsane', 'StoryMenuFire', 24, true);
		fires.animation.play('tCoGoesInsane');
		fires.setGraphicSize(Std.int(fires.width * 0.9));
		fires.updateHitbox();
		fires.screenCenter();
		fires.y += 200;
		fires.alpha = 0;
		fires.antialiasing = ClientPrefs.globalAntialiasing;

		spikes1 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes1.y -= 60;
		spikes1.scrollFactor.set(0, 0);
		spikes1.flipY = true;
		
		upperBar = new FlxSprite().loadGraphic(Paths.image('storymenu/upperBar'));
		upperBar.updateHitbox();
		upperBar.screenCenter();
		upperBar.antialiasing = ClientPrefs.globalAntialiasing;
		
		spikes2 = new FlxBackdrop(Paths.image('mainmenu/spikes'), X, 0, 0);
		spikes2.y += 630;
		spikes2.scrollFactor.set(0, 0);
		
		songsBG = new FlxSprite().loadGraphic(Paths.image('storymenu/songBG'));
		songsBG.updateHitbox();
		songsBG.x = 0;
		songsBG.y = FlxG.height - songsBG.height - 90;
		songsBG.antialiasing = ClientPrefs.globalAntialiasing;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		chapterThingyText = new FlxText(10, 15, 0, weeks[0].desc, 36);
		chapterThingyText.setFormat("VCR OSD Mono", 32);
		
		txtTracklist = new FlxText(FlxG.width * 0.05, songsBG.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.color = 0xFFe55777;

		txtTracklist.text = 'Tracks:';
		txtTracklist.font = 'Small Print.ttf';
		for (i in 0...weeks[0].songs.length)
		{
			txtTracklist.text = txtTracklist.text + '\n' + weeks[0].songs[i];
			txtTracklist.updateHitbox();
		}
		//TO DO: FIX THIS
		txtTracklist.y = songsBG.y + (songsBG.height - txtTracklist.height) / 2;
		txtTracklist.x -= 20;
		
		add(bgSprite);
		add(scrollingThing);
		add(circleTiles);
		add(fires);
		add(spikes1);
		add(upperBar);
		add(spikes2);
		add(songsBG);
		add(scoreText);
		add(chapterThingyText);
		add(txtTracklist);

		var difficultyText = new Alphabet(50, 100, 'Difficulty:', false);
		difficultyText.fontColor = 0xFFFFFFFF;
		difficultyText.outline = 10;
		difficultyText.outlineColor = 0xFF000000;
		add(difficultyText);

		difficultyText.outlineCameras = [camGame];
		//difficultyText.cameras = [camHUD];

		sprDifficulty = new FlxSprite(150, 200);
		add(sprDifficulty);

		weekImages = new FlxSprite();
		add(weekImages);
		
		if (checkpointSystemON)
		{
			blackThing = new FlxSpriteExtra().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackThing.alpha = 0.7;
			blackThing.screenCenter();
			blackThing.cameras = [camHUD];
			add(blackThing);
			
			text = new FlxText(0, 250, FlxG.width, 'Looks like you left the game before,\nbut your progress has been saved.\n\nWould you like to continue?');
			text.setFormat(Paths.font("phantommuff.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
			text.cameras = [camHUD];
			add(text);
			
			//checkpointSelect();
		}

		trace(diff);

		changeDifficulty();

		super.create();

		if (ClientPrefs.shaders) FlxG.camera.setFilters([shaderFilter]);
		if (ClientPrefs.shaders) camHUD.setFilters([shaderFilter]);

		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.expoIn});
		FlxTween.tween(camHUD, {zoom: 1}, 0.8, {ease: FlxEase.expoIn});
		camHUD.fade(FlxColor.BLACK, 0.8, true, function()
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
		
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
		
		scoreText.text = "WEEK SCORE:" + lerpScore;
		scoreText.screenCenter(X);
		scoreText.y = FlxG.height - scoreText.height - 15;

		chapterThingyText.x = FlxG.width - chapterThingyText.width - 60;

		if (!selectedSmth && finishedZoom)
		{
			if (controls.BACK)
			{
				if (!checkpointSystemON){
					FlxG.sound.play(Paths.sound('cancelMenu'));

					FlxTween.tween(FlxG.camera, {zoom: -2}, 1.5, {ease: FlxEase.expoIn});
					FlxTween.tween(camHUD, {zoom: -2}, 1.5, {ease: FlxEase.expoIn});
					camHUD.fade(FlxColor.BLACK, 0.8, false, function()
					{
						MusicBeatState.switchState(new MainMenuState());
					});

				}else{
					checkpointSystemON = false;
					FlxG.save.data.checkpoint = null;
					FlxG.save.flush();
					
					FlxTween.tween(blackThing, {alpha: 0}, 1, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(blackThing);
							blackThing.destroy();
						}
					});

					FlxTween.tween(text, {alpha: 0}, 1, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(text);
							text.destroy();
						}
					});
				}
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDifficulty(1);
			}
			else if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDifficulty(-1);
			}
			else if (controls.ACCEPT)
			{
				if (!checkpointSystemON){
					selectedSmth = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(FlxG.camera, {zoom: 3}, 1, {ease: FlxEase.expoIn});
					FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
					{
						playSongs(weeks[0].songs, 0, 0, curDifficulty);
					});
				}else{
					checkpointSystemON = false;
					selectedSmth = true;
					
					/*FlxTween.tween(blackThing, {alpha: 0}, 1, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(blackThing);
							blackThing.destroy();
						}
					});

					FlxTween.tween(text, {alpha: 0}, 1, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(text);
							text.destroy();
						}
					});*/

					playSongs(FlxG.save.data.checkpoint.playlist, FlxG.save.data.checkpoint.campaignScore, FlxG.save.data.checkpoint.campaignMisses, FlxG.save.data.checkpoint.difficulty);
				}
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
	}
	
	function optionSelect(change:Int = 0):Void
	{
		//
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = difficulties.length-1;
		if (curDifficulty >= difficulties.length)
			curDifficulty = 0;

		var diff:String = difficulties[curDifficulty];

		sprDifficulty.loadGraphic(Paths.image('storymenu/difficult/${diff}'));
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		sprDifficulty.x = 40;
		sprDifficulty.y = 230;

		weekImages.loadGraphic(Paths.image('storymenu/chapterImages/w1-${diff}'));
		weekImages.screenCenter();
		weekImages.antialiasing = ClientPrefs.globalAntialiasing;
		weekImages.setGraphicSize(Std.int(weekImages.width * 0.9));

		switch(curDifficulty)
		{
			case 0:
				FlxG.cameras.flash(FlxColor.BLACK, 0.50);
				fires.alpha = 0;
				if (onInsane) FlxTween.color(bgSprite, 1, FlxColor.WHITE, FlxColor.WHITE);
				if (!onInsane) bgSprite.color = FlxColor.WHITE;
				onInsane = false;
				bgSprite.alpha = 1;
				FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume * 1);
			case 1:
				FlxG.cameras.flash(FlxColor.WHITE, 0.50);
				fires.alpha = 0;
				if (onInsane) FlxTween.color(bgSprite, 1, FlxColor.WHITE, FlxColor.WHITE);
				if (!onInsane) bgSprite.color = FlxColor.WHITE;
				onInsane = false;
				bgSprite.alpha = 1;
				FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume * 1);
			case 2:
		        FlxG.cameras.flash(FlxColor.RED, 0.50);
				fires.alpha = 1;
				onInsane = true;
				if (onInsane) FlxTween.color(bgSprite, 1, FlxColor.WHITE, 0xFF2C2425);
				FlxG.sound.music.fadeOut(1, FlxG.sound.music.volume * 0);
				if (onInsane) FlxG.sound.play(Paths.sound('fire'), 1, false);
		}
		
		lastDifficultyName = diff;

		#if !switch
		//intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
		
		trace(diff);
	}
	
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	
	/*function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}*/

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

    public function clearShaderFromCamera(cam:String){


		switch(cam.toLowerCase()) {
			case 'camgame':
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.setFilters(newCamEffects);
		}
    }

    function playSongs(songlist:Array<String>, campaignScore:Int, campaignMisses:Int, difficultyStory:Int)
    {
		PlayState.storyPlaylist = songlist;
		PlayState.isStoryMode = true;
		PlayState.vaultSong = false;
		PlayState.storyDifficulty = difficultyStory;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-' + difficulties[difficultyStory], PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = campaignScore;
		PlayState.campaignMisses = campaignMisses;
	    PlayState.storyWeek = 1;
		PlayState.seenCutscene = false;
		PlayState.weekNames = 'Episode 1: Computer Breakdown';
		LoadingState.loadAndSwitchState(new PlayState(), true);

		FreeplayState.destroyFreeplayVocals();
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
	}
}

class WeekInfo
{
	public var name:String = "";
	public var songs:Array<String> = [];
	public var desc:String = "";

	public function new(name:String, songs:Array<String>, desc:String)
	{
		this.name = name;
		this.songs = songs;
		this.desc = desc;
	}
}