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
	var sprDifficulty:FlxSprite;

	public var camGame:FlxCamera;
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUD:FlxCamera;

	var selectedSmth:Bool = false;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 0;
	//var curDifficulty2:Int = 0;
	var onInsane:Bool =  false;
	var outline:FlxSprite;

	var difficulties:Array<String> = [
	    'Simple',
		'Hard',
		'Insane'
	];

	var checkpointSystemON:Bool;

	var blackThing:FlxSpriteExtra;
	var text:FlxText;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode", null);
		#end

		PlayState.isStoryMode = true;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.add(camHUD, false);

		checkpointSystemON = FlxG.save.data.checkpoint != null;
		trace(checkpointSystemON);
		trace(FlxG.save.data.checkpoint);

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
		
		upperBar = new FlxSprite().loadGraphic(Paths.image('storymenu/upperBar'));
		upperBar.updateHitbox();
		upperBar.screenCenter();
		upperBar.antialiasing = ClientPrefs.globalAntialiasing;
		
		downBar = new FlxSprite().loadGraphic(Paths.image('storymenu/downBar'));
		downBar.updateHitbox();
		downBar.screenCenter();
		downBar.antialiasing = ClientPrefs.globalAntialiasing;
		
		songsBG = new FlxSprite().loadGraphic(Paths.image('storymenu/songBG'));
		songsBG.updateHitbox();
		songsBG.screenCenter();
		songsBG.antialiasing = ClientPrefs.globalAntialiasing;
		
		add(bgSprite);
		add(scrollingThing);
		add(circleTiles);
		add(fires);
		add(upperBar);
		add(downBar);
		add(songsBG);

		sprDifficulty = new FlxSprite(0, 200);
		add(sprDifficulty);
		
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
	}

	override function update(elapsed:Float)
	{

		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;

		if (!selectedSmth)
		{
			if (controls.BACK)
			{
				if (!checkpointSystemON){
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new MainMenuState());
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
				sprDifficulty.animation.play('bye');
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDifficulty(1);
			}
			else if (controls.UI_LEFT_P)
			{
				sprDifficulty.animation.play('bye');
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDifficulty(-1);
			}
			else if (controls.ACCEPT)
			{
				if (!checkpointSystemON){
					selectedSmth = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
					FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
					{
						playSongs(['adobe', 'outrage', 'end process'], 0, 0, curDifficulty);
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

		sprDifficulty.frames = Paths.getSparrowAtlas('storymenu/difficult/' + diff);
		sprDifficulty.animation.addByPrefix('diff', diff, 24, false);
		sprDifficulty.animation.addByPrefix('bye', 'Bye' + diff, 24, false);
		sprDifficulty.animation.addByPrefix('intro', 'Intro' + diff, 24, false);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		sprDifficulty.animation.play('intro');
		
		weekImages = new FlxSprite().loadGraphic(Paths.image('storymenu/chapterImages/w1-' + difficulties[curDifficulty]));
		weekImages.updateHitbox();
		weekImages.screenCenter();
		weekImages.antialiasing = ClientPrefs.globalAntialiasing;
		add(weekImages);

		var offsetX:Int = 0;
		var offsetY:Int = 0;

		if(diff == 'Hard') {offsetX = 105; offsetY = -125;}
		if(diff == 'Insane') {offsetY = -160; offsetX = -75;}

		sprDifficulty.x = FlxG.width / 3 - sprDifficulty.width + offsetX;
		sprDifficulty.y = FlxG.height / 3 - sprDifficulty.height + offsetY;

		switch(curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('intro');
				FlxG.cameras.flash(FlxColor.BLACK, 0.50);
				fires.alpha = 0;
				if (onInsane) FlxTween.color(bgSprite, 1, FlxColor.WHITE, FlxColor.WHITE);
				if (!onInsane) bgSprite.color = FlxColor.WHITE;
				onInsane = false;
				bgSprite.alpha = 1;
				if (ClientPrefs.shaders) removeShaderFromCamera('camgame', new ChromaticAberrationEffect(0.0045));
				clearShaderFromCamera('camgame');
				FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume * 1);
			case 1:
				sprDifficulty.animation.play('intro');
				FlxG.cameras.flash(FlxColor.WHITE, 0.50);
				fires.alpha = 0;
				if (onInsane) FlxTween.color(bgSprite, 1, FlxColor.WHITE, FlxColor.WHITE);
				if (!onInsane) bgSprite.color = FlxColor.WHITE;
				onInsane = false;
				bgSprite.alpha = 1;
				if (ClientPrefs.shaders) removeShaderFromCamera('camgame', new ChromaticAberrationEffect(0.0045));
				clearShaderFromCamera('camgame');
				FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume * 1);
			case 2:
				sprDifficulty.animation.play('intro');
		        FlxG.cameras.flash(FlxColor.RED, 0.50);
				fires.alpha = 1;
				onInsane = true;
				if (onInsane) FlxTween.color(bgSprite, 1, FlxColor.WHITE, 0xFF2C2425);
				if (ClientPrefs.shaders) addShaderToCamera('camgame', new ChromaticAberrationEffect(0.0045));
				FlxG.sound.music.fadeOut(1, FlxG.sound.music.volume * 0);
				if (onInsane) FlxG.sound.play(Paths.sound('fire'), 1, false);
		}
		lastDifficultyName = diff;
		trace(diff);
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