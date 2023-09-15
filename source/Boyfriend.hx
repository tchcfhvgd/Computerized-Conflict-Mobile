package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var startedDeath:Bool = false;

	public var actuallyDad:Bool = false; //actuallyDad is for the er showdown tco camera

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if(animation.curAnim.finished) {
				if (animation.curAnim.name.endsWith('miss'))
				{
					playAnim('idle', true, false, 10);
				}

				if (startedDeath && animation.curAnim.name == 'firstDeath' )
				{
					playAnim('deathLoop');
				}
			}
		}

		super.update(elapsed);
	}
}
