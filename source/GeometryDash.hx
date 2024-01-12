package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode; 
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import flixel.addons.display.FlxBackdrop;

#if sys
import sys.FileSystem;
#end

using StringTools;

class GeometryDash extends MusicBeatState
{
    var ground:FlxBackdrop;
    var bg:FlxBackdrop;
    var cube:FlxSprite;
    var portal:FlxSprite;
    var orbs:FlxSprite;
    var jumpGround:FlxSprite;

    override function create()
    {
        FlxG.sound.playMusic(Paths.inst('stereo-madness'), 1, false);

        bg = new FlxBackdrop(Paths.image('GD/game_bg_01_001-hd'), X, 0, 0);
        //bg.color = 0x287dff;
        bg.scrollFactor.set();
        bg.setGraphicSize(Std.int(bg.width * 1.35));
        bg.velocity.set(-150, 0);
        add(bg);

		ground = new FlxBackdrop(Paths.image('GD/groundSquare_01_001-hd'), X, 0, 0);
        ground.y = 550;
		ground.velocity.set(-350, 0);
		add(ground);

        cube = new FlxSprite(0, 495.788).loadGraphic(Paths.image('GD/modes/cube'));
        cube.setGraphicSize(Std.int(cube.width * 0.85));
        cube.updateHitbox();
        add(cube);
        super.create();
    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        cube.x = 340;

        if(FlxG.keys.pressed.SPACE || FlxG.mouse.pressed)
        {
            cube.velocity.y -= 615;
        }
    }
}