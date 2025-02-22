package flxanimate;

import flixel.math.FlxAngle;
import haxe.Timer;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flxanimate.animate.*;
import flxanimate.zip.Zip;
import openfl.Assets;
import haxe.io.BytesInput;
import flixel.system.FlxSound;
import flixel.FlxG;
import flxanimate.data.AnimationData;
import flixel.FlxSprite;
import flxanimate.animate.FlxAnim;
import flxanimate.frames.FlxAnimateFrames;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.math.FlxMath;
import flixel.FlxBasic;

typedef Settings = {
	//?ButtonSettings:Map<String, flxanimate.animate.FlxAnim.ButtonSettings>,
	?FrameRate:Float,
	?Reversed:Bool,
	?OnComplete:Void->Void,
	?ShowPivot:Bool,
	?Antialiasing:Bool,
	?ScrollFactor:FlxPoint,
	?Offset:FlxPoint,
}

class FlxAnimate extends FlxSprite
{
	public var anim(default, null):FlxAnim;

	// #if FLX_SOUND_SYSTEM
	// public var audio:FlxSound;
	// #end

	// public var rectangle:FlxRect;

	public var showPivot(default, set):Bool = false;

	var _pivot:FlxFrame;
	/**
	 * # Description
	 * `FlxAnimate` is a texture atlas parser from the drawing software *Adobe Animate* (once being *Adobe Flash*).
	 * It tries to replicate how Adobe Animate works on Haxe so it would be considered (as *MrCheemsAndFriends* likes to call it,) a "*Flash--*", in other words, a replica of Animate's work
	 * on the side of drawing, making symbols, etc.
	 * ## WARNINGS
	 * - This does **NOT** convert the frames into a spritesheet
	 * - Since this is some sort of beta, expect that there could be some inconveniences (bugs, crashes, etc).
	 *
	 * @param X 		The initial X position of the sprite.
	 * @param Y 		The initial Y position of the sprite.
	 * @param Path      The path to the texture atlas, **NOT** the path of the any of the files inside the texture atlas (`Animation.json`, `spritemap.json`, etc).
	 * @param Settings  Optional settings for the animation (antialiasing, framerate, reversed, etc.).
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Path:String, ?Settings:Settings)
	{
		super(X, Y);
		//var t0 = Timer.stamp();
		anim = new FlxAnim(this);
		if (Path != null)
			loadAtlas(Path);
		if (Settings != null)
			setTheSettings(Settings);
		//trace("Init FlxAnimate: " + (Timer.stamp() - t0));
	}

	function set_showPivot(v:Bool) {
		if(v && _pivot == null) {
			@:privateAccess
			_pivot = new FlxFrame(FlxGraphic.fromBitmapData(Assets.getBitmapData("assets/images/pivot.png")));
			_pivot.frame = new FlxRect(0, 0, _pivot.parent.width, _pivot.parent.height);
			_pivot.name = "pivot";
		}
		return showPivot = v;
	}

	public function loadAtlas(Path:String)
	{
		if (!Paths.exists('$Path/Animation.json') && haxe.io.Path.extension(Path) != "zip")
		{
			FlxG.log.error('Animation file not found in specified path: "$path", have you written the correct path?');
			return;
		}
		@:privateAccess
		FlxAnimateFrames.zip = null;
		var animationFile = atlasSetting(Path);
		//trace("Load atlas:");
		//var t0 = Timer.stamp();
		anim._loadAtlas(animationFile);
		//trace("Total: ", (Timer.stamp() - t0));
		//trace("");
		//var t0 = Timer.stamp();
		frames = FlxAnimateFrames.fromTextureAtlas(Path);
		//trace("Load atlas frames", (Timer.stamp() - t0));
	}

	//var isCaching:Bool = false;
	//var _drawList:Array<Array<Dynamic>> = [];
	//var cacheKey:String = null;
	/**
	 * the function `draw()` renders the symbol that `anim` has currently plus a pivot that you can toggle on or off.
	 */
	public override function draw():Void
	{
		if(alpha == 0) return;

		//var key = getKey();
		//if(key != cacheKey) {
		//	isCaching = true;
		//	_drawList = FlxArrayUtil.clearArray(_drawList);
		parseElement(anim.curInstance, anim.curFrame, _matrix, colorTransform, true);
		//	isCaching = false;
		//	cacheKey = key;
		//} else {
		//	for(item in _drawList) {
		//		var bitmap:FlxFrame = item[0];
		//		var matrix:FlxMatrix = item[1];
		//		var colorEffect:ColorTransform = item[2];
		//		drawLimb(bitmap, matrix, colorEffect);
		//	}
		//}
		if (showPivot)
			drawLimb(_pivot, new FlxMatrix(1,0,0,1, origin.x, origin.y));
	}

	//public function getKey() {
	//	return '${anim.curInstance.symbol.name}__${anim.curFrame}__${_matrix.toString()}__rm=${colorTransform.redMultiplier},gm=${colorTransform.greenMultiplier},bm=${colorTransform.blueMultiplier},am=${colorTransform.alphaMultiplier},ro=${colorTransform.redOffset},go=${colorTransform.greenOffset},bo=${colorTransform.blueOffset},ao=${colorTransform.alphaOffset}';
	//}

	/**
	 * This basically renders an element of any kind, both limbs and symbols.
	 * It should be considered as the main function that makes rendering a symbol possible.
	 */
	function parseElement(instance:FlxElement, curFrame:Int, m:FlxMatrix, colorFilter:ColorTransform, mainSymbol:Bool = false)
	{
		var colorEffect = new ColorTransform();
		var matrix = new FlxMatrix();

		if (instance.symbol != null) colorEffect.concat(instance.symbol._colorEffect);
		matrix.concat(instance.matrix);

		colorEffect.concat(colorFilter);
		matrix.concat(m);

		if (instance.bitmap != null)
		{
			//if(isCaching) {
			//	_drawList.push([frames.getByName(instance.bitmap), matrix, colorEffect]);
			//}
			drawLimb(frames.getByName(instance.bitmap), matrix, colorEffect);
			return;
		}

		var symbol = anim.symbolDictionary.get(instance.symbol.name);
		var firstFrame:Int = instance.symbol.firstFrame + curFrame;
		switch (instance.symbol.type)
		{
			//case Button: firstFrame = setButtonFrames(firstFrame);
			default:
		}

		firstFrame = switch (instance.symbol.loop)
		{
			case Loop: firstFrame % symbol.length;
			case PlayOnce: cast FlxMath.bound(firstFrame, 0, symbol.length - 1);
			default: firstFrame;
		}

		var layers = symbol.timeline.getList();
		for (i in 0...layers.length)
		{
			var layer = layers[layers.length - 1 - i];

			if (!layer.visible && mainSymbol) continue;
			var frame = layer.get(firstFrame);

			if (frame == null) continue;

			if (frame.callbacks != null)
			{
				frame.fireCallbacks();
			}

			for (element in frame.getList())
			{
				var firstframe = 0;
				if (element.symbol != null && element.symbol.loop != SingleFrame)
				{
					firstframe = firstFrame - frame.index;
				}
				var coloreffect = new ColorTransform();
				coloreffect.concat(frame._colorEffect);
				coloreffect.concat(colorEffect);
				parseElement(element, firstframe, matrix, coloreffect);
			}
		}
	}

	/*var pressed:Bool = false;
	function setButtonFrames(frame:Int)
	{
		#if FLX_MOUSE
		var badPress:Bool = false;
		var goodPress:Bool = false;
		if (FlxG.mouse.pressed && FlxG.mouse.overlaps(this))
			goodPress = true;
		if (FlxG.mouse.pressed && !FlxG.mouse.overlaps(this) && !goodPress)
		{
			badPress = true;
		}
		if (!FlxG.mouse.pressed)
		{
			badPress = false;
			goodPress = false;
		}
		if (FlxG.mouse.overlaps(this) && !badPress)
		{
			@:privateAccess
			var event = anim.buttonMap.get(anim.curSymbol.name);
			if (FlxG.mouse.justPressed && !pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnClick : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = true;
			}
			frame = (FlxG.mouse.pressed) ? 2 : 1;

			if (FlxG.mouse.justReleased && pressed)
			{
				if (event != null)
					new ButtonEvent((event.Callbacks != null) ? event.Callbacks.OnRelease : null #if FLX_SOUND_SYSTEM, event.Sound #end).fire();
				pressed = false;
			}
		}
		else
		{
			frame = 0;
		}
		#else
		FlxG.log.error("Button stuff isn't available for mobile!");
		#end
		return frame;
	}*/

	static var rMatrix = new FlxMatrix();

	function drawLimb(limb:FlxFrame, _matrix:FlxMatrix, ?colorTransform:ColorTransform)
	{
		if (alpha == 0 || colorTransform != null && (colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255) || limb == null || limb.type == EMPTY)
			return;

		for (camera in cameras)
		{
			rMatrix.identity();
			rMatrix.translate(-limb.offset.x, -limb.offset.y);
			rMatrix.concat(_matrix);
			if (!camera.visible || !camera.exists || !limbOnScreen(limb, _matrix, camera))
				return;

			getScreenPosition(_point, camera).subtractPoint(offset);
			rMatrix.translate(-origin.x, -origin.y);
			if (limb != _pivot)
				rMatrix.scale(scale.x, scale.y);
			else
				rMatrix.a = rMatrix.d = 0.7 / camera.zoom;

			//updateSkewMatrix();
			//rMatrix.concat(_skewMatrix);

			_point.addPoint(origin);
			if (isPixelPerfectRender(camera))
			{
				_point.floor();
			}

			rMatrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, rMatrix, colorTransform, blend, antialiasing);
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		//#if FLX_DEBUG
		//if (FlxG.debugger.drawDebug)
		//	drawDebug();
		//#end
	}

	/*public var skew(default, null):FlxPoint = FlxPoint.get();

	var _skewMatrix:FlxMatrix = new FlxMatrix();

	function updateSkewMatrix():Void
	{
		_skewMatrix.identity();

		if (skew.x != 0 || skew.y != 0)
		{
			_skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
			_skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);
		}
	}*/

	function limbOnScreen(limb:FlxFrame, m:FlxMatrix, ?Camera:FlxCamera)
	{
		if (Camera == null)
			Camera = FlxG.camera;

		var minX:Float = x + m.tx - offset.x - scrollFactor.x * Camera.scroll.x;
		var minY:Float = y + m.ty - offset.y - scrollFactor.y * Camera.scroll.y;

		var radiusX:Float =  limb.frame.width * Math.max(1, m.a);
		var radiusY:Float = limb.frame.height * Math.max(1, m.d);
		var radius:Float = Math.max(radiusX, radiusY);
		radius *= FlxMath.SQUARE_ROOT_OF_TWO;
		minY -= radius;
		minX -= radius;
		radius *= 2;

		_point.set(minX, minY);

		return Camera.containsPoint(_point, radius, radius);
	}

	// function checkSize(limb:FlxFrame, m:FlxMatrix)
	// {
	// 	// var rect = new Rectangle(x,y,limb.frame.width,limb.frame.height);
	// 	// @:privateAccess
	// 	// rect.__transform(rect, m);
	// 	return {width: rect.width, height: rect.height};
	// }
	var oldMatrix:FlxMatrix;
	override function set_flipX(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.a = -oldMatrix.a;
			_matrix.c = -oldMatrix.c;
		}
		else
		{
			_matrix.a = oldMatrix.a;
			_matrix.c = oldMatrix.c;
		}
		return Value;
	}
	override function set_flipY(Value:Bool)
	{
		if (oldMatrix == null)
		{
			oldMatrix = new FlxMatrix();
			oldMatrix.concat(_matrix);
		}
		if (Value)
		{
			_matrix.b = -oldMatrix.b;
			_matrix.d = -oldMatrix.d;
		}
		else
		{
			_matrix.b = oldMatrix.b;
			_matrix.d = oldMatrix.d;
		}
		return Value;
	}

	override function destroy()
	{
		anim = FlxDestroyUtil.destroy(anim);
		// #if FLX_SOUND_SYSTEM
		// if (audio != null)
		// 	audio.destroy();
		// #end
		super.destroy();
	}

	public override function updateAnimation(elapsed:Float)
	{
		anim.update(elapsed);
	}

	/*public function setButtonPack(button:String, callbacks:ClickStuff #if FLX_SOUND_SYSTEM , sound:FlxSound #end):Void
	{
		@:privateAccess
		anim.buttonMap.set(button, {Callbacks: callbacks, #if FLX_SOUND_SYSTEM Sound: sound #end});
	}*/

	function setTheSettings(?Settings:Settings):Void
	{
		@:privateAccess
		if (true)
		{
			antialiasing = Settings.Antialiasing;
			//if (Settings.ButtonSettings != null)
			//{
			//	anim.buttonMap = Settings.ButtonSettings;
			//	if (anim.symbolType != Button)
			//		anim.symbolType = Button;
			//}
			if (Settings.Reversed != null)
				anim.reversed = Settings.Reversed;
			if (Settings.FrameRate != null)
				anim.frameRate = (Settings.FrameRate > 0) ? anim.metadata.frameRate : Settings.FrameRate;
			if (Settings.OnComplete != null)
				anim.onComplete = Settings.OnComplete;
			if (Settings.ShowPivot != null)
				showPivot = Settings.ShowPivot;
			if (Settings.Antialiasing != null)
				antialiasing = Settings.Antialiasing;
			if (Settings.ScrollFactor != null)
				scrollFactor = Settings.ScrollFactor;
			if (Settings.Offset != null)
				offset = Settings.Offset;
		}
	}

	function atlasSetting(Path:String):AnimAtlas
	{
		//var t0 = Timer.stamp();

		var jsontxt:AnimAtlas = null;
		if (haxe.io.Path.extension(Path) == "zip")
		{
			var thing = Zip.readZip(Paths.getBytes(Path));

			for (list in Zip.unzip(thing))
			{
				if (list.fileName.indexOf("Animation.json") != -1)
				{
					jsontxt = haxe.Json.parse(list.data.toString());
					thing.remove(list);
					continue;
				}
			}
			@:privateAccess
			FlxAnimateFrames.zip = thing;
		}
		else
		{
			jsontxt = haxe.Json.parse(
				Paths.getText('$Path/Animation.json')
			);
		}

		//trace("Parse json", (Timer.stamp() - t0));

		return jsontxt;
	}
}
