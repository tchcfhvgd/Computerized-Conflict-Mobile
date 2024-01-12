package;

import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class FaceOff //made by nomnom-DV
{
    //To use Run init() and then faceOff(number) whenever
    public static var cams:Array<FlxCamera> = [];

    public static function faceOff(phase:Int) { // EXAMPLE
        switch(phase){
            case 1:
                FlxTween.tween(cams[0],{y:0},0.2,{ease:FlxEase.expoOut});
            case 6:
                FlxTween.tween(cams[1],{y:0},0.2,{ease:FlxEase.expoOut});
            case 12:
                FlxTween.tween(cams[0],{zoom:0.6},3,{ease:FlxEase.sineOut});
                FlxTween.tween(cams[1],{zoom:0.6},3,{ease:FlxEase.sineOut});
            case 16:
                FlxTween.tween(cams[1],{y:-720},0.4,{ease:FlxEase.expoIn});
                FlxTween.tween(cams[0],{y:720},0.4,{ease:FlxEase.expoIn});
        }
    }
    public static function init() {
        cams[0] = new FlxCamera();
        cams[0].copyFrom(PlayState.instance.camGame);
        cams[0].x = 0;
        cams[0].y = 0;
        cams[0].width = 640;
        cams[0].height = 720;
        cams[0].zoom = 1.6;
    
        cams[0].scroll.x = PlayState.instance.dad.getMidpoint().x - 150;
        cams[0].scroll.x = cams[0].scroll.x - (PlayState.instance.dad.cameraPosition[0] - PlayState.instance.opponentCameraOffset[0]);
        cams[0].scroll.y = PlayState.instance.dad.getMidpoint().y - 175;
        cams[0].scroll.y = cams[0].scroll.y + (PlayState.instance.dad.cameraPosition[1] - PlayState.instance.opponentCameraOffset[1]);
        cams[0].scroll.x -= 200;
        cams[0].scroll.y-= 330;
        
        cams[0].target = null;
        FlxG.cameras.add(cams[0]);
        cams[0].y-=720;

    
        cams[1]= new FlxCamera();
        cams[1].copyFrom(PlayState.instance.camGame);
        cams[1].x = 1280/2;
        cams[1].y = 0;
        cams[1].width = 640;
        cams[1].height = 720;
        cams[1].zoom = 2;
    
        cams[1].scroll.x = PlayState.instance.boyfriend.getMidpoint().x - 150;
        cams[1].scroll.x = cams[1].scroll.x - (PlayState.instance.boyfriend.cameraPosition[0] - PlayState.instance.boyfriendCameraOffset[0]);
        cams[1].scroll.y = PlayState.instance.boyfriend.getMidpoint().y - 175;
        cams[1].scroll.y = cams[1].scroll.y + (PlayState.instance.boyfriend.cameraPosition[1] - PlayState.instance.boyfriendCameraOffset[1]);
        cams[1].scroll.x -= 200;
        cams[1].scroll.y-= 200;
        cams[1].scroll.y-=150;
        cams[1].target = null;
        FlxG.cameras.add(cams[1]);

        FlxCamera.defaultCameras = [cams[0], cams[1], PlayState.instance.camGame];
        cams[0].zoom = 1;
        cams[1].y+= 720;
        cams[0].zoom = 1;
        cams[1].zoom = 1;
        
    }
}