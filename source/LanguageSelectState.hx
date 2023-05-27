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
import flixel.addons.display.FlxBackdrop;
import Shaders;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxAxes;
import flixel.math.FlxMath;

class LanguageSelectState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var scrollingThing:FlxBackdrop;
	public var repeatAxes:FlxAxes = XY;
	public static var curSelected:Int = 0;
	var stuff = 0.0;
	var camFollow:FlxObject;

	var languages:Array<String> = [
	    'spanish',
		'english',
		'portuguese'
	]; //on my way to add more (for v2)

	override function create()
	{

		var yScroll:Float = Math.max(0.25 - (0.05 * (languages.length - 4)), 0.1);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		scrollingThing = new FlxBackdrop(Paths.image('Main_Checker'), repeatAxes, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.alpha = 0.8;
		add(scrollingThing);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for(i in 0...languages.length) // main menu code copy so I can save time heheheha
		{
			var country:FlxSprite = new FlxSprite(0, 0);
			country.loadGraphic(Paths.image('languageImages/' + languages[i]));
			country.ID = i;
			menuItems.add(country);
			country.scrollFactor.set();
			country.antialiasing = ClientPrefs.globalAntialiasing;
			country.updateHitbox();
			country.screenCenter();
		}

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		stuff = elapsed;
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

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

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

						var daChoice:String = languages[curSelected];

						switch (daChoice)
						{
							case 'spanish':
								ClientPrefs.language == 'Español'; //why this doesn't work

							case 'english':
								ClientPrefs.language == 'English';

							case 'portuguese':
								ClientPrefs.language == 'Portuguese';
						}

						ClientPrefs.saveSettings();

						if(FlxG.save.data.language != null) {
							FlxG.save.data.language;

						}

						FlxG.save.flush();

						MusicBeatState.switchState(new FlashingState());
					});
			}
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.x = FlxMath.lerp(spr.x, ((spr.ID - curSelected) * 800) + (FlxG.height * 0.65), CoolUtil.boundTo(stuff * 9.6, 0, 1));
		});
	}

	function changeItem(huh:Int = 1)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0.5;
			spr.updateHitbox();

			FlxTween.tween(spr, {"scale.x": 1, "scale.y": 1}, 0.2, {ease: FlxEase.quadOut});

			if (spr.ID == curSelected)
			{
				FlxTween.tween(spr, {"scale.x": 1.1, "scale.y": 1.1}, 0.2, {ease: FlxEase.quadOut});

				spr.alpha = 1;
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}