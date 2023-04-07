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
import sys.FileSystem;
import sys.io.File;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxInputText;

class VaultState extends MusicBeatState
{
	var tipPopUp:FlxSprite;
	var convertPopUp:FlxSprite;
	var glitchBG:FlxSprite;
	var daStatic:FlxSprite;
    var barTitle:FlxSprite;
	var downBarText:FlxSprite;
	var vignette:FlxSprite;
	var vignette2:FlxSprite;
	var selectedSmth:Bool = false;
	var inputText:FlxInputText;
	var coolDown:Bool = true;
	var scrollingThing:FlxBackdrop;
	var modesText:FlxText;
	var curDifficulty = 1;

	public static var codesAndShit:Array<Array<String>> = [
		['videos', 'Tune In'], 
		['hatred', 'Unfaithful'],
		['joe', 'Rombie'],
		['world1', 'Fancy Funk'],
		['skrunkly', 'catto']
	];

	var isWriting:Bool = false;
	var letterWritten:String;
	
	override public function create()
	{
		Paths.clearStoredMemory();
		WeekData.reloadWeekFiles(false);
		
		glitchBG = new FlxSprite().loadGraphic(Paths.image('vault/glitchBG'));
		glitchBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(glitchBG);
		
		scrollingThing = new FlxBackdrop(Paths.image('FAMenu/scroll'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.8));
		scrollingThing.alpha = 0.5;
		//add(scrollingThing);
		
		vignette2 = new FlxSprite().loadGraphic(Paths.image('vault/vig2'));
		vignette2.antialiasing = ClientPrefs.globalAntialiasing;
		add(vignette2);
		
		daStatic = new FlxSprite().loadGraphic(Paths.image('vault/static'));
		daStatic.antialiasing = ClientPrefs.globalAntialiasing;
		add(daStatic);
		
		downBarText = new FlxSprite(0, 150).loadGraphic(Paths.image('vault/downBarText'));
		downBarText.antialiasing = ClientPrefs.globalAntialiasing;
		downBarText.alpha = 0;
		add(downBarText);
		
		barTitle = new FlxSprite(0, -150).loadGraphic(Paths.image('vault/barTitle'));
		barTitle.antialiasing = ClientPrefs.globalAntialiasing;
		barTitle.alpha = 0;
		add(barTitle);
		
		vignette = new FlxSprite().loadGraphic(Paths.image('vault/blueVig'));
		vignette.antialiasing = ClientPrefs.globalAntialiasing;
		add(vignette);
		
		tipPopUp = new FlxSprite(250, 0).loadGraphic(Paths.image('vault/tip'));
		tipPopUp.antialiasing = ClientPrefs.globalAntialiasing;
		tipPopUp.alpha = 0;
		add(tipPopUp);
		
		convertPopUp = new FlxSprite(-250, 0).loadGraphic(Paths.image('vault/convertToSymbol'));
		convertPopUp.antialiasing = ClientPrefs.globalAntialiasing;
		convertPopUp.alpha = 0;
		add(convertPopUp);
		
		inputText = new FlxInputText(235, 326, FlxG.width, "", 20, FlxColor.BLACK, FlxColor.TRANSPARENT, true);
		inputText.setFormat(Paths.font("tahoma.ttf"), 20, FlxColor.BLACK, FlxTextBorderStyle.OUTLINE,FlxColor.TRANSPARENT);
		inputText.hasFocus = true;
		inputText.maxLength = 32;
		inputText.borderSize = 0.1;
		add(inputText);
		
		modesText = new FlxText(FlxG.width * 0.7, 5, 0, "", 42);
		modesText.setFormat(Paths.font("Small Print.ttf"), 42, FlxColor.WHITE, CENTER);
		modesText.y += 580;
		modesText.x -= 730;
		modesText.alpha = 1;
		add(modesText);
		
		inputText.callback = function(text, action)
		{
			if (action == 'enter')
			{
				if (controls.ACCEPT && !selectedSmth)
				{
					for (i in 0...codesAndShit.length){
						if (text.toLowerCase() == codesAndShit[i][0]){
							trace('the code ' + codesAndShit[i][0] + ' is correct and it unlocks the song ' + codesAndShit[i][1] + '!');

							CoolUtil.songsUnlocked.data.songs.set(codesAndShit[i][1], true);
							CoolUtil.songsUnlocked.flush();


							PlayState.storyPlaylist = [codesAndShit[i][1]];
							PlayState.isStoryMode = false;

							PlayState.storyDifficulty = curDifficulty;

							PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());
							
							selectedSmth = true;

							LoadingState.loadAndSwitchState(new PlayState(), true);
							FreeplayState.destroyFreeplayVocals();
						}
					}
				}
			}
			isWriting = true;
		}
		
		if(FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('secret_menu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 1);
		}
		
		FlxTween.tween(barTitle, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(barTitle, {y: 0}, 0.4, {ease:FlxEase.smoothStepInOut});
		
		FlxTween.tween(downBarText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(downBarText, {y: 0}, 0.4, {ease:FlxEase.smoothStepInOut});
		
		FlxTween.tween(tipPopUp, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.1});
		FlxTween.tween(tipPopUp, {x: 0}, 0.4, {ease:FlxEase.smoothStepInOut,
			onComplete: function(tween:FlxTween)
			{
				FlxTween.tween(tipPopUp, {y: tipPopUp.y + 15}, 3, {ease:FlxEase.smoothStepInOut, type: PINGPONG});
			}
		});
		
		FlxTween.tween(convertPopUp, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.1});
		FlxTween.tween(convertPopUp, {x: 0}, 0.4, {ease:FlxEase.smoothStepInOut});
		
		new FlxTimer().start(0.4, function(lol:FlxTimer)
		{
			coolDown = false;
		});
		
		FlxG.mouse.visible = true;
		FlxG.mouse.unload();
		FlxG.mouse.load(Paths.image("EProcess/alt", 'chapter1').bitmap, 1.5, 0);
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		//scrollingThing.x -= 0.45;
		//scrollingThing.y -= 0.16;
		
		if (!selectedSmth && !coolDown)
		{
			if (FlxG.keys.justPressed.ANY) FlxG.sound.play(Paths.sound('keyboardPress'));
			
			if (controls.BACK && !isWriting)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				Paths.clearUnusedMemory();
				selectedSmth = true;
				escapeTween();
			}
		}

		isWriting = false;

		super.update(elapsed);
	}
	
	function escapeTween()
	{
		FlxTween.tween(barTitle, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(barTitle, {y: -150}, 0.4, {ease:FlxEase.smoothStepInOut});
		
		FlxTween.tween(downBarText, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(downBarText, {y: 150}, 0.4, {ease:FlxEase.smoothStepInOut});
		
		FlxTween.tween(tipPopUp, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(tipPopUp, {x: 250}, 0.4, {ease:FlxEase.smoothStepInOut});
		
		FlxTween.tween(convertPopUp, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.1});
		FlxTween.tween(convertPopUp, {x: -250}, 0.4, {ease:FlxEase.smoothStepInOut});
	}
}