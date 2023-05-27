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
	var border:FlxSprite;
	var bgSpriteFire:FlxSprite;
	var chosenOne:FlxSprite;
	var fires:FlxSprite;
	var sprDifficulty:FlxSprite;
	var diff:String;
	var scrollingThing:FlxBackdrop;
	var vignette:FlxSprite;

	public var camGame:FlxCamera;
	public var camGameShaders:Array<ShaderEffect> = [];

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
		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		border = new FlxSprite().loadGraphic(Paths.image('storymenu/ui/border'));
		border.updateHitbox();
		border.screenCenter();
		border.antialiasing = ClientPrefs.globalAntialiasing;
		border.color = 0xFF111111;

		outline = new FlxSprite().loadGraphic(Paths.image('storymenu/ui/outline'));
		outline.updateHitbox();
		outline.screenCenter();
		outline.antialiasing = ClientPrefs.globalAntialiasing;

		vignette = new FlxSprite().loadGraphic(Paths.image('storymenu/ui/vignette'));
		vignette.updateHitbox();
		vignette.screenCenter();
		vignette.antialiasing = ClientPrefs.globalAntialiasing;

		scrollingThing = new FlxBackdrop(Paths.image('Main_Checker'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.color = 0xFF0E0E0E;

		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.8));

		bgSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/ui/week1BG'));
		bgSprite.updateHitbox();
		bgSprite.screenCenter();
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		//fuck

		chosenOne = new FlxSprite();
		chosenOne.frames = Paths.getSparrowAtlas('storymenu/tcoStoryMode');
		chosenOne.animation.addByPrefix('simple', 'ChosenSimple', 24, true);
		chosenOne.animation.addByPrefix('hard', 'ChosenHard', 24, true);
		chosenOne.animation.addByPrefix('insane', 'ChosenInsane', 24, true);
		chosenOne.animation.play('simple');
		chosenOne.setGraphicSize(Std.int(chosenOne.width * 0.8));
		chosenOne.updateHitbox();
		chosenOne.screenCenter();
		chosenOne.y += 100;
		chosenOne.x += 270;
		chosenOne.antialiasing = ClientPrefs.globalAntialiasing;

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

		add(border);
		add(scrollingThing);
		add(outline);
		add(vignette);
		add(bgSprite);
		add(fires);
		add(chosenOne);

		sprDifficulty = new FlxSprite();
		add(sprDifficulty);

		//CoolUtil.difficulties = CoolUtil.storyDifficulties.copy();

		/*if(lastDifficultyName == '')
		{
			for(i in 0...difficulties.length) lastDifficultyName = difficulties[i];
		}
		for(i in 0...difficulties.length) curDifficulty = Math.round(Math.max(0, difficulties[i].indexOf(lastDifficultyName)));*/

		//curDifficulty2 = Math.round(Math.max(0, CoolUtil.storyDifficultiesCOPY.indexOf(lastDifficultyName)));

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
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
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
				selectedSmth = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
				FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
				{
					playSongs(['adobe', 'outrage', 'end process']);
				});
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
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

		var offsetX:Int = 0;
		var offsetY:Int = 0;

		if(diff == 'Hard') {offsetX = 105; offsetY = -125;}
		if(diff == 'Insane') {offsetY = -160; offsetX = -75;}

		sprDifficulty.x = FlxG.width / 3 - sprDifficulty.width + offsetX;
		sprDifficulty.y = FlxG.height / 3 - sprDifficulty.height + offsetY;

		chosenOne.screenCenter();

		switch(curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('intro');
				FlxG.cameras.flash(FlxColor.BLACK, 0.50);
				chosenOne.animation.play('simple');
				chosenOne.y += 100;
				chosenOne.x += 270;
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
				chosenOne.animation.play('hard');
				chosenOne.y += 100;
				chosenOne.x += 290;
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
				chosenOne.animation.play('insane');
				chosenOne.y -= 50;
				chosenOne.x += 270;
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

    function playSongs(songlist:Array<String>)
    {
		PlayState.storyPlaylist = songlist;
		PlayState.isStoryMode = true;
		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-' + lastDifficultyName, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;
	    PlayState.storyWeek = 1;
		PlayState.seenCutscene = false;
		PlayState.weekNames = 'Chapter 1:';
		LoadingState.loadAndSwitchState(new PlayState(), true);

		FreeplayState.destroyFreeplayVocals();
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
	}
}