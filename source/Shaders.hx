package;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;
import flixel.FlxBasic;
using StringTools;
typedef ShaderEffect = {
  var shader:Dynamic;
}

class BuildingEffect {
  public var shader:BuildingShader = new BuildingShader();
  public function new(){
	shader.alphaShit.value = [0];
  }
  public function addAlpha(alpha:Float){
	trace(shader.alphaShit.value[0]);
	shader.alphaShit.value[0]+=alpha;
  }
  public function setAlpha(alpha:Float){
	shader.alphaShit.value[0]=alpha;
  }
}

class BuildingShader extends FlxShader
{
  @:glFragmentSource('
#pragma header
uniform float alphaShit;
void main()
{

	vec4 color = flixel_texture2D(bitmap,openfl_TextureCoordv);
	if (color.a > 0.0)
	color-=alphaShit;

	gl_FragColor = color;
}
  ')
  public function new()
  {
	super();
  }
}

class SaturationShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

uniform float brightness;
uniform float saturation;
uniform float AAA;
uniform float BBB;

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    float f = (color.x+color.y+color.z) / AAA;
    color.xyz = brightness+f*(color.xyz*BBB);

    color.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;

    gl_FragColor = color;
} ')
public function new()
{
  super();
}
}

class BlendShader extends FlxShader
{
	@:glFragmentSource('

    #pragma header

	//https://www.shadertoy.com/view/Md3GzX
	
	uniform float iTime;
	#define iChannel0 bitmap
	#define iChannel1 bitmap
	#define iChannel2 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main
	
	
	uniform int blendMode;
	
	
	vec3 multiply(in vec3 src, in vec3 dst)
	{
		return src * dst;
	}
	
	vec3 screen(in vec3 src, in vec3 dst)
	{
		return src + dst - src * dst;
	}
	
	vec3 exclusion(in vec3 src, in vec3 dst)
	{
		return dst + src - (2.0*dst*src);;
	}
	
	vec3 overlay(in vec3 src, in vec3 dst)
	{
		return mix(2.0 * src * dst, 1.0 - 2.0 * (1.0 - src) * (1.0-dst), step(0.5, dst));
	}
	
	vec3 hardlight(in vec3 src, in vec3 dst)
	{
		return mix(2.0 * src * dst,  1.0 - 2.0 * (1.0 - src) * (1.0-dst), step(0.5, src));
	}
	
	vec3 softlight(in vec3 src, in vec3 dst)
	{
		return mix(dst - (1.0 - 2.0 * src) * dst * (1.0 - dst), 
				   mix(dst + ( 2.0 * src - 1.0 ) * (sqrt(dst) - dst),
					   dst + (2.0 * src - 1.0) * dst * ((16.0 * dst - 12.0) * dst + 3.0),
					   step(0.5, src) * (1.0 - step(0.25, dst))),
				   step(0.5, src));
	}
	
	vec3 colorDodge(in vec3 src, in vec3 dst)
	{
		return step(0.0, dst) * mix(min(vec3(1.0), dst/ (1.0 - src)), vec3(1.0), step(1.0, src)); 
	}
	
	vec3 colorBurn(in vec3 src, in vec3 dst)
	{
		return mix(step(0.0, src) * (1.0 - min(vec3(1.0), (1.0 - dst) / src)),
			vec3(1.0), step(1.0, dst));
	}
	
	vec3 linearDodge(in vec3 src, in vec3 dst)
	{
		return clamp(src.xyz + dst.xyz, 0.0, 1.0);
	}
	
	vec3 linearBurn(in vec3 src, in vec3 dst)
	{
		return clamp(src.xyz + dst.xyz - 1.0, 0.0, 1.0);
	}
	
	vec3 vividLight(in vec3 src, in vec3 dst)
	{
		return mix(max(vec3(0.0), 1.0 - min(vec3(1.0), (1.0 - dst) / (2.0 * src))),
				   min(vec3(1.0), dst / (2.0 * (1.0 - src))),
				   step(0.5, src));
	}
	
	vec3 linearLight(in vec3 src, in vec3 dst)
	{
		return clamp(2.0 * src + dst - 1.0, 0.0, 1.0);;
	}
	
	vec3 pinLight(in vec3 src, in vec3 dst)
	{
		return mix(mix(2.0 * src, dst, step(0.5 * dst, src)),
			max(vec3(0.0), 2.0 * src - 1.0), 
			step(dst, (2.0 * src - 1.0))
		);
	}
	
	vec3 hardMix(in vec3 src, in vec3 dst)
	{
		return step(1.0, src + dst);
	}
	
	vec3 subtract(in vec3 src, in vec3 dst)
	{
		return dst - src;
	}
	
	vec3 divide(in vec3 src, in vec3 dst)
	{
		return dst / src;
	}
	
	vec3 addition(vec3 src, vec3 dst)
	{
		return src + dst;
	}
	
	vec3 difference(in vec3 src, in vec3 dst )
	{
		return abs(dst - src);   
	}
	
	vec3 darken(in vec3 src, in vec3 dst)
	{
		return min(src, dst);
	}
	
	vec3 lighten(in vec3 src, in vec3 dst)
	{
		return max(src, dst);
	}
	
	vec3 invert(in vec3 src, in vec3 dst)
	{
		return 1.0 - dst;
	}
	
	vec3 invertRGB(in vec3 src, in vec3 dst)
	{
		return src * (1.0 - dst);
	}
	
	vec3 source(in vec3 src, in vec3 dst)
	{
		return src;
	}
	
	vec3 dest(in vec3 src, in vec3 dst)
	{
		return dst;
	}
	
	// Branchless RGB2HSL implementation from : https://www.shadertoy.com/view/MsKGRW
	vec3 rgb2hsl( in vec3 c )
	{
		const float epsilon = 0.00000001;
		float cmin = min( c.r, min( c.g, c.b ) );
		float cmax = max( c.r, max( c.g, c.b ) );
		float cd   = cmax - cmin;
		vec3 hsl = vec3(0.0);
		hsl.z = (cmax + cmin) / 2.0;
		hsl.y = mix(cd / (cmax + cmin + epsilon), cd / (epsilon + 2.0 - (cmax + cmin)), step(0.5, hsl.z));
	
		vec3 a = vec3(1.0 - step(epsilon, abs(cmax - c)));
		a = mix(vec3(a.x, 0.0, a.z), a, step(0.5, 2.0 - a.x - a.y));
		a = mix(vec3(a.x, a.y, 0.0), a, step(0.5, 2.0 - a.x - a.z));
		a = mix(vec3(a.x, a.y, 0.0), a, step(0.5, 2.0 - a.y - a.z));
		
		hsl.x = dot( vec3(0.0, 2.0, 4.0) + ((c.gbr - c.brg) / (epsilon + cd)), a );
		hsl.x = (hsl.x + (1.0 - step(0.0, hsl.x) ) * 6.0 ) / 6.0;
		return hsl;
	}
	
	// HSL2RGB thanks to IQ : https://www.shadertoy.com/view/lsS3Wc
	vec3 hsl2rgb(in vec3 c)
	{
		vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
		return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
	}
	
	vec3 hue(in vec3 src, in vec3 dst)
	{
		vec3 dstHSL = rgb2hsl(dst);
		vec3 srcHSL = rgb2hsl(src);
		return hsl2rgb(vec3(srcHSL.r, dstHSL.gb));
	}
	
	vec3 saturation(in vec3 src, in vec3 dst)
	{
		vec3 dstHSL = rgb2hsl(dst);
		vec3 srcHSL = rgb2hsl(src);
		return hsl2rgb(vec3(dstHSL.r, srcHSL.g, dstHSL.b));
	}
	
	vec3 color(in vec3 src, in vec3 dst)
	{
		vec3 dstHSL = rgb2hsl(dst);
		vec3 srcHSL = rgb2hsl(src);
		return hsl2rgb(vec3(srcHSL.rg, dstHSL.b));
	}
	
	vec3 luminosity(in vec3 src, in vec3 dst)
	{
		vec3 dstHSL = rgb2hsl(dst);
		vec3 srcHSL = rgb2hsl(src);
		return hsl2rgb(vec3(dstHSL.rg, srcHSL.b));
	}
	
	vec3 blend(in vec3 src, in vec3 dst, in int mode)
	{
		//if (mode == )  return source(src, dst);
		//if (mode == )  return dest(src, dst);
		if (mode == 0)  return screen(src, dst);
		if (mode == 1)  return multiply(src, dst);
		if (mode == 2)  return overlay(src, dst);
		if (mode == 3)  return hardlight(src, dst);
		if (mode == 4)  return softlight(src, dst);
		if (mode == 5)  return colorDodge(src, dst);
		if (mode == 6)  return colorBurn(src, dst);
		if (mode == 7)  return linearDodge(src, dst);
		if (mode == 8)  return linearBurn(src, dst);
		if (mode == 9)  return vividLight(src, dst);
		if (mode == 10) return linearLight(src, dst);
		if (mode == 11) return pinLight(src, dst);
		if (mode == 12) return hardMix(src, dst);
		if (mode == 13) return subtract(src, dst);
		if (mode == 14) return divide(src, dst);
		if (mode == 15) return addition(src, dst);
		if (mode == 16) return difference(src, dst);
		if (mode == 17) return darken(src, dst);
		if (mode == 18) return lighten(src, dst);
		if (mode == 19) return invert(src, dst);
		if (mode == 20) return invertRGB(src, dst);
		if (mode == 21) return hue(src, dst);
		if (mode == 22) return saturation(src, dst);
		if (mode == 23) return color(src, dst);
		if (mode == 24) return luminosity(src, dst);
		if (mode == 25) return exclusion(src, dst);
		return vec3(0.0,0.0,0.0);
	}
	
	///////////////////////////////////
	// MAIN
	///////////////////////////////////
	
	void main()
	{
	    vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;
		
		// Blending
		int mode = int(texture(iChannel0, vec2(0.0, 0.0)).x);
		vec3 src = texture(iChannel1, uv).xyz; // Top layer
		vec3 dst = texture(iChannel2, uv).xyz; // Bottom layer
		
		fragColor.xyz = blend(src, dst, blendMode);
		
		fragColor.a = texture(iChannel0, uv).a;
	}')

	public function new()
	{
	  super();
	}
}

class ShaderForTest extends FlxShader
{

	@:glFragmentSource('

    #pragma header
	
	uniform float iTime;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main
	vec3 scanline(vec2 coord, vec3 screen)
	{
		screen.rgb -= sin((coord.y + (iTime * 29.0))) * 0.02;
		return screen;
	}
	
	vec2 crt(vec2 coord, float bend)
	{
		// put in symmetrical coords
		coord = (coord - 0.5) * 2.0;
	
		coord *= 1.1;	
	
		// deform coords
		coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);
		coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);
	
		// transform back to 0.0 - 1.0 space
		coord  = (coord / 2.0) + 0.5;
	
		return coord;
	}
	
	vec3 sampleSplit(sampler2D tex, vec2 coord)
	{
		vec3 frag;
		frag.r = texture(tex, vec2(coord.x - 0.01 * sin(iTime), coord.y)).r;
		frag.g = texture(tex, vec2(coord.x                          , coord.y)).g;
		frag.b = texture(tex, vec2(coord.x + 0.01 * sin(iTime), coord.y)).b;
		return frag;
	}
	
	void main()
	{
	    vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;
		uv.y = 1.0 - uv.y; // flip tex
		vec2 crtCoords = crt(uv, 3.2);

		// if you set up your tex params properly
		if (crtCoords.x < 0.0 || crtCoords.x > 1.0 || crtCoords.y < 0.0 || crtCoords.y > 1.0)
			discard;
	
		// Split the color channels
		fragColor.rgb = sampleSplit(iChannel0, crtCoords);
	
		// HACK: this bend produces a shitty moire pattern.
		// Up the bend for the scanline
		vec2 screenSpace = crtCoords * iResolution.xy;
		float theAlpha = flixel_texture2D(bitmap,uv).a;
		
		fragColor.rgb = scanline(screenSpace, fragColor.rgb);
		gl_FragColor = vec4(fragColor.rgb,theAlpha);
	}')

	public function new()
	{
	  super();
	}
}

class FishEyeShader extends FlxShader
{
	@:glFragmentSource('

    #pragma header
	
	uniform float iTime;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main

	uniform float MAX_POWER; // negative : anti fish eye. positive = fisheye

	//Inspired by http://stackoverflow.com/questions/6030814/add-fisheye-effect-to-images-at-runtime-using-opengl-es
	void main()//Drag mouse over rendering area
	{
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;
		vec2 p = (openfl_TextureCoordv * openfl_TextureSize.xy) / openfl_TextureSize.x;//normalized coords with some cheat
																 //(assume 1:1 prop)
		float prop = openfl_TextureSize.x / openfl_TextureSize.y;//screen proroption
		vec2 m = vec2(0.5, 0.5 / prop);//center coords
		vec2 d = p - m;//vector from center to current fragment
		float r = sqrt(dot(d, d)); // distance of pixel from center
	
		float power = MAX_POWER * -1.3;
	
		float bind;//radius of 1:1 effect
		if (power > 0.0) 
			bind = sqrt(dot(m, m));//stick to corners
		else {if (prop < 1.0) 
			bind = m.x; 
		else 
			bind = m.y;}//stick to borders
	
		//Weird formulas
		vec2 uv;
		if (power > 0.0)//fisheye
			uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
		else if (power < 0.0)//antifisheye
			uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
		else uv = p;//no effect for power = 1.0
			
		uv.y *= prop;
	
		vec4 col = texture2D(bitmap, uv);
		
		// inverted
		//vec3 col = texture(iChannel0, vec2(uv.x, 1.0 - uv.y)).rgb;//Second part of cheat
														  //for round effect, not elliptical
		gl_FragColor = col;
	}')

	public function new()
	{
	  super();
	}
}

class PincushionShader extends FlxShader
{
	@:glFragmentSource('   
	#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

// https://www.shadertoy.com/view/ll2GWV

void main()
{
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
	vec2 uv = fragCoord.xy*2. / iResolution.xy-vec2(1.);

	//------------------------------------------------
	// To use in Godot, port this section:
	//------------------------------------------------

	// I picked these somewhat arbitrarily
	const float BARREL = 0.25;
	const float PINCUSHION = 0.25;

	float effect = PINCUSHION; // Set effect to either BARREL or PINCUSHION
	float effect_scale = 1.0;  // Play with this to slightly vary the results

	/// Fisheye Distortion ///
	float d=length(uv);
	float z = sqrt(1.0 + d * d * effect);
	float r = atan(d, z) / 3.14159;
	r *= effect_scale;
	float phi = atan(uv.y, uv.x);

	uv = vec2(r*cos(phi)+.5,r*sin(phi)+.5);

	//------------------------------------------------
	// end relevant logic
	//------------------------------------------------

	fragColor = texture(iChannel0, uv);
}')

  public function new()
  {
	super();
  }
}

class JpegShader extends FlxShader
{
@:glFragmentSource('
#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define m 2.*asin(1.)
#define a(x) (x!=0.?1.:1./sqrt(2.))
vec2 iResolution;

uniform float ycmpr;


vec3 toYCbCr(vec3 rgb)
{
    return rgb*mat3(0.299,0.587,0.114,-0.168736,-0.331264,0.5,0.5,-0.418688,-0.081312)+vec3(0,.5,.5);
}

vec3 pre( vec2 coord ){
    return floor(256.*(toYCbCr(flixel_texture2D(iChannel0, coord/iResolution.xy).xyz) - .5));
}

vec3 DCT8x8( vec2 coord, vec2 z ) {
    vec3 res = vec3(0);
    for(float x = 0.; x < 8.; x++){
        for(float y = 0.; y < 8.; y++){
            res += pre(coord + vec2(x,y)) *
                cos((2.*x+1.)*z.x*m/16.) *
                cos((2.*y+1.)*z.y*m/16.);
        }
    }
    return res * .25 * a(z.x) * a(z.y);
}

vec3 bufferA(in vec2 fragCoord )
{
    vec2 uv = floor(fragCoord-8.*floor(fragCoord/8.));
    int val = 16;
    int vv = int(uv.x+uv.y*8.);
    if(vv == 0) val = 16;
    else if(vv == 1) val = 11;
    else if(vv == 2) val = 10;
    else if(vv == 3) val = 16;
    else if(vv == 4) val = 24;
    else if(vv == 5) val = 40;
    else if(vv == 6) val = 51;
    else if(vv == 7) val = 51;

    else if(vv == 8) val = 12;
    else if(vv == 9) val = 12;
    else if(vv == 10) val = 14;
    else if(vv == 11) val = 19;
    else if(vv == 12) val = 26;
    else if(vv == 13) val = 58;
    else if(vv == 14) val = 60;
    else if(vv == 15) val = 55;

    else if(vv == 16) val = 14;
    else if(vv == 17) val = 13;
    else if(vv == 18) val = 16;
    else if(vv == 19) val = 24;
    else if(vv == 20) val = 40;
    else if(vv == 21) val = 57;
    else if(vv == 22) val = 69;
    else if(vv == 23) val = 56;

    else if(vv == 24) val = 14;
    else if(vv == 25) val = 17;
    else if(vv == 26) val = 22;
    else if(vv == 27) val = 29;
    else if(vv == 28) val = 51;
    else if(vv == 29) val = 87;
    else if(vv == 30) val = 80;
    else if(vv == 31) val = 62;

    else if(vv == 32) val = 18;
    else if(vv == 33) val = 22;
    else if(vv == 34) val = 37;
    else if(vv == 35) val = 56;
    else if(vv == 36) val = 68;
    else if(vv == 37) val = 109;
    else if(vv == 38) val = 102;
    else if(vv == 39) val = 77;

    else if(vv == 40) val = 24;
    else if(vv == 41) val = 35;
    else if(vv == 42) val = 55;
    else if(vv == 43) val = 64;
    else if(vv == 44) val = 81;
    else if(vv == 45) val = 104;
    else if(vv == 46) val = 113;
    else if(vv == 47) val = 92;

    else if(vv == 48) val = 49;
    else if(vv == 49) val = 64;
    else if(vv == 50) val = 78;
    else if(vv == 51) val = 87;
    else if(vv == 52) val = 103;
    else if(vv == 53) val = 121;
    else if(vv == 54) val = 120;
    else if(vv == 55) val = 101;
    else if(vv == 56) val = 72;
    else if(vv == 57) val = 92;
    else if(vv == 58) val = 95;
    else if(vv == 59) val = 98;

    else if(vv == 60) val = 112;
    else if(vv == 61) val = 100;
    else if(vv == 62) val = 103;
    else if(vv == 63) val = 99;
    float q = (1.+ycmpr*20.)*float(val);
    return vec3((floor(.5+DCT8x8(8.*floor(fragCoord/8.),uv)/q))*q);

}
vec3 toRGB(vec3 ybr)
{
    return (ybr-vec3(0,.5,.5))*mat3(1.,0.,1.402,1.,-.344136,-0.714136,1.,1.772,0.);
}

vec3 inp(vec2 coord){
    return bufferA((coord));
}

vec3 IDCT8x8( vec2 coord, vec2 z ) {
    vec3 res = vec3(0);
    for(float u = 0.; u < 2.; u++){
        for(float v = 0.; v < 2.; v++){
            res += inp(coord + vec2(u,v)) *
                a(u) * a(v) *
                cos((2.*z.x+1.)*u*m/16.) *
                cos((2.*z.y+1.)*v*m/16.);
        }
    }
    return res * .25;
}


void main()
{
    vec2 uvv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
iResolution = openfl_TextureSize;
    vec2 uv = floor(fragCoord-8.*floor(fragCoord/8.));
    gl_FragColor.rgb = toRGB(IDCT8x8(8.*floor(fragCoord/8.),uv)/256.+.5);
    gl_FragColor.a = flixel_texture2D(bitmap, uvv).a;

}
')

public function new()
{
	super();
	this.ycmpr.value = [0.5];
}

}

class PlaneShader3D extends FlxShader
{
	@:glFragmentSource('
	#pragma header
#define PI 3.1415926538

uniform float xrot;
uniform float yrot;
uniform float zrot;
uniform float xpos;
uniform float ypos;
uniform float zpos;

float alph = 0.0;
float plane( in vec3 norm, in vec3 po, in vec3 ro, in vec3 rd ) {
	float de = dot(norm, rd);
	de = sign(de)*max( abs(de), 0.001);
	return dot(norm, po-ro)/de;
}

vec2 raytraceTexturedQuad(in vec3 rayOrigin, in vec3 rayDirection, in vec3 quadCenter, in vec3 quadRotation, in vec2 quadDimensions) {
	//Rotations ------------------
	float a = sin(quadRotation.x); float b = cos(quadRotation.x);
	float c = sin(quadRotation.y); float d = cos(quadRotation.y);
	float e = sin(quadRotation.z); float f = cos(quadRotation.z);
	float ac = a*c;   float bc = b*c;

	mat3 RotationMatrix  =
			mat3(	  d*f,      d*e,  -c,
				ac*f-b*e, ac*e+b*f, a*d,
				bc*f+a*e, bc*e-a*f, b*d );
	//--------------------------------------

	vec3 right = RotationMatrix * vec3(quadDimensions.x, 0.0, 0.0);
	vec3 up = RotationMatrix * vec3(0, quadDimensions.y, 0);
	vec3 normal = cross(right, up);
	normal /= length(normal);

	//Find the plane hit point in space
	vec3 pos = (rayDirection * plane(normal, quadCenter, rayOrigin, rayDirection)) - quadCenter;

	//Find the texture UV by projecting the hit point along the plane dirs
	return vec2(dot(pos, right) / dot(right, right),
				dot(pos, up)    / dot(up,    up)) + 0.5;
}

void main() {
	vec4 texColor = texture2D(bitmap, openfl_TextureCoordv);
	//Screen UV goes from 0 - 1 along each axis
	vec2 screenUV = openfl_TextureCoordv;
	vec2 p = (2.0 * screenUV) - 1.0;
	float screenAspect = openfl_TextureSize.x/openfl_TextureSize.y;
	p.x *= screenAspect;

	//Normalized Ray Dir
	vec3 dir = vec3(p.x, p.y, 1.0);
	dir /= length(dir);

	//Define the plane
	vec3 planePosition = vec3(xpos, ypos, zpos+0.5);
	vec3 planeRotation = vec3(xrot, yrot+PI, zrot);//this the shit you needa change
	vec2 planeDimension = vec2(-screenAspect, 1.0);

	vec2 uv = raytraceTexturedQuad(vec3(0), dir, planePosition, planeRotation, planeDimension);

	//If we hit the rectangle, sample the texture
	if (abs(uv.x - 0.5) < 0.5 && abs(uv.y - 0.5) < 0.5) {

		//vec4 tex = flixel_texture2D(bitmap, uv);
		//float bitch = 1.0;
		//if (tex.z == 0.0){
		//	bitch = 0.0;
		//}

		gl_FragColor = flixel_texture2D(bitmap, uv);
	}
}')
  public function new()
  {
	super();

	this.xrot.value = [0.0];
	this.yrot.value = [0.0];
	this.zrot.value = [0.0];
	this.xpos.value = [0.0];
	this.ypos.value = [0.0];
	this.zpos.value = [0.0];
  }
}

class Test3DShader extends FlxShader
{
	@:glFragmentSource('
//SHADERTOY PORT FIX
#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
//****MAKE SURE TO remove the parameters from mainImage.
//SHADERTOY PORT FIX

#define X_SCALE 0.95
#define Z_SCALE 0.40

#define Z_SPEED     0.3
#define X_SPEED_MAX 0.5
#define X_CYCLE_SPEED 0.1

#define CAM_YAW_CYCLE_SPEED 0.225
#define CAM_YAW_MAX_ANGLE 1.570796

#define CAM_ROLL_CYCLE_SPEED 0.168
#define CAM_ROLL_MAX_ANGLE 0.6642

#define CEN_POINT_CYCLE_SPEED1 0.562
#define CEN_POINT_CYCLE_SPEED2 0.383
#define CEN_POINT_CYCLE_MAG    0.3

#define COLOR_CYCLE 0.25
#define FADE_POWER 0.3

#define PI 3.1415926535897932384626

void main()
{
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
	float minRes = min(iResolution.x, iResolution.y);
	fragCoord /= minRes;

	vec2 center = (iResolution.xy / minRes) / 2.0;

	float angle1 = CEN_POINT_CYCLE_SPEED1 * iTime;
	float angle2 = CEN_POINT_CYCLE_SPEED2 * iTime;
	vec2 p = center + vec2(cos(angle1), sin(angle2)) * CEN_POINT_CYCLE_MAG;

	float angle = sin(iTime * CAM_ROLL_CYCLE_SPEED) * CAM_ROLL_MAX_ANGLE;
	float cs = cos(angle);
	float sn = sin(angle);
	fragCoord.xy -= p;
	vec2 newCoord = vec2(
		fragCoord.x * cs + fragCoord.y * sn,
		fragCoord.y * cs - fragCoord.x * sn);
	fragCoord.xy = newCoord;
	fragCoord.xy += p;

	vec2 dCenter = center - fragCoord.xy;

	float height = (iResolution.y / minRes) / 2.0;

	float zCamera = 1.0 / abs(dCenter.y);
	float xCamera = X_SCALE * dCenter.x * zCamera;
	float yCamera = Z_SCALE * zCamera;

	fragCoord.xy = vec2(xCamera, yCamera);

	angle = sin(iTime * CAM_YAW_CYCLE_SPEED) * CAM_YAW_MAX_ANGLE;
	cs = cos(angle);
	sn = sin(angle);
	newCoord = vec2(
		fragCoord.x * cs + fragCoord.y * sn,
		fragCoord.y * cs - fragCoord.x * sn);
	fragCoord.xy = newCoord;

	fragCoord.y += iTime * Z_SPEED;
	fragCoord.x += cos(iTime * X_CYCLE_SPEED) * X_SPEED_MAX;

	vec2 uv;
	if (dCenter.y > 0.0) {
		uv = fragCoord.xy;
	} else {
		uv = fragCoord.xy;
		uv.y *= -1.0;
	}

	uv.x = mod(uv.x, 1.0);
	uv.y = mod(uv.y, 1.0);

	vec4 sans = texture(iChannel0, uv);
	fragColor = vec4(0.0, 0.0, 0.1, 1.0);
	if (sans.w == 1.0)
		fragColor = sans;

	angle = iTime * COLOR_CYCLE;
	angle = mod(angle, 1.0);
	float mag = mod(angle, 1.0/6.0) * 6.0;

	float r = 0.0;
	float g = 0.0;
	float b = 0.0;
	if (angle < 1.0/6.0) {
		r = mag;
		b = 1.;
	} else if (angle < 2.0/6.0) {
		r = 1.;
		b = 1. - mag;
	} else if (angle < 3.0/6.0) {
		r = 1.;
		g = mag;
	} else if (angle < 4.0/6.0) {
		r = 1. - mag;
		g = 1.;
	} else if (angle < 5.0/6.0) {
		g = 1.;
		b = mag;
	} else {
		g = 1. - mag;
		b = 1.;
	}

	vec3 fadeColor = vec3(r,g,b);

	float fade = 1.0 - (1.0 / (1.0 + zCamera * FADE_POWER));
	fragColor.rgb = mix( fragColor.rgb, fadeColor.rgb, fade );
}
')
  public function new()
  {
	super();
  }

}

class Test3DEffect extends Effect //fuck
{
	public var shader:Test3DShader = new Test3DShader();

	public function new()
	{
		shader.iTime.value = [0];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.iTime.value[0] += elapsed;
	}
}

class Shader244p extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    
    void main() {
        vec2 pos = openfl_TextureCoordv;
        pos = floor(pos * vec2(320, 224)) / vec2(320, 224);
    gl_FragColor = flixel_texture2D(bitmap, pos);
    }')

	public function new()
	{
	    super();
	}
}

class EpicRainbowTrailShader extends FlxShader //yes ik there's already a function to do this without shader but this looks epic
{
	@:glFragmentSource('
	#pragma header
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

void main()
{
	vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;

	gl_FragColor = texture(iChannel0, uv);
}
	')

  	public function new()
  	{
  		super();
  	}
}


//HYPNO V2 SHADERS:

class DesaturationShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

uniform float desaturationAmount;
uniform float distortionTime;
uniform float amplitude;
uniform float frequency;

void main() {
	vec4 desatTexture = texture2D(bitmap, vec2(openfl_TextureCoordv.x + sin((openfl_TextureCoordv.y * frequency) + distortionTime) * amplitude, openfl_TextureCoordv.y));
	gl_FragColor = vec4(mix(vec3(dot(desatTexture.xyz, vec3(.2126, .7152, .0722))), desatTexture.xyz, desaturationAmount), desatTexture.a);
}')

  	public function new()
  	{
  		super();

		this.desaturationAmount.value = [0.0];
		this.distortionTime.value = [0.0];
		this.amplitude.value = [-0.1];
		this.frequency.value = [8.0];
  	}
}

class IndividualGlitchesShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

uniform float binaryIntensity;

void main() {
	vec2 uv = openfl_TextureCoordv.xy;

	// get snapped position
	float psize = 0.04 * binaryIntensity;
	float psq = 1.0 / psize;

	float px = floor(uv.x * psq + 0.5) * psize;
	float py = floor(uv.y * psq + 0.5) * psize;

	vec4 colSnap = texture2D(bitmap, vec2(px, py));

	float lum = pow(1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, binaryIntensity);

	float qsize = psize * lum;
	float qsq = 1.0 / qsize;

	float qx = floor(uv.x * qsq + 0.5) * qsize;
	float qy = floor(uv.y * qsq + 0.5) * qsize;

	float rx = (px - qx) * lum + uv.x;
	float ry = (py - qy) * lum + uv.y;

	gl_FragColor = texture2D(bitmap, vec2(rx, ry));
}')

	public function new()
	{
		super();
		this.binaryIntensity.value = [0];
	}
}

class FilmGrainShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

uniform float time;

vec2 ShakeUV(vec2 uv, float time) {
	uv.x += 0.002 * sin(time*3.141) * sin(time*14.14);
	uv.y += 0.002 * sin(time*1.618) * sin(time*17.32);
	return uv;
}

void main() {
	gl_FragColor = texture2D(bitmap, ShakeUV(openfl_TextureCoordv, time / 2.0));
}')

  	public function new()
  	{
  		super();

		this.time.value = [0];
  	}
}

class HypnoCamEffectsOneShader extends FlxShader
{
	@:glFragmentSource('
#pragma header
/**
* https://www.shadertoy.com/view/wsdBWM
**/

uniform float distort;

vec2 pincushionDistortion(in vec2 uv, float strength) {
	vec2 st = uv - 0.5;
	float uvA = atan(st.x, st.y);
	float uvD = dot(st, st);
	return 0.5 + vec2(sin(uvA), cos(uvA)) * sqrt(uvD) * (1.0 - strength * uvD);
}

void main() {
	float rChannel = texture2D(bitmap, pincushionDistortion(openfl_TextureCoordv, 0.3 * distort)).r;
	float gChannel = texture2D(bitmap, pincushionDistortion(openfl_TextureCoordv, 0.15 * distort)).g;
	float bChannel = texture2D(bitmap, pincushionDistortion(openfl_TextureCoordv, 0.075 * distort)).b;
	gl_FragColor = vec4(rChannel, gChannel, bChannel, 1.0);
}')

  	public function new()
  	{
  		super();

		this.distort.value = [0];
  	}
}

class VHSCoolShader extends FlxShader
{
	@:glFragmentSource('
// Based on a shader by FMS_Cat.
// https://www.shadertoy.com/view/XtBXDt
// Modified to support OpenFL.
#pragma header
#define PI 3.14159265

uniform float time;

vec3 tex2D(sampler2D _tex,vec2 _p)
{
	vec3 col=texture2D(_tex,_p).xyz;
	if(.5<abs(_p.x-.5)){
		col=vec3(.1);
	}
		return col;
}

float hash(vec2 _v)
{
	return fract(sin(dot(_v,vec2(89.44,19.36)))*22189.22);
}

float iHash(vec2 _v,vec2 _r)
{
	float h00=hash(vec2(floor(_v*_r+vec2(0.,0.))/_r));
	float h10=hash(vec2(floor(_v*_r+vec2(1.,0.))/_r));
	float h01=hash(vec2(floor(_v*_r+vec2(0.,1.))/_r));
	float h11=hash(vec2(floor(_v*_r+vec2(1.,1.))/_r));
	vec2 ip=vec2(smoothstep(vec2(0.,0.),vec2(1.,1.),mod(_v*_r,1.)));
	return(h00*(1.-ip.x)+h10*ip.x)*(1.-ip.y)+(h01*(1.-ip.x)+h11*ip.x)*ip.y;
}

float noise(vec2 _v)
{
	float sum=0.;
	for(int i=1;i<9;i++)
	{
		sum+=iHash(_v+vec2(i),vec2(2.*pow(2.,float(i))))/pow(2.,float(i));
	}
	return sum;
}

void main()
{
	vec2 uv=openfl_TextureCoordv;
	vec2 uvn=uv;
	vec3 col=vec3(0.);

	// tape wave
	uvn.x+=(noise(vec2(uvn.y,time))-.5)*.005;
	uvn.x+=(noise(vec2(uvn.y*100.,time*10.))-.5)*.01;

	// tape crease
	float tcPhase=clamp((sin(uvn.y*8.-time*PI*1.2)-.92)*noise(vec2(time)),0.,.01)*10.;
	float tcNoise=max(noise(vec2(uvn.y*100.,time*10.))-.5,0.);
	uvn.x=uvn.x-tcNoise*tcPhase;

	// switching noise
	float snPhase=smoothstep(.03,0.,uvn.y);
	uvn.y+=snPhase*.3;
	uvn.x+=snPhase*((noise(vec2(uv.y*100.,time*10.))-.5)*.2);

	col=tex2D(bitmap,uvn);
	col*=1.-tcPhase;
	col=mix(
		col,
		col.yzx,
		snPhase
	);

	// bloom
	for(float x=-4.;x<2.5;x+=1.){
		col.xyz+=vec3(
			tex2D(bitmap,uvn+vec2(x-0.,0.)*7E-3).x,
			tex2D(bitmap,uvn+vec2(x-2.,0.)*7E-3).y,
			tex2D(bitmap,uvn+vec2(x-4.,0.)*7E-3).z
		)*.1;
	}
	col*=.6;

	// ac beat
	col*=1.+clamp(noise(vec2(0.,uv.y+time*.2))*.6-.25,0.,.1);

	gl_FragColor=vec4(col,1.);
}
')

  	public function new()
  	{
  		super();
  	}
}


class NightTimeShader extends FlxShader // https://www.shadertoy.com/view/3tfcD8
{
	//SHADERTOY PORT FIX
	//is there a better way to do this? most likely
	//but it works so eh
	#if !mac
	@:glFragmentSource('
	#pragma header
	
	uniform float iTime;

	//****MAKE SURE TO remove the parameters from mainImage.

	float NoiseSeed;
	float randomFloat(){
		NoiseSeed = sin(NoiseSeed) * 84522.13219145687;
		return fract(NoiseSeed);
	}

	float SCurve (float value, float amount, float correction) {
		float curve = 1.0;

		if (value < 0.5) {
			curve = pow(value, amount) * pow(2.0, amount) * 0.5;
		}
		else {
			curve = 1.0 - pow(1.0 - value, amount) * pow(2.0, amount) * 0.5;
		}

		return pow(curve, correction);
	}




	//ACES tonemapping from: https://www.shadertoy.com/view/wl2SDt
	vec3 ACESFilm(vec3 x) {
		float a = 2.51;
		float b = 0.03;
		float c = 2.43;
		float d = 0.59;
		float e = 0.14;
		return (x*(a*x+b))/(x*(c*x+d)+e);
	}




	//Chromatic Abberation from: https://www.shadertoy.com/view/XlKczz
	vec3 chromaticAbberation(sampler2D tex, vec2 uv, float amount) {
		float aberrationAmount = amount/10.0;
		vec2 distFromCenter = uv - 0.5;

		// stronger aberration near the edges by raising to power 3
		vec2 aberrated = aberrationAmount * pow(distFromCenter, vec2(3.0, 3.0));

		vec3 color = vec3(0.0);

		for (int i = 1; i <= 8; i++) {
			float weight = 1.0 / pow(2.0, float(i));
			color.r += flixel_texture2D(tex, uv - float(i) * aberrated).r * weight;
			color.b += flixel_texture2D(tex, uv + float(i) * aberrated).b * weight;
		}

		color.g = flixel_texture2D(tex, uv).g * 0.9961; // 0.9961 = weight(1)+weight(2)+...+weight(8);

		return color;
	}




	//film grain from: https://www.shadertoy.com/view/wl2SDt
	vec3 filmGrain() {
		return vec3(0.9 + randomFloat()*0.15);
	}




	//Sigmoid Contrast from: https://www.shadertoy.com/view/MlXGRf
	vec3 contrast(vec3 color)
	{
		return vec3(SCurve(color.r, 3.0, 1.0),
				SCurve(color.g, 4.0, 0.7),
				SCurve(color.b, 2.6, 0.6)
				);
	}




	//anamorphic-ish flares from: https://www.shadertoy.com/view/MlsfRl
	vec3 flares(sampler2D tex, vec2 uv, float threshold, float intensity, float stretch, float brightness) {
		threshold = 1.0 - threshold;

		vec3 hdr = flixel_texture2D(tex, uv).rgb;
		hdr = vec3(floor(threshold+pow(hdr.r, 1.0)));

		float d = intensity; //200.;
		float c = intensity*stretch; //100.;


		//horizontal
		for (float i=c; i>-1.0; i--)
		{
			float texL = flixel_texture2D(tex, uv+vec2(i/d, 0.0)).r;
			float texR = flixel_texture2D(tex, uv-vec2(i/d, 0.0)).r;
			hdr += floor(threshold+pow(max(texL,texR), 4.0))*(1.0-i/c);
		}

		//vertical
		for (float i=c/2.0; i>-1.0; i--)
		{
			float texU = flixel_texture2D(tex, uv+vec2(0.0, i/d)).r;
			float texD = flixel_texture2D(tex, uv-vec2(0.0, i/d)).r;
			hdr += floor(threshold+pow(max(texU,texD), 40.0))*(1.0-i/c) * 0.25;
		}

		hdr *= vec3(0.5,0.4,1.0); //tint

		return hdr*brightness;
	}




	//glow from: https://www.shadertoy.com/view/XslGDr (unused but useful)
	vec3 samplef(vec2 tc, vec3 color)
	{
		return pow(color, vec3(2.2, 2.2, 2.2));
	}

	vec3 highlights(vec3 pixel, float thres)
	{
		float val = (pixel.x + pixel.y + pixel.z) / 3.0;
		return pixel * smoothstep(thres - 0.1, thres + 0.1, val);
	}

	vec3 hsample(vec3 color, vec2 tc)
	{
		return highlights(samplef(tc, color), 0.6);
	}

	vec3 blur(vec3 col, vec2 tc, float offs)
	{
		vec4 xoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.x;
		vec4 yoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.y;

		vec3 color = vec3(0.0, 0.0, 0.0);
		color += hsample(col, tc + vec2(xoffs.x, yoffs.x)) * 0.00366;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.x)) * 0.01465;
		color += hsample(col, tc + vec2(	0.0, yoffs.x)) * 0.02564;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.x)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.x)) * 0.00366;

		color += hsample(col, tc + vec2(xoffs.x, yoffs.y)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.y)) * 0.05861;
		color += hsample(col, tc + vec2(	0.0, yoffs.y)) * 0.09524;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.y)) * 0.05861;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.y)) * 0.01465;

		color += hsample(col, tc + vec2(xoffs.x, 0.0)) * 0.02564;
		color += hsample(col, tc + vec2(xoffs.y, 0.0)) * 0.09524;
		color += hsample(col, tc + vec2(	0.0, 0.0)) * 0.15018;
		color += hsample(col, tc + vec2(xoffs.z, 0.0)) * 0.09524;
		color += hsample(col, tc + vec2(xoffs.w, 0.0)) * 0.02564;

		color += hsample(col, tc + vec2(xoffs.x, yoffs.z)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.z)) * 0.05861;
		color += hsample(col, tc + vec2(	0.0, yoffs.z)) * 0.09524;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.z)) * 0.05861;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.z)) * 0.01465;

		color += hsample(col, tc + vec2(xoffs.x, yoffs.w)) * 0.00366;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.w)) * 0.01465;
		color += hsample(col, tc + vec2(	0.0, yoffs.w)) * 0.02564;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.w)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.w)) * 0.00366;

		return color;
	}

	vec3 glow(vec3 col, vec2 uv)
	{
		vec3 color = blur(col, uv, 2.0);
		color += blur(col, uv, 3.0);
		color += blur(col, uv, 5.0);
		color += blur(col, uv, 7.0);
		color /= 4.0;

		color += samplef(uv, col);

		return color;
	}




	void main() {
		vec2 uv = openfl_TextureCoordv.xy;
		vec3 color = flixel_texture2D(bitmap, uv).xyz;

		//gl_FragColor.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;


		//chromatic abberation
		color = chromaticAbberation(bitmap, uv, 0.3);


		//film grain
		color *= filmGrain();


		//ACES Tonemapping
		color = ACESFilm(color);


		//glow
		color = clamp(.1 + glow(color, uv) * .9, .0, 1.);


		//contrast
		color = contrast(color) * 0.9;


		//flare
		color += flares(bitmap, uv, 0.9, 200.0, .04, 0.1);


		float theAlpha = flixel_texture2D(bitmap,uv).a;


		//output
		gl_FragColor = vec4(color,theAlpha);
	}')
	#else
	@:glFragmentSource('
	#pragma header
	vec2 uv = openfl_TextureCoordv.xy;
	uniform float iTime;

	//****MAKE SURE TO remove the parameters from mainImage.

	float NoiseSeed;
	float randomFloat(){
		NoiseSeed = sin(NoiseSeed) * 84522.13219145687;
		return fract(NoiseSeed);
	}

	float SCurve (float value, float amount, float correction) {
		float curve = 1.0;

		if (value < 0.5) {
			curve = pow(value, amount) * pow(2.0, amount) * 0.5;
		}
		else {
			curve = 1.0 - pow(1.0 - value, amount) * pow(2.0, amount) * 0.5;
		}

		return pow(curve, correction);
	}




	//ACES tonemapping from: https://www.shadertoy.com/view/wl2SDt
	vec3 ACESFilm(vec3 x) {
		float a = 2.51;
		float b = 0.03;
		float c = 2.43;
		float d = 0.59;
		float e = 0.14;
		return (x*(a*x+b))/(x*(c*x+d)+e);
	}




	//Chromatic Abberation from: https://www.shadertoy.com/view/XlKczz
	vec3 chromaticAbberation(sampler2D tex, vec2 uv, float amount) {
		float aberrationAmount = amount/10.0;
		vec2 distFromCenter = uv - 0.5;

		// stronger aberration near the edges by raising to power 3
		vec2 aberrated = aberrationAmount * pow(distFromCenter, vec2(3.0, 3.0));

		vec3 color = vec3(0.0);

		for (int i = 1; i <= 8; i++) {
			float weight = 1.0 / pow(2.0, float(i));
			color.r += flixel_texture2D(tex, uv - float(i) * aberrated).r * weight;
			color.b += flixel_texture2D(tex, uv + float(i) * aberrated).b * weight;
		}

		color.g = flixel_texture2D(tex, uv).g * 0.9961; // 0.9961 = weight(1)+weight(2)+...+weight(8);

		return color;
	}




	//film grain from: https://www.shadertoy.com/view/wl2SDt
	vec3 filmGrain() {
		return vec3(0.9 + randomFloat()*0.15);
	}




	//Sigmoid Contrast from: https://www.shadertoy.com/view/MlXGRf
	vec3 contrast(vec3 color)
	{
		return vec3(SCurve(color.r, 3.0, 1.0),
				SCurve(color.g, 4.0, 0.7),
				SCurve(color.b, 2.6, 0.6)
				);
	}




	//anamorphic-ish flares from: https://www.shadertoy.com/view/MlsfRl
	vec3 flares(sampler2D tex, vec2 uv, float threshold, float intensity, float stretch, float brightness) {
		threshold = 1.0 - threshold;

		vec3 hdr = flixel_texture2D(tex, uv).rgb;
		hdr = vec3(floor(threshold+pow(hdr.r, 1.0)));

		float d = intensity; //200.;
		float c = intensity*stretch; //100.;


		//horizontal
		for (float i=c; i>-1.0; i--)
		{
			float texL = flixel_texture2D(tex, uv+vec2(i/d, 0.0)).r;
			float texR = flixel_texture2D(tex, uv-vec2(i/d, 0.0)).r;
			hdr += floor(threshold+pow(max(texL,texR), 4.0))*(1.0-i/c);
		}

		//vertical
		for (float i=c/2.0; i>-1.0; i--)
		{
			float texU = flixel_texture2D(tex, uv+vec2(0.0, i/d)).r;
			float texD = flixel_texture2D(tex, uv-vec2(0.0, i/d)).r;
			hdr += floor(threshold+pow(max(texU,texD), 40.0))*(1.0-i/c) * 0.25;
		}

		hdr *= vec3(0.5,0.4,1.0); //tint

		return hdr*brightness;
	}




	//glow from: https://www.shadertoy.com/view/XslGDr (unused but useful)
	vec3 samplef(vec2 tc, vec3 color)
	{
		return pow(color, vec3(2.2, 2.2, 2.2));
	}

	vec3 highlights(vec3 pixel, float thres)
	{
		float val = (pixel.x + pixel.y + pixel.z) / 3.0;
		return pixel * smoothstep(thres - 0.1, thres + 0.1, val);
	}

	vec3 hsample(vec3 color, vec2 tc)
	{
		return highlights(samplef(tc, color), 0.6);
	}

	vec3 blur(vec3 col, vec2 tc, float offs)
	{
		vec4 xoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.x;
		vec4 yoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.y;

		vec3 color = vec3(0.0, 0.0, 0.0);
		color += hsample(col, tc + vec2(xoffs.x, yoffs.x)) * 0.00366;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.x)) * 0.01465;
		color += hsample(col, tc + vec2(	0.0, yoffs.x)) * 0.02564;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.x)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.x)) * 0.00366;

		color += hsample(col, tc + vec2(xoffs.x, yoffs.y)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.y)) * 0.05861;
		color += hsample(col, tc + vec2(	0.0, yoffs.y)) * 0.09524;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.y)) * 0.05861;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.y)) * 0.01465;

		color += hsample(col, tc + vec2(xoffs.x, 0.0)) * 0.02564;
		color += hsample(col, tc + vec2(xoffs.y, 0.0)) * 0.09524;
		color += hsample(col, tc + vec2(	0.0, 0.0)) * 0.15018;
		color += hsample(col, tc + vec2(xoffs.z, 0.0)) * 0.09524;
		color += hsample(col, tc + vec2(xoffs.w, 0.0)) * 0.02564;

		color += hsample(col, tc + vec2(xoffs.x, yoffs.z)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.z)) * 0.05861;
		color += hsample(col, tc + vec2(	0.0, yoffs.z)) * 0.09524;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.z)) * 0.05861;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.z)) * 0.01465;

		color += hsample(col, tc + vec2(xoffs.x, yoffs.w)) * 0.00366;
		color += hsample(col, tc + vec2(xoffs.y, yoffs.w)) * 0.01465;
		color += hsample(col, tc + vec2(	0.0, yoffs.w)) * 0.02564;
		color += hsample(col, tc + vec2(xoffs.z, yoffs.w)) * 0.01465;
		color += hsample(col, tc + vec2(xoffs.w, yoffs.w)) * 0.00366;

		return color;
	}

	vec3 glow(vec3 col, vec2 uv)
	{
		vec3 color = blur(col, uv, 2.0);
		color += blur(col, uv, 3.0);
		color += blur(col, uv, 5.0);
		color += blur(col, uv, 7.0);
		color /= 4.0;

		color += samplef(uv, col);

		return color;
	}




	void main() {
		vec2 uv = openfl_TextureCoordv.xy;
		vec3 color = flixel_texture2D(bitmap, uv).xyz;

		//gl_FragColor.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;


		//chromatic abberation
		color = chromaticAbberation(bitmap, uv, 0.3);


		//film grain
		//color *= filmGrain();


		//ACES Tonemapping
		color = ACESFilm(color);


		//glow
		color = clamp(.1 + glow(color, uv) * .9, .0, 1.);


		//contrast
		color = contrast(color) * 0.9;


		//flare
		color += flares(bitmap, uv, 0.9, 200.0, .04, 0.1);


		float theAlpha = flixel_texture2D(bitmap,uv).a;


		//output
		gl_FragColor = vec4(color,theAlpha);
	}')
	#end

	public function new()
	{
		super();
	}
}

class NightTimeEffect extends Effect
{
	public var shader:NightTimeShader = new NightTimeShader();

	public function new()
	{
		shader.iTime.value = [0];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.iTime.value[0] += elapsed;
	}
}
class RainbowShader extends FlxShader //https://www.shadertoy.com/view/MdffDS
{
	@:glFragmentSource('
//SHADERTOY PORT FIX
#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
//****MAKE SURE TO remove the parameters from mainImage.
//SHADERTOY PORT FIX
#define posterSteps 4.0
#define lumaMult 0.5
#define timeMult 0.15
#define BW 0

float rgbToGray(vec4 rgba) {
	const vec3 W = vec3(0.2125, 0.7154, 0.0721);
	return dot(rgba.xyz, W);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
	vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
	float theAlpha = flixel_texture2D(bitmap, uv).a;

	vec4 color = texture(iChannel0, uv);
	float luma = rgbToGray(color) * lumaMult;
	float lumaIndex = floor(luma * posterSteps);
	float lumaFloor = lumaIndex / posterSteps;
	float lumaRemainder = (luma - lumaFloor) * posterSteps;
	if(mod(lumaIndex, 2.) == 0.) lumaRemainder = 1.0 - lumaRemainder; // flip luma remainder for smooth color transitions
	float timeInc = iTime * timeMult;
	float lumaCycle = mod(luma + timeInc, 1.);
	vec3 roygbiv = hsv2rgb(vec3(lumaCycle, 1., lumaRemainder));
	if(BW == 1) {
		float bw = rgbToGray(vec4(roygbiv, 1.));
	fragColor = vec4(vec3(bw), theAlpha);
	} else {
		fragColor = vec4(roygbiv, theAlpha);
	}
}
')

	public function new()
	{
		super();
	}

}

class RainbowEffect extends Effect
{
	public var shader:RainbowShader = new RainbowShader();

	public function new()
	{
		shader.iTime.value = [0];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.iTime.value[0] += elapsed;
	}
}

class Glitch02Shader extends FlxShader //https://www.shadertoy.com/view/lsfGD2#
{

	@:glFragmentSource('
//SHADERTOY PORT FIX (thx bb)
#pragma header

uniform float uTime;
uniform float iMouseX;
uniform int NUM_SAMPLES;
uniform float glitchMultiply;

float sat( float t ) {
	return clamp( t, 0.0, 1.0 );
}

vec2 sat( vec2 t ) {
	return clamp( t, 0.0, 1.0 );
}

//remaps inteval [a;b] to [0;1]
float remap  ( float t, float a, float b ) {
	return sat( (t - a) / (b - a) );
}

//note: /\\ t=[0;0.5;1], y=[0;1;0]
float linterp( float t ) {
	return sat( 1.0 - abs( 2.0*t - 1.0 ) );
}

vec3 spectrum_offset( float t ) {
	float t0 = 3.0 * t - 1.5;
	return clamp( vec3( -t0, 1.0-abs(t0), t0), 0.0, 1.0);
	/*
	vec3 ret;
	float lo = step(t,0.5);
	float hi = 1.0-lo;
	float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
	float neg_w = 1.0-w;
	ret = vec3(lo,1.0,hi) * vec3(neg_w, w, neg_w);
	return pow( ret, vec3(1.0/2.2) );
*/
}

//note: [0;1]
float rand( vec2 n ) {
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}

//note: [-1;1]
float srand( vec2 n ) {
	return rand(n) * 2.0 - 1.0;
}

float mytrunc( float x, float num_levels )
{
	return floor(x*num_levels) / num_levels;
}
vec2 mytrunc( vec2 x, float num_levels )
{
	return floor(x*num_levels) / num_levels;
}

void main()
{
	float aspect = openfl_TextureSize.x / openfl_TextureSize.y;
	vec2 uv = openfl_TextureCoordv;
	// uv.y = 1.0 - uv.y;

	float time = mod(uTime, 32.0); // + modelmat[0].x + modelmat[0].z;

	float GLITCH = (0.1 + iMouseX / openfl_TextureSize.x) * glitchMultiply;

	//float rdist = length( (uv - vec2(0.5,0.5))*vec2(aspect, 1.0) )/1.4;
	//GLITCH *= rdist;

	float gnm = sat( GLITCH );
	float rnd0 = rand( mytrunc( vec2(time, time), 6.0 ) );
	float r0 = sat((1.0-gnm)*0.7 + rnd0);
	float rnd1 = rand( vec2(mytrunc( uv.x, 10.0*r0 ), time) ); //horz
	//float r1 = 1.0f - sat( (1.0f-gnm)*0.5f + rnd1 );
	float r1 = 0.5 - 0.5 * gnm + rnd1;
	r1 = 1.0 - max( 0.0, ((r1<1.0) ? r1 : 0.9999999) ); //note: weird ass bug on old drivers
	float rnd2 = rand( vec2(mytrunc( uv.y, 40.0*r1 ), time) ); //vert
	float r2 = sat( rnd2 );

	float rnd3 = rand( vec2(mytrunc( uv.y, 10.0*r0 ), time) );
	float r3 = (1.0-sat(rnd3+0.8)) - 0.1;

	float pxrnd = rand( uv + time );

	float ofs = 0.05 * r2 * GLITCH * ( rnd0 > 0.5 ? 1.0 : -1.0 );
	ofs += 0.5 * pxrnd * ofs;

	uv.y += 0.1 * r3 * GLITCH;

	// const int NUM_SAMPLES = 10;
	// const float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);
	float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);

	vec4 sum = vec4(0.0);
	vec3 wsum = vec3(0.0);
	for( int i=0; i<NUM_SAMPLES; ++i )
	{
		float t = float(i) * RCP_NUM_SAMPLES_F;
		uv.x = sat( uv.x + ofs * t );
		vec4 samplecol = texture2D( bitmap, uv );
		vec3 s = spectrum_offset( t );
		samplecol.rgb = samplecol.rgb * s;
		sum += samplecol;
		wsum += s;
	}
	sum.rgb /= wsum;
	sum.a *= RCP_NUM_SAMPLES_F;

	//gl_FragColor = vec4( sum.bbb, 1.0 ); return;

	gl_FragColor.a = sum.a;
	gl_FragColor.rgb = sum.rgb; // * outcol0.a;
}')

	public function new()
	{
		super();
	}
}

class Glitch02Effect extends Effect
{
	public var shader:Glitch02Shader = new Glitch02Shader();

	public function new(mouse:Int, numsample:Int, glithcmult:Int)
	{
		shader.uTime.value = [0];
		shader.iMouseX.value = [mouse];
		shader.NUM_SAMPLES.value = [numsample];
		shader.glitchMultiply.value = [glithcmult];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.uTime.value[0] += elapsed;
	}
}

class DistortedTVShader extends FlxShader //https://www.shadertoy.com/view/ldXGW4
{
	@:glFragmentSource('
//SHADERTOY PORT FIX (thx bb)
#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
// change these values to 0.0 to turn off individual effects
float vertJerkOpt = 1.0;
float vertMovementOpt = 1.0;
float bottomStaticOpt = 1.0;
float scalinesOpt = 1.0;
float rgbOffsetOpt = 0.2;
float horzFuzzOpt = 1.0;

// Noise generation functions borrowed from:
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
	return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
{
	const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
						0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
						-0.577350269189626,  // -1.0 + 2.0 * C.x
						0.024390243902439); // 1.0 / 41.0
// First corner
	vec2 i  = floor(v + dot(v, C.yy) );
	vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
	vec2 i1;
	//i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
	//i1.y = 1.0 - i1.x;
	i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	// x0 = x0 - 0.0 + 0.0 * C.xx ;
	// x1 = x0 - i1 + 1.0 * C.xx ;
	// x2 = x0 - 1.0 + 2.0 * C.xx ;
	vec4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;

// Permutations
	i = mod289(i); // Avoid truncation effects in permutation
	vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

	vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
	m = m*m ;
	m = m*m ;

// Gradients: 41 points uni formly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;

	// Normalise gradients implicitly by scaling m
	// Approximation of: m *= inversesqrt( a0*a0 + h*h );
		m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

	// Compute final noise value at P
		vec3 g;
		g.x  = a0.x  * x0.x  + h.x  * x0.y;
		g.yz = a0.yz * x12.xz + h.yz * x12.yw;
		return 130.0 * dot(m, g);
	}

	float staticV(vec2 uv) {
		float staticHeight = snoise(vec2(9.0,iTime*1.2+3.0))*0.3+5.0;
		float staticAmount = snoise(vec2(1.0,iTime*1.2-6.0))*0.1+0.3;
		float staticStrength = snoise(vec2(-9.75,iTime*0.6-3.0))*2.0+2.0;
		return (1.0-step(snoise(vec2(5.0*pow(iTime,2.0)+pow(uv.x*7.0,1.2),pow((mod(iTime,100.0)+100.0)*uv.y*0.3+3.0,staticHeight))),staticAmount))*staticStrength;
	}


void main()
{
    vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;

	float jerkOffset = (1.0-step(snoise(vec2(iTime*1.3,5.0)),0.8))*0.05;

	float fuzzOffset = snoise(vec2(iTime*15.0,uv.y*80.0))*0.003;
	float largeFuzzOffset = snoise(vec2(iTime*1.0,uv.y*25.0))*0.004;

	float vertMovementOn = (1.0-step(snoise(vec2(iTime*0.2,8.0)),0.4))*vertMovementOpt;
	float vertJerk = (1.0-step(snoise(vec2(iTime*1.5,5.0)),0.6))*vertJerkOpt;
	float vertJerk2 = (1.0-step(snoise(vec2(iTime*5.5,5.0)),0.2))*vertJerkOpt;
	float yOffset = abs(sin(iTime)*4.0)*vertMovementOn+vertJerk*vertJerk2*0.3;
	float y = mod(uv.y+yOffset,1.0);


	float xOffset = (fuzzOffset + largeFuzzOffset) * horzFuzzOpt;

	float staticVal = 0.0;

	float theAlpha = flixel_texture2D(bitmap,uv).a;

	for (float y = -1.0; y <= 1.0; y += 1.0) {
		float maxDist = 5.0/200.0;
		float dist = y/200.0;
		staticVal += staticV(vec2(uv.x,uv.y+dist))*(maxDist-abs(dist))*1.5;
	}

	staticVal *= bottomStaticOpt;

	float red 	=   texture(	iChannel0, 	vec2(uv.x + xOffset -0.01*rgbOffsetOpt,y)).r+staticVal;
	float green = 	texture(	iChannel0, 	vec2(uv.x + xOffset,	  y)).g+staticVal;
	float blue 	=	texture(	iChannel0, 	vec2(uv.x + xOffset +0.01*rgbOffsetOpt,y)).b+staticVal;

	vec3 color = vec3(red,green,blue);
	float scanline = sin(uv.y*800.0)*0.04*scalinesOpt;
	color -= scanline;

	gl_FragColor = vec4(color,theAlpha);
}
')

	public function new()
	{
		super();
	}
}

class DistortedTVShaderHUD extends FlxShader //https://www.shadertoy.com/view/ldXGW4 fuck off the same shader because i don't want to apply the other one to camhud
{
	@:glFragmentSource('
//SHADERTOY PORT FIX (thx bb)
#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
// change these values to 0.0 to turn off individual effects
float vertJerkOpt = 0.0;
float vertMovementOpt = 0.0;
float bottomStaticOpt = 1.0;
float scalinesOpt = 1.0;
float rgbOffsetOpt = 0.3;
float horzFuzzOpt = 1.0;

// Noise generation functions borrowed from:
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
	return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
{
	const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
						0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
						-0.577350269189626,  // -1.0 + 2.0 * C.x
						0.024390243902439); // 1.0 / 41.0
// First corner
	vec2 i  = floor(v + dot(v, C.yy) );
	vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
	vec2 i1;
	//i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
	//i1.y = 1.0 - i1.x;
	i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	// x0 = x0 - 0.0 + 0.0 * C.xx ;
	// x1 = x0 - i1 + 1.0 * C.xx ;
	// x2 = x0 - 1.0 + 2.0 * C.xx ;
	vec4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;

// Permutations
	i = mod289(i); // Avoid truncation effects in permutation
	vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

	vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
	m = m*m ;
	m = m*m ;

// Gradients: 41 points uni formly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;

	// Normalise gradients implicitly by scaling m
	// Approximation of: m *= inversesqrt( a0*a0 + h*h );
		m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

	// Compute final noise value at P
		vec3 g;
		g.x  = a0.x  * x0.x  + h.x  * x0.y;
		g.yz = a0.yz * x12.xz + h.yz * x12.yw;
		return 130.0 * dot(m, g);
	}

	float staticV(vec2 uv) {
		float staticHeight = snoise(vec2(9.0,iTime*1.2+3.0))*0.3+5.0;
		float staticAmount = snoise(vec2(1.0,iTime*1.2-6.0))*0.1+0.3;
		float staticStrength = snoise(vec2(-9.75,iTime*0.6-3.0))*2.0+2.0;
		return (1.0-step(snoise(vec2(5.0*pow(iTime,2.0)+pow(uv.x*7.0,1.2),pow((mod(iTime,100.0)+100.0)*uv.y*0.3+3.0,staticHeight))),staticAmount))*staticStrength;
	}


void main()
{
    vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;

	float jerkOffset = (1.0-step(snoise(vec2(iTime*1.3,5.0)),0.8))*0.05;

	float fuzzOffset = snoise(vec2(iTime*15.0,uv.y*80.0))*0.003;
	float largeFuzzOffset = snoise(vec2(iTime*1.0,uv.y*25.0))*0.004;

	float vertMovementOn = (1.0-step(snoise(vec2(iTime*0.2,8.0)),0.4))*vertMovementOpt;
	float vertJerk = (1.0-step(snoise(vec2(iTime*1.5,5.0)),0.6))*vertJerkOpt;
	float vertJerk2 = (1.0-step(snoise(vec2(iTime*5.5,5.0)),0.2))*vertJerkOpt;
	float yOffset = abs(sin(iTime)*4.0)*vertMovementOn+vertJerk*vertJerk2*0.3;
	float y = mod(uv.y+yOffset,1.0);


	float xOffset = (fuzzOffset + largeFuzzOffset) * horzFuzzOpt;

	float staticVal = 0.0;

	float theAlpha = flixel_texture2D(bitmap,uv).a;

	for (float y = -1.0; y <= 1.0; y += 1.0) {
		float maxDist = 5.0/200.0;
		float dist = y/200.0;
		staticVal += staticV(vec2(uv.x,uv.y+dist))*(maxDist-abs(dist))*1.5;
	}

	staticVal *= bottomStaticOpt;

	float red 	=   texture(	iChannel0, 	vec2(uv.x + xOffset -0.01*rgbOffsetOpt,y)).r+staticVal;
	float green = 	texture(	iChannel0, 	vec2(uv.x + xOffset,	  y)).g+staticVal;
	float blue 	=	texture(	iChannel0, 	vec2(uv.x + xOffset +0.01*rgbOffsetOpt,y)).b+staticVal;

	vec3 color = vec3(red,green,blue);
	float scanline = sin(uv.y*800.0)*0.04*scalinesOpt;
	color -= scanline;

	gl_FragColor = vec4(color,theAlpha);
}
')

	public function new()
	{
		super();
	}
}

class DistortedTVEffect extends Effect
{
	public var shader:DistortedTVShader = new DistortedTVShader();

	public function new()
	{
		shader.iTime.value = [0];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.iTime.value[0] += elapsed;
	}
}

class DistortedTVEffectHUD extends Effect //fuck
{
	public var shader:DistortedTVShaderHUD = new DistortedTVShaderHUD();

	public function new()
	{
		shader.iTime.value = [0];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.iTime.value[0] += elapsed;
	}
}

class RadialBlurShader extends FlxShader
{
	@:glFragmentSource('
#pragma header
//https://github.com/bbpanzu/FNF-Sunday/blob/main/source_sunday/RadialBlur.hx
//https://www.shadertoy.com/view/XsfSDs
uniform float cx;
uniform float cy;
uniform float blurWidth;

const int nsamples = 30; //samples

void main(){
	vec4 color = texture2D(bitmap, openfl_TextureCoordv);
	vec2 res;
	res = openfl_TextureCoordv;
	vec2 pp = vec2(cx, cy);
	vec2 center = pp;
	float blurStart = 1.0;


	vec2 uv = openfl_TextureCoordv.xy;

	uv -= center;
	float precompute = blurWidth * (1.0 / float(nsamples - 1));

	for(int i = 0; i < nsamples; i++)
	{
		float scale = blurStart + (float(i)* precompute);
		color += texture2D(bitmap, uv * scale + center);
	}


	color /= float(nsamples);

	gl_FragColor = color;

}')

	public function new()
	{
		super();

		this.cx.value = [0.5]; //center x (0.0 - 1.0)
		this.cy.value = [0.5]; //center y (0.0 - 1.0)
		this.blurWidth.value = [0.5]; // blurAmount
	}
}

class VHSGlitchShader extends FlxShader //https://www.shadertoy.com/view/Ms3XWH
{
  @:glFragmentSource('
  #pragma header

uniform vec2 iResolution;
uniform float iTime;
vec2 uv;

const float range = 0.05;
const float noiseQuality = 250.0;
const float noiseIntensity = 0.0088;
const float offsetIntensity = 0.02;
const float colorOffsetIntensity = 1.3;

float rand(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset)
{
	float edge0 = (pos - range);
	float edge1 = (pos + range);

	float x = smoothstep(edge0, pos, uvY) * offset;
	x -= smoothstep(pos, edge1, uvY) * offset;
	return x;
}

void main()
{
	float theAlpha = flixel_texture2D(bitmap, uv).a;

	vec2 fragCoord = openfl_TextureCoordv * iResolution;

	uv = fragCoord.xy / iResolution.xy;

	for (float i = 0.0; i < 0.71; i += 0.1313)
	{
		float d = mod(iTime * i, 1.7);
		float o = sin(1.0 - tan(iTime * 0.24 * i));
		o *= offsetIntensity;
		uv.x += verticalBar(d, uv.y, o);
	}

	float uvY = uv.y;
	uvY *= noiseQuality;
	uvY = float(int(uvY)) * (1.0 / noiseQuality);
	float noise = rand(vec2(iTime * 0.00001, uvY));
	uv.x += noise * noiseIntensity;

	vec2 offsetR = vec2(0.006 * sin(iTime), 0.0) * colorOffsetIntensity;
	vec2 offsetG = vec2(0.0073 * (cos(iTime * 0.97)), 0.0) * colorOffsetIntensity;

	float r = texture2D(bitmap, uv + offsetR).r;
	float g = texture2D(bitmap, uv + offsetG).g;
	float b = texture2D(bitmap, uv).b;

	vec4 tex = vec4(r, g, b, theAlpha);
	gl_FragColor = tex;
}
  ')
  	public function new()
  	{
  		super();
  	}
}

class VHSGlitchEffect extends Effect //fuck
{
	public var shader:VHSGlitchShader = new VHSGlitchShader();

	public function new()
	{
		shader.iTime.value = [0];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.iTime.value[0] += elapsed;
	}
}

class CRTShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

uniform float iTime;

vec2 curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv *0.92 + 0.04;
	return uv;
}

void main()
{
	vec2 q = openfl_TextureCoordv;
	vec2 uv = q;
	uv = curve( uv );
	float oga = flixel_texture2D( bitmap, uv).a;
	vec3 oricol = flixel_texture2D( bitmap, uv ).xyz; //q and uv is aready a vex2. no need for (q.x,q.y)
	vec3 col;
	float x =  sin(0.3*iTime+uv.y*21.0)*sin(0.7*iTime+uv.y*29.0)*sin(0.3+0.33*iTime+uv.y*31.0)*0.0017;

	col.r = flixel_texture2D(bitmap,vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
	col.g = flixel_texture2D(bitmap,vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
	col.b = flixel_texture2D(bitmap,vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
	col.r += 0.08*flixel_texture2D(bitmap,0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
	col.g += 0.05*flixel_texture2D(bitmap,0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
	col.b += 0.08*flixel_texture2D(bitmap,0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

	col = clamp(col*0.6+0.4*col*col*1.0,0.0,1.0);

	float vig = (0.0 + 1.0*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y));
	col *= vec3(pow(vig,0.3));

	col *= vec3(0.95,1.05,0.95);
	col *= 2.8;

	float scans = clamp( 0.35+0.35*sin(3.5*iTime+uv.y*openfl_TextureSize.y*1.5), 0.0, 1.0);

	float s = pow(scans,1.7);
	col = col*vec3( 0.4+0.7*s) ;

	col *= 1.0+0.01*sin(110.0*iTime);
	if (uv.x < 0.0 || uv.x > 1.0)
		col *= 0.0;
	if (uv.y < 0.0 || uv.y > 1.0)
		col *= 0.0;

	col*=1.0-0.65*vec3(clamp((mod(openfl_TextureCoordv.x, 2.0)-1.0)*2.0,0.0,1.0));

	float comp = smoothstep( 0.1, 0.9, sin(iTime) );

	// Remove the next line to stop cross-fade between original and postprocess
	//	col = mix( col, oricol, comp );

	gl_FragColor = vec4(col,oga);
}')
	public function new()
	{
		super();
	}
}

class WavyShaderV1 extends FlxShader //credit Laztrix#5670
{
	@:glFragmentSource('
//SHADERTOY PORT FIX
#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
//SHADERTOY PORT FIX
uniform float frequency;
uniform float amplitude;
void main()
{
	vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
	vec2 texCoord = fragCoord.xy / iResolution.xy;

	vec2 pulse = sin(iTime - 8.0 * texCoord);
	float dist = 2.0 * length(texCoord.y - 0.5);

	vec2 newCoord = texCoord + 0.05 * vec2(0.0, pulse.x + pulse.y);

	vec2 interpCoord = mix(newCoord, texCoord, dist);

	fragColor = texture(iChannel0, interpCoord);
}
')
	public function new()
	{
		super();
	}
}

class WavyV1Effect extends Effect
{
	public var shader:WavyShaderV1 = new WavyShaderV1();

	public function new(frequency:Float, amplitude:Float)
	{
		shader.iTime.value = [0];
		shader.frequency.value = [frequency];
		shader.amplitude.value = [amplitude];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed){
		shader.iTime.value[0] += elapsed;
	}
}

class Shader3D extends FlxShader //soulles DX https://github.com/GrayAnimates/Soulles-DX/blob/main/shaders/3D%20Floor.frag
{
	@:glFragmentSource('
//SHADERTOY PORT FIX
#pragma header

uniform float curveX;
uniform float curveY;

void main() {
	vec2 pos = openfl_TextureCoordv;
	vec2 newPos = vec2((openfl_TextureCoordv.x * (1.0 - openfl_TextureCoordv.y)) + ((openfl_TextureCoordv.x + curveX) * openfl_TextureCoordv.y), openfl_TextureCoordv.y * (1.0 + curveY));
	gl_FragColor = flixel_texture2D(bitmap, newPos);
}
')
	public function new()
	{
		super();

		this.curveX.value = [0.05];
		this.curveY.value = [0.05];
	}
}

class DemonBlurShader extends FlxShader //credit cyn#5661
{
	@:glFragmentSource('
#pragma header

uniform float u_size;
uniform float u_alpha;

void main() {
	vec2 uv = openfl_TextureCoordv.xy;
	vec4 blur = vec4(0.0, 0.0, 0.0, 0.0);
	float a_size = u_size * 0.05 * openfl_TextureCoordv.y;
	for (float i = -a_size; i < a_size; i += 0.001) {blur.rgb += flixel_texture2D(bitmap, uv + vec2(0.0, i)).rgb / (1600.0 * a_size);}
	vec4 color = flixel_texture2D(bitmap, uv);
	gl_FragColor = color + u_alpha * (color * (color + blur * 1.5 - 1.0));
}')
	public function new()
	{
		super();
	}
}
class PixellateShader extends FlxShader //credit poggerboi#6856
{
	@:glFragmentSource('
//SHADERTOY PORT FIX (thx bb)
#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
//SHADERTOY PORT FIX

void mainImage() {
	vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
	vec2 coordinates = fragCoord.xy/iResolution.xy;
	const float size = 4.5;
	vec2 pixelSize = vec2(size/iResolution.x, size/iResolution.y);
	vec2 position = floor(coordinates/pixelSize)*pixelSize;
	vec4 finalColor = texture(iChannel0, position);
	fragColor = finalColor;
}
')
	public function new()
	{
		super();
	}
}
class GrayscaleShaderShit extends FlxShader //https://www.shadertoy.com/view/4sjGRD
{
	@:glFragmentSource('
	#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
const int lookupSize = 64;
const float errorCarry = 0.3;
vec2 uv;
vec2 iResolution;

float getGrayscale(vec2 coords){
	vec2 uv = coords / iResolution.xy;
	uv.y = 1.0-uv.y;
	vec3 sourcePixel = texture2D(iChannel0, uv).rgb;
	return length(sourcePixel*vec3(0.2126,0.7152,0.0722));
}

void main() {

	uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
iResolution = openfl_TextureSize;
	int topGapY = int(iResolution.y - gl_FragCoord.y);

	int cornerGapX = int((gl_FragCoord.x < 10.0) ? gl_FragCoord.x : iResolution.x - gl_FragCoord.x);
	int cornerGapY = int((gl_FragCoord.y < 10.0) ? gl_FragCoord.y : iResolution.y - gl_FragCoord.y);
	int cornerThreshhold = ((cornerGapX == 0) || (topGapY == 0)) ? 5 : 4;

	if (cornerGapX+cornerGapY < cornerThreshhold) {
		gl_FragColor = vec4(0,0,0,1);
	} else if (topGapY < 20) {
		if (topGapY == 19) {
			gl_FragColor = vec4(0,0,0,1);
		} else {
			gl_FragColor = vec4(1,1,1,1);
		}
	} else {
		float xError = 0.0;
		for(int xLook=0; xLook<lookupSize; xLook++){
			float grayscale = getGrayscale(gl_FragCoord.xy + vec2(-lookupSize+xLook,0));
			grayscale += xError;
			float bit = grayscale >= 0.5 ? 1.0 : 0.0;
			xError = (grayscale - bit)*errorCarry;
		}

		float yError = 0.0;
		for(int yLook=0; yLook<lookupSize; yLook++){
			float grayscale = getGrayscale(gl_FragCoord.xy + vec2(0,-lookupSize+yLook));
			grayscale += yError;
			float bit = grayscale >= 0.5 ? 1.0 : 0.0;
			yError = (grayscale - bit)*errorCarry;
		}

		float finalGrayscale = getGrayscale(gl_FragCoord.xy);
		finalGrayscale += xError*0.5 + yError*0.5;
		float finalBit = finalGrayscale >= 0.5 ? 1.0 : 0.0;

		gl_FragColor = vec4(finalBit,finalBit,finalBit,1);

	}

}
	')
	public function new()
	{
		super();
	}
}

class FakeBloomShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

uniform vec4 iMouse;

#define iChannel0 bitmap
#define fragColor gl_FragColor

void main()
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    float theAlpha = flixel_texture2D(iChannel0, uv).a;

    vec2 mouseInput = iMouse.xy;

    float mouseParamOne = 3.0;
    float mouseParamTwo = 0.6;

    if(iMouse.z > 0.0)
    {
        mouseParamOne = mouseInput.x * 8.0;
        mouseParamTwo = mouseInput.y / iResolution.y;
    }

    vec3 col0 = texture2D(iChannel0, fragCoord / iResolution, 0.0).rgb;
    vec3 col2 = texture2D(iChannel0, fragCoord / iResolution, mouseParamOne).rgb;

    vec3 col = mix(col0, col2, mouseParamTwo);
    fragColor = vec4(col, theAlpha);
}
	')
	public function new()
	{
		super();
	}
}

class BBPANZUBloomShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header


//BLOOM SHADER BY BBPANZU

const float amount = 2.0;

// GAUSSIAN BLUR SETTINGS
float dim = 1.8;
float Directions = 16.0;
float Quality = 8.0;
float Size = 18.0;

void main(void)
{
	vec2 Radius = Size/openfl_TextureSize.xy;
	vec2 uv = openfl_TextureCoordv.xy ;
	float Pi = 6.28318530718; // Pi*2
	vec4 Color = texture2D( bitmap, uv);

	for( float d=0.0; d<Pi; d+=Pi/Directions){
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality){
			float ex = (cos(d)*Size*i)/openfl_TextureSize.x;
			float why = (sin(d)*Size*i)/openfl_TextureSize.y;

			Color += flixel_texture2D( bitmap, uv+vec2(ex,why));
		}
	}

	Color /= (dim * Quality) * Directions - 15.0;
	vec4 bloom =  (flixel_texture2D( bitmap, uv)/ dim)+Color;

	gl_FragColor = bloom;

}
	')
	public function new()
	{
		super();
	}
}

class ChromaticAberrationShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

uniform float rOffset;
uniform float gOffset;
uniform float bOffset;

void main()
{
	vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffset, 0.0));
	vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffset, 0.0));
	vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffset, 0.0));
	vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
	toUse.r = col1.r;
	toUse.g = col2.g;
	toUse.b = col3.b;
	//float someshit = col4.r + col4.g + col4.b;

	gl_FragColor = toUse;
}')
	public function new()
	{
		super();
	}
}

class ChromaticAberrationEffect extends Effect
{
	public var shader:ChromaticAberrationShader;
  public function new(offset:Float = 0.00){
	shader = new ChromaticAberrationShader();
	shader.rOffset.value = [offset];
	shader.gOffset.value = [0.0];
	shader.bOffset.value = [-offset];
  }

	public function setChrome(chromeOffset:Float):Void
	{
		shader.rOffset.value = [chromeOffset];
		shader.gOffset.value = [0.0];
		shader.bOffset.value = [chromeOffset * -1];
	}

}


class ScanlineEffect extends Effect
{

	public var shader:Scanline;
	public function new (lockAlpha){
		shader = new Scanline();
		shader.lockAlpha.value = [lockAlpha];
	}


}


class Scanline extends FlxShader
{
	@:glFragmentSource('
#pragma header
const float scale = 1.0;
uniform bool lockAlpha;
void main()
{
	if (mod(floor(openfl_TextureCoordv.y * openfl_TextureSize.y / scale), 2.0) == 0.0 ){
		float bitch = 1.0;

		vec4 texColor = texture2D(bitmap, openfl_TextureCoordv);
		if (lockAlpha) bitch = texColor.a;
		gl_FragColor = vec4(0.0, 0.0, 0.0, bitch);
	}else{
		gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
	}
}')
	public function new()
	{
		super();

		this.lockAlpha.value = [false];
	}
}

class TiltshiftEffect extends Effect{

	public var shader:Tiltshift;
	public function new (blurAmount:Float, center:Float){
		shader = new Tiltshift();
		shader.bluramount.value = [blurAmount];
		shader.center.value = [center];
	}


}

class Tiltshift extends FlxShader
{
	@:glFragmentSource('
#pragma header

// Modified version of a tilt shift shader from Martin Jonasson (http://grapefrukt.com/)
// Read http://notes.underscorediscovery.com/ for context on shaders and this file
// License : MIT

/*
	Take note that blurring in a single pass (the two for loops below) is more expensive than separating
	the x and the y blur into different passes. This was used where bleeding edge performance
	was not crucial and is to illustrate a point.

	The reason two passes is cheaper?
		texture2D is a fairly high cost call, sampling a texture.

		So, in a single pass, like below, there are 3 steps, per x and y.

		That means a total of 9 "taps", it touches the texture to sample 9 times.

		Now imagine we apply this to some geometry, that is equal to 16 pixels on screen (tiny)
		(16 * 16) * 9 = 2304 samples taken, for width * height number of pixels, * 9 taps
		Now, if you split them up, it becomes 3 for x, and 3 for y, a total of 6 taps
		(16 * 16) * 6 = 1536 samples

		That\'s on a *tiny* sprite, let\'s scale that up to 128x128 sprite...
		(128 * 128) * 9 = 147,456
		(128 * 128) * 6 =  98,304

		That\'s 33.33..% cheaper for splitting them up.
		That\'s with 3 steps, with higher steps (more taps per pass...)

		A really smooth, 6 steps, 6*6 = 36 taps for one pass, 12 taps for two pass
		You will notice, the curve is not linear, at 12 steps it\'s 144 vs 24 taps
		It becomes orders of magnitude slower to do single pass!
		Therefore, you split them up into two passes, one for x, one for y.
*/

// I am hardcoding the constants like a jerk

uniform float bluramount;
uniform float center;
const float stepSize    = 0.004;
const float steps       = 3.0;

const float minOffs     = (float(steps-1.0)) / -2.0;
const float maxOffs     = (float(steps-1.0)) / +2.0;

void main() {
	float amount;
	vec4 blurred;

	// Work out how much to blur based on the mid point
	amount = pow((openfl_TextureCoordv.y * center) * 2.0 - 1.0, 2.0) * bluramount;

	// This is the accumulation of color from the surrounding pixels in the texture
	blurred = vec4(0.0, 0.0, 0.0, 1.0);

	// From minimum offset to maximum offset
	for (float offsX = minOffs; offsX <= maxOffs; ++offsX) {
		for (float offsY = minOffs; offsY <= maxOffs; ++offsY) {

			// copy the coord so we can mess with it
			vec2 temp_tcoord = openfl_TextureCoordv.xy;

			//work out which uv we want to sample now
			temp_tcoord.x += offsX * amount * stepSize;
			temp_tcoord.y += offsY * amount * stepSize;

			// accumulate the sample
			blurred += texture2D(bitmap, temp_tcoord);
		}
	}

	// because we are doing an average, we divide by the amount (x AND y, hence steps * steps)
	blurred /= float(steps * steps);

	// return the final blurred color
	gl_FragColor = blurred;
}')
	public function new()
	{
		super();

		this.bluramount.value = [1.0];
		this.center.value = [1.0];
	}
}
class GreyscaleEffect extends Effect{

	public var shader:GreyscaleShader = new GreyscaleShader();

	public function new(){

	}


}
class GreyscaleShader extends FlxShader{
	@:glFragmentSource('
	#pragma header
	void main() {
		vec4 color = texture2D(bitmap, openfl_TextureCoordv);
		float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
		gl_FragColor = vec4(vec3(gray), color.a);
	}


	')

	public function new(){
		super();
	}



}







class GrainEffect extends Effect {

	public var shader:Grain;
	public function new (grainsize, lumamount,lockAlpha){
		shader = new Grain();
		shader.lumamount.value = [lumamount];
		shader.grainsize.value = [grainsize];
		shader.lockAlpha.value = [lockAlpha];
		shader.uTime.value = [FlxG.random.float(0,8)];
		PlayState.instance.shaderUpdates.push(update);
	}
	public function update(elapsed){
		shader.uTime.value[0] += elapsed;
	}




}


class Grain extends FlxShader
{
	@:glFragmentSource(
	#pragma header

/*
Film Grain post-process shader v1.1
Martins Upitis (martinsh) devlog-martinsh.blogspot.com
2013

--------------------------
This work is licensed under a Creative Commons Attribution 3.0 Unported License.
So you are free to share, modify and adapt it for your needs, and even use it for commercial use.
I would also love to hear about a project you are using it.

Have fun,
Martins
--------------------------

Perlin noise shader by toneburst:
http://machinesdontcare.wordpress.com/2009/06/25/3d-perlin-noise-sphere-vertex-shader-sourcecode/
*/
uniform float uTime;

const float permTexUnit = 1.0/256.0;        // Perm texture texel-size
const float permTexUnitHalf = 0.5/256.0;    // Half perm texture texel-size

float width;
float height;

const float grainamount = 0.05; //grain amount
bool colored = false; //colored noise?
uniform float coloramount;
uniform float grainsize; //grain particle size (1.5 - 2.5)
uniform float lumamount; //
uniform bool lockAlpha;

//a random texture generator, but you can also use a pre-computed perturbation texture

vec4 rnm(in vec2 tc)
{
	float noise =  sin(dot(tc + vec2(uTime,uTime),vec2(12.9898,78.233))) * 43758.5453;

	float noiseR =  fract(noise)*2.0-1.0;
	float noiseG =  fract(noise*1.2154)*2.0-1.0;
	float noiseB =  fract(noise * 1.3453) * 2.0 - 1.0;


	float noiseA =  (fract(noise * 1.3647) * 2.0 - 1.0);

	return vec4(noiseR,noiseG,noiseB,noiseA);
}

float fade(in float t) {
	return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float pnoise3D(in vec3 p)
{
	vec3 pi = permTexUnit*floor(p)+permTexUnitHalf; // Integer part, scaled so +1 moves permTexUnit texel
	// and offset 1/2 texel to sample texel centers
	vec3 pf = fract(p);     // Fractional part for interpolation

	// Noise contributions from (x=0, y=0), z=0 and z=1
	float perm00 = rnm(pi.xy).a ;
	vec3  grad000 = rnm(vec2(perm00, pi.z)).rgb * 4.0 - 1.0;
	float n000 = dot(grad000, pf);
	vec3  grad001 = rnm(vec2(perm00, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n001 = dot(grad001, pf - vec3(0.0, 0.0, 1.0));

	// Noise contributions from (x=0, y=1), z=0 and z=1
	float perm01 = rnm(pi.xy + vec2(0.0, permTexUnit)).a ;
	vec3  grad010 = rnm(vec2(perm01, pi.z)).rgb * 4.0 - 1.0;
	float n010 = dot(grad010, pf - vec3(0.0, 1.0, 0.0));
	vec3  grad011 = rnm(vec2(perm01, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n011 = dot(grad011, pf - vec3(0.0, 1.0, 1.0));

	// Noise contributions from (x=1, y=0), z=0 and z=1
	float perm10 = rnm(pi.xy + vec2(permTexUnit, 0.0)).a ;
	vec3  grad100 = rnm(vec2(perm10, pi.z)).rgb * 4.0 - 1.0;
	float n100 = dot(grad100, pf - vec3(1.0, 0.0, 0.0));
	vec3  grad101 = rnm(vec2(perm10, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n101 = dot(grad101, pf - vec3(1.0, 0.0, 1.0));

	// Noise contributions from (x=1, y=1), z=0 and z=1
	float perm11 = rnm(pi.xy + vec2(permTexUnit, permTexUnit)).a ;
	vec3  grad110 = rnm(vec2(perm11, pi.z)).rgb * 4.0 - 1.0;
	float n110 = dot(grad110, pf - vec3(1.0, 1.0, 0.0));
	vec3  grad111 = rnm(vec2(perm11, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n111 = dot(grad111, pf - vec3(1.0, 1.0, 1.0));

	// Blend contributions along x
	vec4 n_x = mix(vec4(n000, n001, n010, n011), vec4(n100, n101, n110, n111), fade(pf.x));

	// Blend contributions along y
	vec2 n_xy = mix(n_x.xy, n_x.zw, fade(pf.y));

	// Blend contributions along z
	float n_xyz = mix(n_xy.x, n_xy.y, fade(pf.z));

	// We are done, return the final noise value.
	return n_xyz;
}

//2d coordinate orientation thing
vec2 coordRot(in vec2 tc, in float angle)
{
	float aspect = width/height;
	float rotX = ((tc.x*2.0-1.0)*aspect*cos(angle)) - ((tc.y*2.0-1.0)*sin(angle));
	float rotY = ((tc.y*2.0-1.0)*cos(angle)) + ((tc.x*2.0-1.0)*aspect*sin(angle));
	rotX = ((rotX/aspect)*0.5+0.5);
	rotY = rotY*0.5+0.5;
	return vec2(rotX,rotY);
}

void main()
{
	width = openfl_TextureSize.x;
	height = openfl_TextureSize.y;
	vec2 texCoord = openfl_TextureCoordv.st;

	vec3 rotOffset = vec3(1.425,3.892,5.835); //rotation offset values
	vec2 rotCoordsR = coordRot(texCoord, uTime + rotOffset.x);
	vec3 noise = vec3(pnoise3D(vec3(rotCoordsR*vec2(width/grainsize,height/grainsize),0.0)));

	if (colored)
	{
		vec2 rotCoordsG = coordRot(texCoord, uTime + rotOffset.y);
		vec2 rotCoordsB = coordRot(texCoord, uTime + rotOffset.z);
		noise.g = mix(noise.r,pnoise3D(vec3(rotCoordsG*vec2(width/grainsize,height/grainsize),1.0)),coloramount);
		noise.b = mix(noise.r,pnoise3D(vec3(rotCoordsB*vec2(width/grainsize,height/grainsize),2.0)),coloramount);
	}

	vec3 col = texture2D(bitmap, openfl_TextureCoordv).rgb;

	//noisiness response curve based on scene luminance
	vec3 lumcoeff = vec3(0.299,0.587,0.114);
	float luminance = mix(0.0,dot(col, lumcoeff),lumamount);
	float lum = smoothstep(0.2,0.0,luminance);
	lum += luminance;


	noise = mix(noise,vec3(0.0),pow(lum,4.0));
	col = col+noise*grainamount;

		float bitch = 1.0;
	vec4 texColor = texture2D(bitmap, openfl_TextureCoordv);
		if (lockAlpha) bitch = texColor.a;
	gl_FragColor =  vec4(col,bitch);
}
	')
	public function new()
	{
		super();

		this.coloramount.value = [0.6];
		this.grainsize.value = [1.6]; //grain particle size (1.5 - 2.5)
		this.lumamount.value = [1.0]; //
		this.lockAlpha.value = [false];
	}


}

class VCRDistortionEffect extends Effect
{
  public var shader:VCRDistortionShader = new VCRDistortionShader();
  public function new(glitchFactor:Float,distortion:Bool=true,perspectiveOn:Bool=true,vignetteMoving:Bool=true){
	shader.iTime.value = [0];
	shader.vignetteOn.value = [true];
	shader.perspectiveOn.value = [perspectiveOn];
	shader.distortionOn.value = [distortion];
	shader.scanlinesOn.value = [true];
	shader.vignetteMoving.value = [vignetteMoving];
	shader.glitchModifier.value = [glitchFactor];
	shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
   // var noise = Assets.getBitmapData(Paths.image("noise2"));
   // shader.noiseTex.input = noise;
   PlayState.instance.shaderUpdates.push(update);
  }

  public function update(elapsed:Float){
	shader.iTime.value[0] += elapsed;
	shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
  }

  public function setVignette(state:Bool){
	shader.vignetteOn.value[0] = state;
  }

  public function setPerspective(state:Bool){
	shader.perspectiveOn.value[0] = state;
  }

  public function setGlitchModifier(modifier:Float){
	shader.glitchModifier.value[0] = modifier;
  }

  public function setDistortion(state:Bool){
	shader.distortionOn.value[0] = state;
  }

  public function setScanlines(state:Bool){
	shader.scanlinesOn.value[0] = state;
  }

  public function setVignetteMoving(state:Bool){
	shader.vignetteMoving.value[0] = state;
  }
}

class VCRDistortionShader extends FlxShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{

  @:glFragmentSource('
  #pragma header

uniform float iTime;
uniform bool vignetteOn;
uniform bool perspectiveOn;
uniform bool distortionOn;
uniform bool scanlinesOn;
uniform bool vignetteMoving;
uniform float glitchModifier;
uniform vec3 iResolution;

float onOff(float a, float b, float c)
{
	return step(c, sin(iTime + a*cos(iTime*b)));
}

float ramp(float y, float start, float end)
{
	float inside = step(start,y) - step(end,y);
	float fact = (y-start)/(end-start)*inside;
	return (1.-fact) * inside;

}

vec4 getVideo(vec2 uv)
	{
	vec2 look = uv;
	if(distortionOn){
		float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
		look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(glitchModifier*2.0);
		float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
												(0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
		look.y = mod(look.y + vShift*glitchModifier, 1.);
	}
	vec4 video = flixel_texture2D(bitmap,look);

	return video;
	}

vec2 screenDistort(vec2 uv)
{
	if(perspectiveOn){
	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv *0.92 + 0.04;
	return uv;
	}
	return uv;
}
float random(vec2 uv)
{
	return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
}
float noise(vec2 uv)
{
	vec2 i = floor(uv);
	vec2 f = fract(uv);

	float a = random(i);
	float b = random(i + vec2(1.,0.));
	float c = random(i + vec2(0., 1.));
	float d = random(i + vec2(1.));

	vec2 u = smoothstep(0., 1., f);

	return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

}


vec2 scandistort(vec2 uv) {
	float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
	float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
	float amount = scan1 * scan2 * uv.x;

	//uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

	return uv;

}
void main()
{
	vec2 uv = openfl_TextureCoordv;
	vec2 curUV = screenDistort(uv);
	uv = scandistort(curUV);
	vec4 video = getVideo(uv);
	float vigAmt = 1.0;
	float x =  0.0;


	video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
	video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
	video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
	video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
	video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
	video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

	video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);
	if(vignetteMoving)
		vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

	if(vignetteOn)
		video *= vignette;


	gl_FragColor = mix(video,vec4(noise(uv * 75.)),.05);

	if(curUV.x<0.0 || curUV.x>1.0 || curUV.y<0.0 || curUV.y>1.0){
	gl_FragColor = vec4(0.0,0.0,0.0,0.0);
	}

}
')
public function new()
{
super();
}
}

//coding is like hitting on women, you never start with the number
//               -naether

//Boing! by ThaeHan

class BloomEffect extends Effect{

	public var shader:BloomShader = new BloomShader();
	public function new(blurSize:Float, intensity:Float){
		shader.blurSize.value = [blurSize];
		shader.intensity.value = [intensity];

	}


}


class BloomShader extends FlxShader{


	@:glFragmentSource('

#pragma header

uniform float intensity;
uniform float blurSize;
void main()
{
   vec4 sum = vec4(0);
   vec2 texcoord = openfl_TextureCoordv;
   int j;
   int i;

   //thank you! http://www.gamerendering.com/2008/10/11/gaussian-blur-filter-shader/ for the
   //blur tutorial
   // blur in y (vertical)
   // take nine samples, with the distance blurSize between them
   sum += flixel_texture2D(bitmap, vec2(texcoord.x - 4.0*blurSize, texcoord.y)) * 0.05;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x - 3.0*blurSize, texcoord.y)) * 0.09;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x - 2.0*blurSize, texcoord.y)) * 0.12;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x - blurSize, texcoord.y)) * 0.15;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y)) * 0.16;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x + blurSize, texcoord.y)) * 0.15;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x + 2.0*blurSize, texcoord.y)) * 0.12;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x + 3.0*blurSize, texcoord.y)) * 0.09;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x + 4.0*blurSize, texcoord.y)) * 0.05;

	// blur in y (vertical)
   // take nine samples, with the distance blurSize between them
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y - 4.0*blurSize)) * 0.05;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y - 3.0*blurSize)) * 0.09;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y - 2.0*blurSize)) * 0.12;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y - blurSize)) * 0.15;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y)) * 0.16;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y + blurSize)) * 0.15;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y + 2.0*blurSize)) * 0.12;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y + 3.0*blurSize)) * 0.09;
   sum += flixel_texture2D(bitmap, vec2(texcoord.x, texcoord.y + 4.0*blurSize)) * 0.05;

   //increase blur with intensity!
  gl_FragColor = sum*intensity + flixel_texture2D(bitmap, texcoord);
  // if(sin(iTime) > 0.0)
   //    fragColor = sum * sin(iTime)+ texture(iChannel0, texcoord);
  // else
	//   fragColor = sum * -sin(iTime)+ texture(iChannel0, texcoord);
}


	')

	public function new(){
		super();

		this.intensity.value = [0.35];
		this.blurSize.value = [1.0/512.0];
	}


}



/*STOLE FROM DAVE AND BAMBI

I LOVE BANUUU I LOVE BANUUU
   ________
  /        \
_/__________\_
 ||  o||  o||
 |//--  --//|
  \____O___/
   |      |
   |______|
   |   |  |
   |___|__|


*/






class GlitchEffect extends Effect
{
	public var shader:GlitchShader = new GlitchShader();

	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new(waveSpeed:Float,waveFrequency:Float,waveAmplitude:Float):Void
	{
		shader.uTime.value = [0];
		this.waveSpeed = waveSpeed;
		this.waveFrequency = waveFrequency;
		this.waveAmplitude = waveAmplitude;
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}


	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}

}

class DistortBGEffect extends Effect
{
	public var shader:DistortBGShader = new DistortBGShader();

	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new(waveSpeed:Float,waveFrequency:Float,waveAmplitude:Float):Void
	{
		this.waveSpeed = waveSpeed;
		this.waveFrequency = waveFrequency;
		this.waveAmplitude = waveAmplitude;
		shader.uTime.value = [0];
		//PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}


	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}

}


class PulseEffect extends Effect
{
	public var shader:PulseShader = new PulseShader();

	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
	public var Enabled(default, set):Bool = false;

	public function new(waveSpeed:Float,waveFrequency:Float,waveAmplitude:Float):Void
	{
		this.waveSpeed = waveSpeed;
		this.waveFrequency = waveFrequency;
		this.waveAmplitude = waveAmplitude;
		shader.uTime.value = [0];
		shader.uampmul.value = [0];
		shader.uEnabled.value = [false];
		PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}


	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_Enabled(v:Bool):Bool
	{
		Enabled = v;
		shader.uEnabled.value = [Enabled];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}

}


class InvertColorsEffect extends Effect
{
	public var shader:InvertShader = new InvertShader();
	public function new(lockAlpha){
	//	shader.lockAlpha.value = [lockAlpha];
	}

}

class GlitchShader extends FlxShader
{
	@:glFragmentSource('
#pragma header
//uniform float tx, ty; // x,y waves phase

//modified version of the wave shader to create weird garbled corruption like messes
uniform float uTime;

/**
	* How fast the waves move over time
	*/
uniform float uSpeed;

/**
	* Number of waves over time
	*/
uniform float uFrequency;

/**
	* How much the pixels are going to stretch over the waves
	*/
uniform float uWaveAmplitude;

vec2 sineWave(vec2 pt)
{
	float x = 0.0;
	float y = 0.0;

	float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
	float offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / pt.y * pt.x);
	pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
	pt.y += offsetY;

	return vec2(pt.x + x, pt.y + y);
}

void main()
{
	vec2 uv = sineWave(openfl_TextureCoordv);
	gl_FragColor = texture2D(bitmap, uv);
}')

	public function new()
	{
	   super();
	}
}

class InvertShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

vec4 sineWave(vec4 pt)
{

return vec4(1.0 - pt.x, 1.0 - pt.y, 1.0 - pt.z, pt.w);
}

void main()
{
	vec2 uv = openfl_TextureCoordv;
	gl_FragColor = sineWave(texture2D(bitmap, uv));
	gl_FragColor.a = 1.0 - gl_FragColor.a;
}')

	public function new()
	{
	   super();
	}
}



class DistortBGShader extends FlxShader
{
	@:glFragmentSource('
#pragma header
//uniform float tx, ty; // x,y waves phase

//gives the character a glitchy, distorted outline
uniform float uTime;

/**
	* How fast the waves move over time
	*/
uniform float uSpeed;

/**
	* Number of waves over time
	*/
uniform float uFrequency;

/**
	* How much the pixels are going to stretch over the waves
	*/
uniform float uWaveAmplitude;

vec2 sineWave(vec2 pt)
{
	float x = 0.0;
	float y = 0.0;

	float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
	float offsetY = sin(pt.y * uFrequency - uTime * uSpeed) * (uWaveAmplitude);
	pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
	pt.y += offsetY;

	return vec2(pt.x + x, pt.y + y);
}

vec4 makeBlack(vec4 pt)
{
	return vec4(0, 0, 0, pt.w);
}

void main()
{
	vec2 uv = sineWave(openfl_TextureCoordv);
	gl_FragColor = makeBlack(texture2D(bitmap, uv)) + texture2D(bitmap,openfl_TextureCoordv);
}')

	public function new()
	{
	   super();
	}
}


class PulseShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header
uniform float uampmul;

//modified version of the wave shader to create weird garbled corruption like messes
uniform float uTime;

/**
	* How fast the waves move over time
	*/
uniform float uSpeed;

/**
	* Number of waves over time
	*/
uniform float uFrequency;

uniform bool uEnabled;

/**
	* How much the pixels are going to stretch over the waves
	*/
uniform float uWaveAmplitude;

vec4 sineWave(vec4 pt, vec2 pos)
{
	if (uampmul > 0.0)
	{
		float offsetX = sin(pt.y * uFrequency + uTime * uSpeed);
		float offsetY = sin(pt.x * (uFrequency * 2.0) - (uTime / 2.0) * uSpeed);
		float offsetZ = sin(pt.z * (uFrequency / 2.0) + (uTime / 3.0) * uSpeed);
		pt.x = mix(pt.x,sin(pt.x / 2.0 * pt.y + (5.0 * offsetX) * pt.z),uWaveAmplitude * uampmul);
		pt.y = mix(pt.y,sin(pt.y / 3.0 * pt.z + (2.0 * offsetZ) - pt.x),uWaveAmplitude * uampmul);
		pt.z = mix(pt.z,sin(pt.z / 6.0 * (pt.x * offsetY) - (50.0 * offsetZ) * (pt.z * offsetX)),uWaveAmplitude * uampmul);
	}


	return vec4(pt.x, pt.y, pt.z, pt.w);
}

void main()
{
	vec2 uv = openfl_TextureCoordv;
	gl_FragColor = sineWave(texture2D(bitmap, uv),uv);
}
	')

	public function new()
	{
	   super();
	}
}




class Effect {
	public function setValue(shader:FlxShader, variable:String, value:Float){
		Reflect.setProperty(Reflect.getProperty(shader, 'variable'), 'value', [value]);
	}

}