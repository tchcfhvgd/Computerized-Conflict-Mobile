package;

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

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<FlxText>;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var scrollingThing:FlxBackdrop;
	var featuredChar:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var zoomTween:FlxTween;
	var tweenX:FlxTween;
	var alphaTween:FlxTween;
	var weeks:Null<Array<String>>;
	var barName:FlxSprite;
	var arrow:FlxSprite;
	var flippedArrow:FlxSprite;

	var precacheList:Map<String, String> = new Map<String, String>();

	public function new (?newWeeks:Null<Array<String>>) //code is from w.i. btw
	{
		super();

		if (newWeeks != null)
			weeks = newWeeks;
	}

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Song Selection", null);
		#end

		for (i in 0...weeks.length) {
			if(weekIsLocked(weeks[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(weeks[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}

		WeekData.loadTheFirstEnabledMod();


		bg = new FlxSprite();
		add(bg);

		scrollingThing = new FlxBackdrop(Paths.image('FAMenu/scroll'), XY, 0, 0);
		scrollingThing.scrollFactor.set(0, 0.07);
		scrollingThing.setGraphicSize(Std.int(scrollingThing.width * 0.8));
		scrollingThing.antialiasing = ClientPrefs.globalAntialiasing;
		add(scrollingThing);

		for (i in 0...songs.length) precacheList.set('freeplayArt/freeplayImages/bgs/' + songs[i].songName, 'image');

		featuredChar = new FlxSprite();
		add(featuredChar);

		var vignetteCircle:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplayArt/freeplayImages/dea'));
		vignetteCircle.antialiasing = ClientPrefs.globalAntialiasing;
		add(vignetteCircle);
		vignetteCircle.screenCenter();

		var upBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplayArt/freeplayImages/upBar'));
		upBar.antialiasing = ClientPrefs.globalAntialiasing;
		add(upBar);
		upBar.screenCenter();

		var downBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplayArt/freeplayImages/downBar'));
		downBar.antialiasing = ClientPrefs.globalAntialiasing;
		add(downBar);
		downBar.screenCenter();

		barName = new FlxSprite().loadGraphic(Paths.image('freeplayArt/freeplayImages/type of freeplay/' + weeks[0] + '-songs'));
		barName.antialiasing = ClientPrefs.globalAntialiasing;
		add(barName);
		barName.screenCenter();

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:FlxText = new FlxText(500, 650, songs[i].songName.toUpperCase(), 44);
			songText.setFormat(Paths.font("phantommuff.ttf"), 44, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
			songText.scrollFactor.set(1, 0);
			add(songText);
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			icon.x -= 380;
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		arrow = new FlxSprite(1150, 593);
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
		add(flippedArrow);

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 405, 0, "", 24);
		scoreText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);

		scoreBG = new FlxSprite(scoreText.x - 6, 400).makeGraphic(1, 126, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 48, 0, "", 24);
		diffText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
		add(diffText);

		add(scoreText);

		if (curSelected >= songs.length) curSelected = 0;
		scrollingThing.color = songs[curSelected].color;
		intendedColor = scrollingThing.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		changeSelection();
		changeDiff();

		super.create();

		for (key => type in precacheList)
		{
			switch(type)
			{
				case 'image':
					Paths.image(key);
			}
		}
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		var skipAdd:Bool = false;
		for (i in 0...VaultState.codesAndShit.length){
			for (i in 0...VaultState.codesAndShit.length){
				if(VaultState.codesAndShit[i][1].toLowerCase() == songName.toLowerCase())
					if (CoolUtil.songsUnlocked.data.songs.get(VaultState.codesAndShit[i][1]) == false)
						skipAdd = true;
			}
		}

		if (!skipAdd)
			songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		scrollingThing.x -= 0.45 * 60 * elapsed;
		scrollingThing.y -= 0.16 * 60 * elapsed;

		scrollingThing.alpha = 0.7;

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}

		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: \n' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (controls.UI_LEFT_P)
			{
				flippedArrow.animation.play('smash');
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (controls.UI_RIGHT_P)
			{
				arrow.animation.play('smash');
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_RIGHT_P || controls.UI_LEFT_P)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_LEFT_P ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (downP)
			changeDiff(-1);
		else if (upP)
			changeDiff(1);
		else if (controls.UI_LEFT_P || controls.UI_RIGHT_P) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			if(zoomTween != null) {
				zoomTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new FreeplayMenu());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}

			if(zoomTween != null) {
				zoomTween.cancel();
			}

			if (songs[curSelected].songName == "amity".toLowerCase()) {
					MusicBeatState.switchState(new MinusCharSelector());
			}
			else
			{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< \n' + CoolUtil.difficultyString() + '\n >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if(zoomTween != null) {
			zoomTween.cancel();
		}

		if(tweenX != null) {
			tweenX.cancel();
		}

		if(alphaTween != null) {
			alphaTween.cancel();
		}

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(scrollingThing, 1, scrollingThing.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		bg.loadGraphic(Paths.image('freeplayArt/freeplayImages/bgs/' + songs[curSelected].songName));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.screenCenter();

		featuredChar.loadGraphic(Paths.image('freeplayArt/freeplayImages/art/' + songs[curSelected].songName));
		featuredChar.antialiasing = ClientPrefs.globalAntialiasing;
		featuredChar.screenCenter();
		featuredChar.x -= 150;
		featuredChar.alpha = 0;

		//if (featuredChar != null)
		//{
			tweenX = FlxTween.tween(featuredChar, { x: 0 }, 0.25, {
				type: FlxTween.ONESHOT, ease: FlxEase.quadInOut,
				onComplete: function (twn:FlxTween) {
					tweenX = null;
				}
			});

			alphaTween = FlxTween.tween(featuredChar, { alpha: 1 }, 0.25, {
				ease: FlxEase.sineInOut,
				onComplete: function (twn:FlxTween) {
					alphaTween = null;
				}
			});
		//}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0;

			zoomTween = FlxTween.tween(iconArray[i], {"scale.x": 0.85, "scale.y": 0.85}, 0.2, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) {
					zoomTween = null;
				}
			});
		}

		iconArray[curSelected].alpha = 1;
		zoomTween = FlxTween.tween(iconArray[curSelected], {"scale.x": 0.85, "scale.y": 1}, 0.85, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) {
					zoomTween = null;
				}
			});

		for (item in grpSongs.members)
		{
			var shit = bullShit - curSelected;
			bullShit++;

			item.alpha = 0;

				zoomTween = FlxTween.tween(item, {"scale.x": 0.85, "scale.y": 0.85}, 0.2, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween) {
						zoomTween = null;
					}
				});
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (shit == 0)
			{
				item.alpha = 1;

					zoomTween = FlxTween.tween(item, {"scale.x": 1, "scale.y": 1}, 0.2, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween) {
						zoomTween = null;
					}
				});
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}