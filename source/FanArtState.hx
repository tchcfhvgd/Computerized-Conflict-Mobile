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
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import flixel.addons.display.FlxBackdrop;

class FanArtState extends MusicBeatState
{
	public var image:FlxSprite;
	public var coolArtistArray:Array<String> = [];
	public var actualNum = 0;

	var selectedSmth:Bool = false;
	var vignette:FlxSprite;
	var colorTween:FlxTween;
	var firstImage:Float = 0;
	var bgText:FlxSprite;
	var textArtists:FlxText;
	var scrollingThing:FlxBackdrop;
	var vignette2:FlxSprite;
	var downBar:FlxSprite;
	var textSquare:FlxSprite;
	var menuText:FlxSprite;
	var arrow:FlxSprite;
	var flippedArrow:FlxSprite;
	var coolDown:Bool = true;

	var totalMap:Map<String, Int> = [];

	override public function create()
	{
		Paths.clearStoredMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Art Gallery", null);
		#end

		Lib.application.window.title = "Computerized Conflict - Art Gallery Menu - Theme by: DangDoodle";

		var thing:Array<String> = FileSystem.readDirectory('assets/images/fan-arts/ingame-fanart');
		for (i in 0...thing.length){
			coolArtistArray.push(thing[i]);
		}

		FlxG.camera.zoom = 2;

		scrollingThing = new FlxBackdrop(Paths.image('FAMenu/scroll'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.8));
		scrollingThing.antialiasing = ClientPrefs.globalAntialiasing;
		add(scrollingThing);

		vignette = new FlxSprite().loadGraphic(Paths.image('FAMenu/vignette'));
		vignette.scrollFactor.set();
		vignette.antialiasing = ClientPrefs.globalAntialiasing;
		add(vignette);

		vignette2 = new FlxSprite().loadGraphic(Paths.image('FAMenu/vig2'));
		vignette2.scrollFactor.set();
		vignette2.antialiasing = ClientPrefs.globalAntialiasing;
		add(vignette2);

		downBar = new FlxSprite(0, 794).loadGraphic(Paths.image('FAMenu/downBar'));
		downBar.scrollFactor.set();
		downBar.antialiasing = ClientPrefs.globalAntialiasing;
		downBar.alpha = 0.00001;
		add(downBar);

		textSquare = new FlxSprite(250, 0).loadGraphic(Paths.image('FAMenu/squaretext'));
		textSquare.scrollFactor.set();
		textSquare.antialiasing = ClientPrefs.globalAntialiasing;
		textSquare.alpha = 0.000001;
		add(textSquare);

		menuText = new FlxSprite(0, -150).loadGraphic(Paths.image('FAMenu/art-gallery-bar'));
		menuText.scrollFactor.set();
		menuText.antialiasing = ClientPrefs.globalAntialiasing;
		menuText.alpha = 0.00001;
		add(menuText);

		image = new FlxSprite();
		image.antialiasing = ClientPrefs.globalAntialiasing;
		add(image);

		bgText = new FlxSprite(0, 0).loadGraphic(Paths.image('FAMenu/artist-text-BG'));
		bgText.scrollFactor.set();
		bgText.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgText);

		textArtists = new FlxText(45, 30, 0, 'null', 46);
		textArtists.setFormat(Paths.font("phantommuff.ttf"), 46, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textArtists.scrollFactor.set();
		textArtists.antialiasing = ClientPrefs.globalAntialiasing;
		add(textArtists);

		arrow = new FlxSprite(815, 250);
		arrow.frames = Paths.getSparrowAtlas('FAMenu/arrows');
		arrow.animation.addByPrefix('idle', 'arrow0', 24, false);
		arrow.animation.addByPrefix('smash', 'arrow press', 24, false);
		arrow.setGraphicSize(Std.int(arrow.width * 0.55));
		arrow.scrollFactor.set();
		arrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrow);

		flippedArrow = new FlxSprite(-15, 250);
		flippedArrow.frames = Paths.getSparrowAtlas('FAMenu/arrows');
		flippedArrow.animation.addByPrefix('idle', 'arrow0', 24, false);
		flippedArrow.animation.addByPrefix('smash', 'arrow press', 24, false);
		flippedArrow.setGraphicSize(Std.int(flippedArrow.width * 0.55));
		flippedArrow.scrollFactor.set();
		flippedArrow.flipX = true;
		flippedArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(flippedArrow);

		FlxG.mouse.visible = true;
		FlxG.mouse.unload();
		FlxG.mouse.load(Paths.image("EProcess/alt", 'chapter1').bitmap, 1.5, 0);
		@:privateAccess FlxG.mouse._cursor.smoothing = true;

		FlxTween.tween(menuText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(menuText, {y: 0}, 0.4, {ease:FlxEase.smoothStepInOut});

		FlxTween.tween(downBar, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(downBar, {y: 644}, 0.4, {ease:FlxEase.smoothStepInOut});

		FlxTween.tween(textSquare, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.1});
		FlxTween.tween(textSquare, {x: 0}, 0.4, {ease:FlxEase.smoothStepInOut});

		var i:Int = 0;
		for(artist in coolArtistArray) {
			// TODO: Fixing this like what
			var total = FileSystem.readDirectory('assets/images/fan-arts/ingame-fanart/' + coolArtistArray[i] + '/').length;
			totalMap[artist] = total;
			trace(total);
			i++;
		}

		changeImage();


		super.create();

		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.expoIn});
		FlxG.camera.fade(FlxColor.BLACK, 0.9, true, function()
		{
			coolDown = false;
		});
	}

	override function update(elapsed:Float)
	{

		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;


		/*var thing = Std.int(textArtists.width) + 100;

		if (thing < 400) thing = 400;*/

		/*image.width = 400;
		image.height = 400;*/

		if (!selectedSmth && !coolDown)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));

				FlxTween.tween(FlxG.camera, {zoom: -2}, 1.5, {ease: FlxEase.expoIn});
				FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
				{
					MusicBeatState.switchState(new MainMenuState());
				});

				Paths.clearUnusedMemory();
				goodBye();
				selectedSmth = true;
			}

			if (controls.UI_RIGHT_P)
			{
				arrow.animation.play('smash');
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeImage(1);
			}
			else if (controls.UI_LEFT_P)
			{
				flippedArrow.animation.play('smash');
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeImage(-1);
			}
			else if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeNo(-1);
			}
			else if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeNo(1);
			}

			if (FlxG.mouse.overlaps(downBar) && FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('mouseClick'));

				CoolUtil.browserLoad('https://twitter.com/' + coolArtistArray[actualNum]);
			}
		}
		super.update(elapsed);

		image.screenCenter();
	}

	function changeImage(number:Int = 0)
	{
		actualNum += number;

		firstImage = 0;

		if (actualNum >= coolArtistArray.length)
			actualNum = 0;
		if (actualNum < 0)
			actualNum = coolArtistArray.length - 1;

		updateImage();
	}

	function changeNo(change:Int = 0)
	{
		var total = totalMap[coolArtistArray[actualNum]];
		trace(total, coolArtistArray[actualNum], actualNum, firstImage);

		firstImage += change;

		if(firstImage >= total)
			firstImage = 0;
		else if(firstImage < 0)
			firstImage = total - 1;

		updateImage();
	}

	function updateImage() {
		image.loadGraphic(Paths.image('fan-arts/ingame-fanart/' + coolArtistArray[actualNum] + '/' + (firstImage+1)));
		textArtists.text = '@' + coolArtistArray[actualNum];
	}

	function goodBye()
	{
		FlxTween.tween(menuText, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(menuText, {y: -150}, 0.4, {ease:FlxEase.smoothStepInOut});

		FlxTween.tween(downBar, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(downBar, {y: 794}, 0.4, {ease:FlxEase.smoothStepInOut});

		FlxTween.tween(textSquare, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.1});
		FlxTween.tween(textSquare, {x: 250}, 0.4, {ease:FlxEase.smoothStepInOut});
	}
}