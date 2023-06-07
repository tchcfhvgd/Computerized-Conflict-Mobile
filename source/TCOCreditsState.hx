package;

import flixel.FlxCamera;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import FreeplayMenu;
import flixel.FlxObject;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class TCOCreditsState extends MusicBeatState
{
	var credits:Array<CreditsMetadata> = [];

	var curSelected:Int = 0;

	var grpCredits:FlxTypedGroup<Alphabet>;

	var grpIcons:FlxTypedGroup<AttachedSprite>;

	var bg:FlxSprite;
	var scrollingThing:FlxBackdrop;
	var arrow:FlxSprite;
	var flippedArrow:FlxSprite;

	var outlineWidth:Float = 10;

	var camDefault:FlxCamera;
	var camTexts:FlxCamera;

	override function create()
	{
		persistentUpdate = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits Menu", null);
		#end

		camDefault = new FlxCamera();
		camTexts = new FlxCamera();
		camTexts.bgColor.alpha = 0;

		FlxG.cameras.reset(camDefault);
		FlxG.cameras.add(camTexts, false);

		CustomFadeTransition.nextCamera = camTexts;

		credits = [
			new CreditsMetadata("Jet", "jet", "Director, Concept Artist & Main Charter", 0xbd3185, ""),
			new CreditsMetadata("Jet", "jet", "Director 2"),
			new CreditsMetadata("Jet", "jet", "Director 3"),
			new CreditsMetadata("Jet", "jet", "Director 4"),
			new CreditsMetadata("Jet", "jet", "Director 5"),
			new CreditsMetadata("Jet", "jet", "Director 6"),
			new CreditsMetadata("Jet", "jet", "Director 7"),
		];

		bg = new FlxSprite().loadGraphic(Paths.image('creditsmenu/background'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		scrollingThing = new FlxBackdrop(Paths.image('creditsmenu/Main_Checker'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.alpha = 0.7;
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.4));
		scrollingThing.antialiasing = ClientPrefs.globalAntialiasing;
		add(scrollingThing);

		var vignette = new FlxSprite();
		vignette.loadGraphic(Paths.image('creditsmenu/ok'));
		vignette.scrollFactor.set();
		vignette.antialiasing = ClientPrefs.globalAntialiasing;
		add(vignette);

		grpCredits = new FlxTypedGroup<Alphabet>();
		add(grpCredits);
		grpIcons = new FlxTypedGroup<AttachedSprite>();
		add(grpIcons);

		var topbar = new FlxSprite();
		topbar.loadGraphic(Paths.image('creditsmenu/upperBar'));
		topbar.scrollFactor.set();
		topbar.antialiasing = ClientPrefs.globalAntialiasing;
		topbar.cameras = [camTexts];
		add(topbar);

		var creditsbar = new FlxSprite();
		creditsbar.loadGraphic(Paths.image('creditsmenu/creditsBar'));
		creditsbar.scrollFactor.set();
		creditsbar.x = FlxG.width - creditsbar.width;
		creditsbar.antialiasing = ClientPrefs.globalAntialiasing;
		creditsbar.cameras = [camTexts];
		add(creditsbar);

		var downBar = new FlxSprite();
		downBar.loadGraphic(Paths.image('creditsmenu/downBar'));
		downBar.scrollFactor.set();
		downBar.y = FlxG.height - downBar.height;
		downBar.antialiasing = ClientPrefs.globalAntialiasing;
		downBar.cameras = [camTexts];
		add(downBar);

		for (i in 0...credits.length)
		{
			var creditText = new Alphabet(200 + 40, 300, credits[i].name, false);
			creditText.fontColor = credits[i].color;
			creditText.isCreditItem = true;
			creditText.distancePerItem.x = 0;
			creditText.distancePerItem.y = 200;
			creditText.targetY = i;
			if(i == 0) {
				creditText.outline = outlineWidth;
			}
			creditText.snapToPosition();
			grpCredits.add(creditText);

			if(credits[i].color & 0xFFFFFF == 0xFFFFFF) {
				creditText.outlineColor = 0xFF000000;
			} else {
				creditText.outlineColor = 0xFFFFFFFF;
			}

			creditText.outlineCameras = [camDefault];
			creditText.cameras = [camTexts];

			var icon = new AttachedSprite("credits/" + credits[i].icon);
			icon.sprTracker = creditText.letters[0];
			icon.yAdd = -100;
			icon.xAdd = -320;
			icon.origin.set(280, 200);
			icon.antialiasing = ClientPrefs.globalAntialiasing;
			icon.cameras = [camTexts];
			grpIcons.add(icon);
		}

		/*arrow = new FlxSprite(1150, 593);
		arrow.frames = Paths.getSparrowAtlas('FAMenu/arrows');
		arrow.animation.addByPrefix('idle', 'arrow0', 24, false);
		arrow.animation.addByPrefix('smash', 'arrow press', 24, false);
		arrow.setGraphicSize(Std.int(arrow.width * 0.4));
		arrow.scrollFactor.set();
		arrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrow);

		flippedArrow = new FlxSprite(0, 593);
		flippedArrow.frames = Paths.getSparrowAtlas('FAMenu/arrows');
		flippedArrow.animation.addByPrefix('idle', 'arrow0', 24, false);
		flippedArrow.animation.addByPrefix('smash', 'arrow press', 24, false);
		flippedArrow.setGraphicSize(Std.int(flippedArrow.width * 0.4));
		flippedArrow.scrollFactor.set();
		flippedArrow.flipX = true;
		flippedArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(flippedArrow);*/

		changeSelection();

		super.create();
	}

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(credits.length > 1)
		{
			if (controls.UI_UP_P)
			{
				//flippedArrow.animation.play('smash');
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				//arrow.animation.play('smash');
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_UP_P || controls.UI_DOWN_P)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP_P ? -shiftMult : shiftMult));
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
			}
		}

		if(controls.ACCEPT && credits[curSelected].link.length > 0) {
			CoolUtil.browserLoad(credits[curSelected].link);
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			CustomFadeTransition.nextCamera = camTexts;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function tween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions) {
		if(Object == null) return;
		FlxTween.cancelTweensOf(Object);
		FlxTween.tween(Object, Values, Duration, Options);
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;
		if (curSelected >= credits.length)
			curSelected = 0;

		/*bg.loadGraphic(Paths.image('freeplayArt/freeplayImages/bgs/' + songs[curSelected].songName));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.screenCenter();*/

		for (i in 0...grpIcons.members.length)
		{
			tween(grpIcons.members[i], {"scale.x": 0.3, "scale.y": 0.3, xAdd: -320}, 0.2, {
				ease: FlxEase.quadOut
			});
		}

		tween(grpIcons.members[curSelected], {"scale.x": 1, "scale.y": 1, xAdd: -340}, 0.2, {
			ease: FlxEase.quadOut
		});

		for (i=>item in grpCredits.members)
		{
			var shit = i - curSelected;
			var scale = shit == 0 ? 1.5 : 0.75;
			var outline:Float = shit == 0 ? outlineWidth : 0;
			var outlineAlpha:Float = shit == 0 ? 1.0 : 0.0;

			item.textOffsetX = shit == 0 ? 120 : 0;
			tween(item, {scaleX: scale, "scale.y": scale, outline: outline, outlineAlpha: outlineAlpha}, 0.2, {
				ease: FlxEase.quadOut
			});

			item.targetY = shit;

			if (shit == 0) {
				item.alpha = 1;
			} else {
				item.alpha = 0.4;
			}
		}
	}
}

class CreditsMetadata
{
	public var name:String = "";
	public var icon:String = "";
	public var desc:String = "";
	public var color:FlxColor;
	public var link:String = "";

	public function new(name:String, icon:String, desc:String, color:FlxColor = 0xffffff, link:String = "")
	{
		this.name = name;
		this.icon = icon;
		this.desc = desc;
		this.color = color;
		this.link = link;
	}
}