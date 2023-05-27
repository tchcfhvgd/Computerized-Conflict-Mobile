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
import Controls;

using StringTools;

class ModOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Mod Settings';
		rpcTitle = 'TCO Mod Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Language:',
			"Select the language you want the mod to have\n(Just works with in-game text).",
			'language',
			'string',
			'English',
			['English', 'Español', 'Portuguese']);
		addOption(option);

		var option:Option = new Option('Shaders',
			"If unchecked, shaders will not appear in-game\n(Recommended if you have an AMD Graphics Card).",
			'shaders',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Enable Lane Underlay',
			"Enables a black underlay behind the notes\nfor better reading!\n(Similar to Funky Friday's Scroll Underlay or osu!mania's thing)",
			'laneunderlay',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Lane Underlay Transparency',
			'Set the Lane Underlay Transparency (Lane Underlay must be enabled)',
			'laneTransparency',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Mechanics:',
			"Select the language you want the mod to have (Just works with in-game text).",
			'mechanics',
			'string',
			'Enabled',
			['None', 'Just Actual Mechanics', 'Just Note Mechanics', 'Enabled']);
		addOption(option);

		super();
	}

	var changedMusic:Bool = false;

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}