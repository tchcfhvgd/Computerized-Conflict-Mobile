package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['RESUME', 'RESTART SONG', 'CHANGE DIFFICULTY', 'EXIT TO MENU'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:FlxText;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	var scrollingThing:FlxBackdrop;
	var bar:FlxSprite;
	var vignette:FlxSprite;
	var portrait:FlxSprite;
	var pauseText:FlxSprite;
	var arrow:FlxSprite;
	var coolDown:Bool = true;
	//var botplayText:FlxText;
	var arrowTween:FlxTween;
	var selectTween:FlxTween;
	
	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');


		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);
		
		scrollingThing = new FlxBackdrop(Paths.image('pauseMenu/scroll'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.alpha = 0;
		scrollingThing.color = FlxColor.fromRGB(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1],
		PlayState.instance.dad.healthColorArray[2]);
		
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.8));
		add(scrollingThing);
		
		vignette = new FlxSprite().loadGraphic(Paths.image('pauseMenu/vignette'));
		vignette.scrollFactor.set();
		vignette.alpha = 0;
		add(vignette);
		
		bar = new FlxSprite().loadGraphic(Paths.image('pauseMenu/bar'));
		bar.scrollFactor.set();
		bar.alpha = 0;
		add(bar);
		
		portrait = new FlxSprite(250, 0).loadGraphic(Paths.image('pauseMenu/chars/' + PlayState.instance.dad.curCharacter));
		portrait.scrollFactor.set();
		portrait.alpha = 0;
		if (portrait != null) add(portrait);
		
		pauseText = new FlxSprite(0, -150).loadGraphic(Paths.image('pauseMenu/text'));
		pauseText.scrollFactor.set();
		pauseText.alpha = 0;
		add(pauseText);
		
		arrow = new FlxSprite(0, 0).loadGraphic(Paths.image('pauseMenu/arrow'));
		arrow.scrollFactor.set();
		add(arrow);
		
		if (PlayState.instance.oldVideoResolution) bar.x -= 270;
		if (PlayState.instance.oldVideoResolution) portrait.x -= 270;

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		
		FlxTween.tween(scrollingThing, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(vignette, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bar, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(portrait, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.1});
		FlxTween.tween(pauseText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		arrowTween = FlxTween.tween(arrow, {x: arrow.x + 10}, 1, {ease:FlxEase.smoothStepInOut, type: PINGPONG});
		FlxTween.tween(pauseText, {y: 0}, 0.4, {ease:FlxEase.smoothStepInOut});
		
		if (PlayState.instance.oldVideoResolution) FlxTween.tween(portrait, {x: -270}, 0.4, {ease:FlxEase.smoothStepInOut});
		else FlxTween.tween(portrait, {x: 0}, 0.4, {ease:FlxEase.smoothStepInOut});

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);
		
		new FlxTimer().start(0.4, function(lol:FlxTimer)
		{
			coolDown = false;
		});

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		if(PlayState.instance.oldVideoResolution) FlxG.fullscreen = false;
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();
		
		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode) && !coolDown)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "RESUME":
					
					goodByePortrait();
					new FlxTimer().start(0.4, function(lol:FlxTimer)
					{
						close();
						
						if (PlayState.SONG.song.toLowerCase() == 'end process'
						&& PlayState.instance.popUpTimer != null) PlayState.instance.popUpTimer.active = true;
					});
					
				case 'CHANGE DIFFICULTY':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "RESTART SONG":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "EXIT TO MENU":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new TCOStoryState());
					} else {
						MusicBeatState.switchState(new FreeplayMenu());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			var shit = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.color = 0xFFFFFFFF;
			FlxTween.tween(item, {x: 90}, 0.3, {ease:FlxEase.smoothStepInOut});
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (shit == 0)
			{
				item.alpha = 1;
				item.color = 0xFFFFF777;
				
				FlxTween.tween(item, {x: 100}, 0.3, {ease:FlxEase.smoothStepInOut});
				
				arrow.y = item.y - 20;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new FlxText(90, (i * 100) + 280, menuItems[i], 64);
			item.setFormat(Paths.font("Small Print.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			item.scrollFactor.set();

			if (menuItems.length > 4){
				//item.scale.x = 4/menuItems.length;
				item.scale.y = 4 / menuItems.length;
				item.scale.x = 8/menuItems.length;
			}

			item.y = ((i * 100) * item.scale.y) + 280;

			item.width = item.width*item.scale.y;
			item.updateHitbox();

			//if (item.scale.y < 1) item.x = 90-item.width;
			
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.scale.x = item.scale.x;
				skipTimeText.scale.y = item.scale.y;
				//skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
	
	function goodByePortrait()
	{
		arrowTween.cancel();
	    //FlxTween.tween(arrow, {x: 300}, 0.4, {ease:FlxEase.smoothStepInOut});
		//FlxTween.tween(arrow, {arrow: 0}, 0.4, {ease: FlxEase.quartInOut});
		for (item in grpMenuShit.members) FlxTween.tween(item, {x: item.x - 500}, 0.4, {ease:FlxEase.smoothStepInOut});
		for (item in grpMenuShit.members) FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(pauseText, {y: -150}, 0.4, {ease:FlxEase.smoothStepInOut});
		FlxTween.tween(portrait, {x: 250}, 0.4, {ease:FlxEase.smoothStepInOut});
		FlxTween.tween(scrollingThing, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(vignette, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bar, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(portrait, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
	}
}
