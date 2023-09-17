package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.scaleModes.StageSizeScaleMode;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;
	var gfMoment:Bool = MainMenuState.gfMoment;
	var retryText:FlxText;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		switch(PlayState.SONG.player1)
		{
			case 'bf':
				characterName = 'bf-dead';
				deathSoundName = 'fnf_loss_sfx';
				loopSoundName = 'gameOver';
				endSoundName = 'gameOverEnd';

			case 'blue-bf':
				characterName = 'bf-dead';
				deathSoundName = 'fnf_loss_sfx';
				loopSoundName = 'gameOver-cc';
				endSoundName = 'gameOverEnd-cc';

			case 'betaBF':
				characterName = 'betaBF die';
				deathSoundName = 'fnf_loss_sfx';
				loopSoundName = 'gameOver-cc';
				endSoundName = 'gameOverEnd-cc';

			case 'meanBF':
				characterName = 'meanBF die';
				deathSoundName = 'fnf_loss_sfx';
				loopSoundName = 'gameOver-cc';
				endSoundName = 'gameOverEnd-cc';

			default:
				characterName = 'animator-bf-dead';
				deathSoundName = 'fnf_loss_sfx';
				loopSoundName = 'gameOver-cc';
				endSoundName = 'gameOverEnd-cc';
		}
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;
		
		var screen:FlxSpriteExtra = new FlxSpriteExtra(0, 0).makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF00010D);
		screen.scrollFactor.set();
		screen.screenCenter();
		add(screen);

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		if (PlayState.SONG.song.toLowerCase() == 'phantasm') boyfriend.alpha = 0;

		switch(characterName)
		{
			case 'tco-aol-dead':
				camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x + 200, boyfriend.getGraphicMidpoint().y + 150);
			case 'yt-gameover':
				camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x + 100, boyfriend.getGraphicMidpoint().y + 500);
			case 'stick-bf-death':
				camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x + 100, boyfriend.getGraphicMidpoint().y + 100);
			case 'animator-bf-dead' | 'animator-bf-dead-flipX':
				camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x + 250, boyfriend.getGraphicMidpoint().y + 180);
			default:
				camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
				Conductor.changeBPM(100);
		}

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(104);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		retryText = new FlxText(0, 0, FlxG.width, 'RETRY?\n\nENTER - Yes.\nESC - No.');
		retryText.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
		retryText.alpha = 0.0001;
		retryText.scrollFactor.set();
		retryText.screenCenter();
		if (PlayState.SONG.song.toLowerCase() == 'phantasm') add(retryText);
		
		if (ClientPrefs.flashing) FlxG.camera.flash(FlxColor.RED, 0.5);
		
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, FlxG.camera.zoom);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			if (PlayState.SONG.song.toLowerCase() == 'phantasm')
			{
				retryText.applyMarkup("RETRY?\n\n$ENTER - Yes.$\nESC - No.", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.YELLOW), "$")]);
				retryText.alpha = 1;
			}

			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
			{
				MusicBeatState.switchState(new TCOStoryState());
			}
			else if (gfMoment)
			{				
			    MusicBeatState.switchState(new MainMenuState());
				MainMenuState.gfMoment = false;
			}
			else
				MusicBeatState.switchState(new FreeplayMenu());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.SONG.stage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);

					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
				if (PlayState.SONG.song.toLowerCase() == 'phantasm') FlxTween.tween(retryText, {alpha:1}, 0.45);
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (PlayState.curStage == 'rombieBG') PlayState.distortShader.shader.iTime.value[0] += elapsed;

		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.35}, 2.7, {ease: FlxEase.quadIn});
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				//FlxTween.cancelTweensOf(PlayState..camera);
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
				    if (FreeplayState.minimizeWindowArray.contains(codesAndShit[i][1].toLowerCase()))
					{
						Lib.application.window.resizable = false;
						FlxG.scaleMode = new StageSizeScaleMode();
						FlxG.resizeGame(360, 720);
						FlxG.resizeWindow(960, 720);
					}
					
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
