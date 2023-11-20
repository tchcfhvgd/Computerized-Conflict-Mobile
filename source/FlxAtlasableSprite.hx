import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import flxanimate.FlxAnimate;
import flixel.util.FlxDestroyUtil;
import flixel.FlxSprite;

// Code from Codename Engine
class FlxAtlasableSprite extends FlxSprite {
	public var shaderEnabled:Bool = true;

	public var animateAtlas:FlxAnimate;
	@:noCompletion public var atlasPlayingAnim:String;
	@:noCompletion public var atlasPath:String;

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (animateAtlas != null)
			animateAtlas.update(elapsed);
	}

	public override function draw() {
		if (animateAtlas != null) {
			copyAtlasValues();
			animateAtlas.draw();
		} else {
			super.draw();
		}
	}

	public function copyAtlasValues() {
		@:privateAccess {
			animateAtlas.cameras = cameras;
			animateAtlas.scrollFactor = scrollFactor;
			animateAtlas.scale = scale;
			animateAtlas.offset = offset;
			animateAtlas.origin = origin;
			//animateAtlas.rotOffset = rotOffset;
			animateAtlas.x = x;
			animateAtlas.y = y;
			animateAtlas.angle = angle;
			animateAtlas.alpha = alpha;
			animateAtlas.visible = visible;
			animateAtlas.flipX = flipX;
			animateAtlas.flipY = flipY;
			//animateAtlas.shader = shaderEnabled ? shader : null;
			animateAtlas.antialiasing = antialiasing;
			animateAtlas.colorTransform = colorTransform;
			animateAtlas.color = color;
		}
	}

	public override function destroy() {
		super.destroy();
		if (animateAtlas != null) {
			//for(f in animateAtlas.frames.frames)
			//	FlxG.bitmap.remove(f.parent);
			//Assets.cache.clear(atlasPath);
			animateAtlas = FlxDestroyUtil.destroy(animateAtlas);
		}
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		#if (flixel >= "5.0.0")
		getScreenPosition(_point, camera).subtractPoint(offset);
		#end
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shaderEnabled ? shader : null);
	}
}