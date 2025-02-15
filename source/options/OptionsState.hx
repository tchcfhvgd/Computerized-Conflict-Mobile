package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import openfl.Lib;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	var finishedZoom = false;

	function openSelectedSubstate(label:String) {
		removeTouchPad();
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var scrollingThing:FlxBackdrop;
	var spikes1:FlxBackdrop;
	var spikes2:FlxBackdrop;
	var vignette:FlxSprite;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		Lib.application.window.title = "Computerized Conflict - Options Menu - Theme by: DangDoodle";

		FlxG.camera.zoom = 3;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		scrollingThing = new FlxBackdrop(Paths.image('mainmenu/scroll'), XY, 0, 0);
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

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();

		addTouchPad("UP_DOWN", "A_B_X_Y");
		addTouchPadCamera();

		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.expoIn});
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true, function()
		{
			finishedZoom = true;
		});
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		removeTouchPad();
		addTouchPad("UP_DOWN", "A_B_X_Y");
		addTouchPadCamera();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;

		spikes1.x -= 0.45 * 60 * elapsed;
		spikes2.x -= 0.45 * 60 * elapsed;

		if(finishedZoom)
		{
			if (controls.UI_UP_P) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
			}
	
			if (controls.BACK) {
				finishedZoom = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(FlxG.camera, {zoom: -2}, 1.5, {ease: FlxEase.expoIn});
				FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function()
				{
					if(TitleState.instance.titleOptions) MusicBeatState.switchState(new TitleState());
					else MusicBeatState.switchState(new MainMenuState());
				});
			}
	
			if (controls.ACCEPT) {
				openSelectedSubstate(options[curSelected]);
			}

			if (touchPad != null && touchPad.buttonX.justPressed) {
			removeTouchPad();
			openSubState(new mobile.MobileControlSelectSubState());
			}

			if (touchPad != null && touchPad.buttonY.justPressed) {
			removeTouchPad();
			openSubState(new mobile.options.MobileOptionsSubState());
			}
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
