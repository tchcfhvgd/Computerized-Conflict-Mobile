package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import haxe.Json;
import haxe.format.JsonParser;
import Alphabet;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets;

using StringTools;

// Gonna try to kind of make it compatible to Forever Engine,
// love u Shubs no homo :flushedh4:
typedef ScriptDialogueFile = {
	var dialogue:Array<ScriptDialogueLine>;
}

typedef ScriptDialogueLine = {
	var text:Null<String>;
	var speed:Null<Float>;
	var sound:Null<String>;
}

// TO DO: Clean code? Maybe? idk
class DialogueScript extends FlxSpriteGroup
{
	var dialogue:TypedAlphabet;
	var dialogueList:ScriptDialogueFile = null;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;
	var bgFade:FlxSprite = null;
	var textToType:String = '';

	var currentText:Int = 0;
	var offsetPos:Float = -600;
	public function new(dialogueList:ScriptDialogueFile, ?song:String = null)
	{
		super();

		if(song != null && song != '') {
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		
		bgFade = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		bgFade.scrollFactor.set();
		bgFade.visible = true;
		add(bgFade);

		this.dialogueList = dialogueList;
		
		daText = new TypedAlphabet(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, '');
		daText.scaleX = 0.7;
		daText.scaleY = 0.7;
		add(daText);

		startNextDialog();
	}

	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	public static var DEFAULT_TEXT_X = 175;
	public static var DEFAULT_TEXT_Y = 132;
	public static var LONG_TEXT_ADD = 24;
	var scrollSpeed = 4000;
	var daText:TypedAlphabet = null;
	var ignoreThisFrame:Bool = true; //First frame is reserved for loading dialogue images

	public var closeSound:String = 'dialogueClose';
	public var closeVolume:Float = 1;
	override function update(elapsed:Float)
	{
		if(ignoreThisFrame) {
			ignoreThisFrame = false;
			super.update(elapsed);
			return;
		}

		if(!dialogueEnded) {
			//bgFade.alpha += 0.5 * elapsed;
			if(bgFade.alpha > 1) bgFade.alpha = 1;

			if(PlayerSettings.player1.controls.ACCEPT) {
				if(!daText.finishedText) {
					daText.finishText();
					if(skipDialogueThing != null) {
						skipDialogueThing();
					}
				} else if(currentText >= dialogueList.dialogue.length) {
					dialogueEnded = true;
					
					if(daText != null)
					{
						daText.kill();
						remove(daText);
						daText.destroy();
					}
					FlxG.sound.music.fadeOut(1, 0);
				} else {
					startNextDialog();
				}
				FlxG.sound.play(Paths.sound(closeSound), closeVolume);
			}
			
		} else { //Dialogue ending

			if(bgFade != null) {
				bgFade.alpha -= 1 * elapsed;
				if(bgFade.alpha <= 0) {
					bgFade.kill();
					remove(bgFade);
					bgFade.destroy();
					bgFade = null;
				}
			}

			if(bgFade == null) {
				finishThing();
				kill();
			}
		}
		super.update(elapsed);
	}
	
	function startNextDialog():Void
	{
		var curDialogue:ScriptDialogueLine = null;
		do {
			curDialogue = dialogueList.dialogue[currentText];
		} while(curDialogue == null);

		if(curDialogue.text == null || curDialogue.text.length < 1) curDialogue.text = ' ';
		if(curDialogue.speed == null || Math.isNaN(curDialogue.speed)) curDialogue.speed = 0.05;
		
		var centerPrefix:String = '';

		daText.text = curDialogue.text;
		daText.sound = curDialogue.sound;
		if(daText.sound == null || daText.sound.trim() == '') daText.sound = 'dialogue';
		
		daText.y = DEFAULT_TEXT_Y;
		if (daText.rows > 2) daText.y -= LONG_TEXT_ADD;

		var rate:Float = 24 - (((curDialogue.speed - 0.05) / 5) * 480);
		if(rate < 12) rate = 12;
		else if (rate > 48) rate = 48;
		
		currentText++;

		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	public static function parseDialogue(path:String):ScriptDialogueFile {
		#if MODS_ALLOWED
		if(FileSystem.exists(path))
		{
			return cast Json.parse(File.getContent(path));
		}
		#end
		return cast Json.parse(Assets.getText(path));
	}
}
