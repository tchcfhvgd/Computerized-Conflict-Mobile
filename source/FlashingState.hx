package;

import AttachedText;
import CheckboxThingie;
import options.Option;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.FlxCamera;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var warnText2:FlxText;

	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	var grpOptions:FlxTypedGroup<Alphabet>;
	var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	var grpTexts:FlxTypedGroup<AttachedText>;
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	override function create()
	{
		super.create();

		camGame = new FlxCamera();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 1;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Hey, watch out!\n
			This Mod contains some flashing lights,\n
			screen shake and shaders!",
			32);
		warnText.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		warnText.cameras = [camGame];
		add(warnText);

		warnText2 = new FlxText(0, 0, FlxG.width,
			"If you have a low end PC, it's not recommended to play this mod.\n
			Since it could present various bugs that could ruin your experience.",
			32);
		warnText2.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, CENTER);
		warnText2.screenCenter(Y);
		add(warnText2);
		warnText2.cameras = [camHUD];
		warnText2.alpha = 0;

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		var option:Option = new Option('Do Not Show Me This Again', "", 'shaders', 'bool', true);
		addOption(option);

		var option:Option = new Option('Flashing Lights', "", 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option('Screen Shake', "", 'screenShake', 'bool', true);
		addOption(option);

		var option:Option = new Option('Shaders', "", 'shaders', 'bool', true);
		addOption(option);



		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(150, 260, optionsArray[i].name, false);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
			optionText.yMult = 90;*/
			optionText.targetY = i;
			grpOptions.add(optionText);
			optionText.cameras = [camGame];

			var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
			checkbox.sprTracker = optionText;
			checkbox.ID = i;
			checkboxGroup.add(checkbox);
			checkbox.cameras = [camGame];
		}

		changeSelection();
		reloadCheckboxes();
	}

	var holdTime:Float = 0;
	var holdValue:Float = 0;
	override function update(elapsed:Float)
	{

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if(controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curOption.setValue((curOption.getValue() == true) ? false : true);
			curOption.change();
			reloadCheckboxes();
		}

		if(!leftState) {
			var space:Bool = FlxG.keys.justPressed.SPACE;
			if (space) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				goinToTitleState();
			}
		}
		super.update(elapsed);
	}

	public function addOption(option:Option) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
	}

	function clearHold()
	{
		if(holdTime > 0.5) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		holdTime = 0;
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		for (text in grpTexts) {
			text.alpha = 0.6;
			if(text.ID == curSelected) {
				text.alpha = 1;
			}
		}

		curOption = optionsArray[curSelected]; //shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}

	function goinToTitleState()
	{
		ClientPrefs.saveSettings();
		FlxG.sound.play(Paths.sound('confirmMenu'));

		FlxTween.tween(camGame, {alpha: 0}, 1, {
			onComplete: function(twn:FlxTween) {
		        FlxTween.tween(camHUD, {alpha: 1}, 1);
				new FlxTimer().start(5, function (tmr:FlxTimer) {
					FlxTween.tween(camHUD, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				});
			}
		});
	}
}
