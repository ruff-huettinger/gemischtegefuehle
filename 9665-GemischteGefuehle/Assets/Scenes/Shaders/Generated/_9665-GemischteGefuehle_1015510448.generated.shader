/*
                                            _
   _ __ __ _ _   _ _ __ ___   __ _ _ __ ___| |__ (_)_ __   __ _ 
  | '__/ _` | | | | '_ ` _ \ /  ` | '__/ __| '_ \| | '_ \ /  ` |
  | | | (_| | |_| | | | | | |     | | | (__| | | | | | | |     |
  |_|  \__,_|\__, |_| |_| |_|\__,_|_|  \___|_| |_|_|_| |_|\__, |
             |___/                                        |___/ 
   _              _ _    _ _   
  | |_ ___   ___ | | | _(_) |_ 
  | __/   \ /   \| | |/ / | __|
  | ||     |     | |   <| | |_   for Unity
   \__\___/ \___/|_|_|\_\_|\__|
                              

  This shader was automatically generated from
  Raymarching Toolkit\Assets\Shaders\RaymarchTemplate.shader
  
  for Raymarcher named 'Raymarcher' in scene '9665-GemischteGefuehle'.

*/


Shader "Hidden/_9665-GemischteGefuehle_1015510448.generated"
{

SubShader
{

Tags {
	"RenderType" = "Opaque"
	"Queue" = "Geometry-1"
	"DisableBatching" = "True"
	"IgnoreProjector" = "True"
}

Cull Off
ZWrite On

Pass
{

CGPROGRAM

#pragma shader_feature RENDER_OBJECT

#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc" // @noinlineinclude
#if RENDER_OBJECT
#include "UnityPBSLighting.cginc" // @noinlineinclude
#endif

// #define DEBUG_STEPS 1
// #define DEBUG_MATERIALS 1
// #define AO_ENABLED 1
// #define FOG_ENABLED 1
// #define FADE_TO_SKYBOX 1

#ifdef _RAYMARCHING_CGINC
#error "Already included Raymarching.cginc"
#else
#define _RAYMARCHING_CGINC 1

//
// Noise Shader Library for Unity - https://github.com/keijiro/NoiseShader
//
// Original work (webgl-noise) Copyright (C) 2011 Stefan Gustavson
// Translation and modification was made by Keijiro Takahashi.
//
// This shader is based on the webgl-noise GLSL shader. For further details
// of the original shader, please see the following description from the
// original source code.
//

//
// GLSL textureless classic 2D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/ashima/webgl-noise
//


float3 mod(float3 x, float3 y)
{
  return x - y * floor(x / y);
}
float4 mod(float4 x, float4 y)
{
  return x - y * floor(x / y);
}

float2 mod289(float2 x)
{
    return x - floor(x / 289.0) * 289.0;
}
float3 mod289(float3 x)
{
  return x - floor(x / 289.0) * 289.0;
}
float4 mod289(float4 x)
{
  return x - floor(x / 289.0) * 289.0;
}

float3 permute(float3 x)
{
    return mod289((x * 34.0 + 1.0) * x);
}
float4 permute(float4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

float3 taylorInvSqrt(float3 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}
float4 taylorInvSqrt(float4 r)
{
  return (float4)1.79284291400159 - r * 0.85373472095314;
}

float2 fade(float2 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}
float3 fade(float3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float cnoise(float2 P)
{
  float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
  float4 Pf = frac (P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
  Pi = mod289(Pi); // To avoid truncation effects in permutation
  float4 ix = Pi.xzxz;
  float4 iy = Pi.yyww;
  float4 fx = Pf.xzxz;
  float4 fy = Pf.yyww;

  float4 i = permute(permute(ix) + iy);

  float4 gx = frac(i / 41.0) * 2.0 - 1.0 ;
  float4 gy = abs(gx) - 0.5 ;
  float4 tx = floor(gx + 0.5);
  gx = gx - tx;

  float2 g00 = float2(gx.x,gy.x);
  float2 g10 = float2(gx.y,gy.y);
  float2 g01 = float2(gx.z,gy.z);
  float2 g11 = float2(gx.w,gy.w);

  float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;

  float n00 = dot(g00, float2(fx.x, fy.x));
  float n10 = dot(g10, float2(fx.y, fy.y));
  float n01 = dot(g01, float2(fx.z, fy.z));
  float n11 = dot(g11, float2(fx.w, fy.w));

  float2 fade_xy = fade(Pf.xy);
  float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
  float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

// Classic Perlin noise, periodic variant
float pnoise(float2 P, float2 rep)
{
  float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
  float4 Pf = frac (P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
  Pi = mod289(Pi);        // To avoid truncation effects in permutation
  float4 ix = Pi.xzxz;
  float4 iy = Pi.yyww;
  float4 fx = Pf.xzxz;
  float4 fy = Pf.yyww;

  float4 i = permute(permute(ix) + iy);

  float4 gx = frac(i / 41.0) * 2.0 - 1.0 ;
  float4 gy = abs(gx) - 0.5 ;
  float4 tx = floor(gx + 0.5);
  gx = gx - tx;

  float2 g00 = float2(gx.x,gy.x);
  float2 g10 = float2(gx.y,gy.y);
  float2 g01 = float2(gx.z,gy.z);
  float2 g11 = float2(gx.w,gy.w);

  float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;

  float n00 = dot(g00, float2(fx.x, fy.x));
  float n10 = dot(g10, float2(fx.y, fy.y));
  float n01 = dot(g01, float2(fx.z, fy.z));
  float n11 = dot(g11, float2(fx.w, fy.w));

  float2 fade_xy = fade(Pf.xy);
  float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
  float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}



// Classic Perlin noise
float cnoise(float3 P)
{
  float3 Pi0 = floor(P); // Integer part for indexing
  float3 Pi1 = Pi0 + (float3)1.0; // Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  float3 Pf0 = frac(P); // Fractional part for interpolation
  float3 Pf1 = Pf0 - (float3)1.0; // Fractional part - 1.0
  float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  float4 iy = float4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
  float4 iz0 = (float4)Pi0.z;
  float4 iz1 = (float4)Pi1.z;

  float4 ixy = permute(permute(ix) + iy);
  float4 ixy0 = permute(ixy + iz0);
  float4 ixy1 = permute(ixy + iz1);

  float4 gx0 = ixy0 / 7.0;
  float4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
  gx0 = frac(gx0);
  float4 gz0 = (float4)0.5 - abs(gx0) - abs(gy0);
  float4 sz0 = step(gz0, (float4)0.0);
  gx0 -= sz0 * (step((float4)0.0, gx0) - 0.5);
  gy0 -= sz0 * (step((float4)0.0, gy0) - 0.5);

  float4 gx1 = ixy1 / 7.0;
  float4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
  gx1 = frac(gx1);
  float4 gz1 = (float4)0.5 - abs(gx1) - abs(gy1);
  float4 sz1 = step(gz1, (float4)0.0);
  gx1 -= sz1 * (step((float4)0.0, gx1) - 0.5);
  gy1 -= sz1 * (step((float4)0.0, gy1) - 0.5);

  float3 g000 = float3(gx0.x,gy0.x,gz0.x);
  float3 g100 = float3(gx0.y,gy0.y,gz0.y);
  float3 g010 = float3(gx0.z,gy0.z,gz0.z);
  float3 g110 = float3(gx0.w,gy0.w,gz0.w);
  float3 g001 = float3(gx1.x,gy1.x,gz1.x);
  float3 g101 = float3(gx1.y,gy1.y,gz1.y);
  float3 g011 = float3(gx1.z,gy1.z,gz1.z);
  float3 g111 = float3(gx1.w,gy1.w,gz1.w);

  float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;

  float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, float3(Pf1.x, Pf0.y, Pf0.z));
  float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, float3(Pf1.x, Pf1.y, Pf0.z));
  float n001 = dot(g001, float3(Pf0.x, Pf0.y, Pf1.z));
  float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, float3(Pf0.x, Pf1.y, Pf1.z));
  float n111 = dot(g111, Pf1);

  float3 fade_xyz = fade(Pf0);
  float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
  float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
  return 2.2 * n_xyz;
}

// Classic Perlin noise, periodic variant
float pnoise(float3 P, float3 rep)
{
  float3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
  float3 Pi1 = mod(Pi0 + (float3)1.0, rep); // Integer part + 1, mod period
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  float3 Pf0 = frac(P); // Fractional part for interpolation
  float3 Pf1 = Pf0 - (float3)1.0; // Fractional part - 1.0
  float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  float4 iy = float4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
  float4 iz0 = (float4)Pi0.z;
  float4 iz1 = (float4)Pi1.z;

  float4 ixy = permute(permute(ix) + iy);
  float4 ixy0 = permute(ixy + iz0);
  float4 ixy1 = permute(ixy + iz1);

  float4 gx0 = ixy0 / 7.0;
  float4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
  gx0 = frac(gx0);
  float4 gz0 = (float4)0.5 - abs(gx0) - abs(gy0);
  float4 sz0 = step(gz0, (float4)0.0);
  gx0 -= sz0 * (step((float4)0.0, gx0) - 0.5);
  gy0 -= sz0 * (step((float4)0.0, gy0) - 0.5);

  float4 gx1 = ixy1 / 7.0;
  float4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
  gx1 = frac(gx1);
  float4 gz1 = (float4)0.5 - abs(gx1) - abs(gy1);
  float4 sz1 = step(gz1, (float4)0.0);
  gx1 -= sz1 * (step((float4)0.0, gx1) - 0.5);
  gy1 -= sz1 * (step((float4)0.0, gy1) - 0.5);

  float3 g000 = float3(gx0.x,gy0.x,gz0.x);
  float3 g100 = float3(gx0.y,gy0.y,gz0.y);
  float3 g010 = float3(gx0.z,gy0.z,gz0.z);
  float3 g110 = float3(gx0.w,gy0.w,gz0.w);
  float3 g001 = float3(gx1.x,gy1.x,gz1.x);
  float3 g101 = float3(gx1.y,gy1.y,gz1.y);
  float3 g011 = float3(gx1.z,gy1.z,gz1.z);
  float3 g111 = float3(gx1.w,gy1.w,gz1.w);

  float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, float3(Pf1.x, Pf0.y, Pf0.z));
  float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, float3(Pf1.x, Pf1.y, Pf0.z));
  float n001 = dot(g001, float3(Pf0.x, Pf0.y, Pf1.z));
  float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, float3(Pf0.x, Pf1.y, Pf1.z));
  float n111 = dot(g111, Pf1);

  float3 fade_xyz = fade(Pf0);
  float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
  float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
  return 2.2 * n_xyz;
}

float snoise(float2 v)
{
    const float4 C = float4( 0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                             0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                            -0.577350269189626,  // -1.0 + 2.0 * C.x
                             0.024390243902439); // 1.0 / 41.0
    // First corner
    float2 i  = floor(v + dot(v, C.yy));
    float2 x0 = v -   i + dot(i, C.xx);

    // Other corners
    float2 i1;
    i1.x = step(x0.y, x0.x);
    i1.y = 1.0 - i1.x;

    // x1 = x0 - i1  + 1.0 * C.xx;
    // x2 = x0 - 1.0 + 2.0 * C.xx;
    float2 x1 = x0 + C.xx - i1;
    float2 x2 = x0 + C.zz;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float3 p =
      permute(permute(i.y + float3(0.0, i1.y, 1.0))
                    + i.x + float3(0.0, i1.x, 1.0));

    float3 m = max(0.5 - float3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.0);
    m = m * m;
    m = m * m;

    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    m *= taylorInvSqrt(a0 * a0 + h * h);

    // Compute final noise value at P
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.y = a0.y * x1.x + h.y * x1.y;
    g.z = a0.z * x2.x + h.z * x2.y;
    return 130.0 * dot(m, g);
}


float snoise(float3 v)
{
    const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);

    // First corner
    float3 i  = floor(v + dot(v, C.yyy));
    float3 x0 = v   - i + dot(i, C.xxx);

    // Other corners
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);

    // x1 = x0 - i1  + 1.0 * C.xxx;
    // x2 = x0 - i2  + 2.0 * C.xxx;
    // x3 = x0 - 1.0 + 3.0 * C.xxx;
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy;
    float3 x3 = x0 - 0.5;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float4 p =
      permute(permute(permute(i.z + float4(0.0, i1.z, i2.z, 1.0))
                            + i.y + float4(0.0, i1.y, i2.y, 1.0))
                            + i.x + float4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)

    float4 x_ = floor(j / 7.0);
    float4 y_ = floor(j - 7.0 * x_);  // mod(j,N)

    float4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    float4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;

    float4 h = 1.0 - abs(x) - abs(y);

    float4 b0 = float4(x.xy, y.xy);
    float4 b1 = float4(x.zw, y.zw);

    //float4 s0 = float4(lessThan(b0, 0.0)) * 2.0 - 1.0;
    //float4 s1 = float4(lessThan(b1, 0.0)) * 2.0 - 1.0;
    float4 s0 = floor(b0) * 2.0 + 1.0;
    float4 s1 = floor(b1) * 2.0 + 1.0;
    float4 sh = -step(h, 0.0);

    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    float3 g0 = float3(a0.xy, h.x);
    float3 g1 = float3(a0.zw, h.y);
    float3 g2 = float3(a1.xy, h.z);
    float3 g3 = float3(a1.zw, h.w);

    // Normalise gradients
    float4 norm = taylorInvSqrt(float4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;

    // Mix final noise value
    float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    m = m * m;

    float4 px = float4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3));
    return 42.0 * dot(m, px);
}



float2 snoise_grad(float2 v)
{
    const float4 C = float4( 0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                             0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                            -0.577350269189626,  // -1.0 + 2.0 * C.x
                             0.024390243902439); // 1.0 / 41.0
    // First corner
    float2 i  = floor(v + dot(v, C.yy));
    float2 x0 = v -   i + dot(i, C.xx);

    // Other corners
    float2 i1;
    i1.x = step(x0.y, x0.x);
    i1.y = 1.0 - i1.x;

    // x1 = x0 - i1  + 1.0 * C.xx;
    // x2 = x0 - 1.0 + 2.0 * C.xx;
    float2 x1 = x0 + C.xx - i1;
    float2 x2 = x0 + C.zz;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float3 p =
      permute(permute(i.y + float3(0.0, i1.y, 1.0))
                    + i.x + float3(0.0, i1.x, 1.0));

    float3 m = max(0.5 - float3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.0);
    float3 m2 = m * m;
    float3 m3 = m2 * m;
    float3 m4 = m2 * m2;

    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    // Normalise gradients
    float3 norm = taylorInvSqrt(a0 * a0 + h * h);
    float2 g0 = float2(a0.x, h.x) * norm.x;
    float2 g1 = float2(a0.y, h.y) * norm.y;
    float2 g2 = float2(a0.z, h.z) * norm.z;

    // Compute gradient of noise function at P
    float2 grad =
      -6.0 * m3.x * x0 * dot(x0, g0) + m4.x * g0 +
      -6.0 * m3.y * x1 * dot(x1, g1) + m4.y * g1 +
      -6.0 * m3.z * x2 * dot(x2, g2) + m4.z * g2;
    return 130.0 * grad;
}



float3 snoise_grad(float3 v)
{
    const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);

    // First corner
    float3 i  = floor(v + dot(v, C.yyy));
    float3 x0 = v   - i + dot(i, C.xxx);

    // Other corners
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);

    // x1 = x0 - i1  + 1.0 * C.xxx;
    // x2 = x0 - i2  + 2.0 * C.xxx;
    // x3 = x0 - 1.0 + 3.0 * C.xxx;
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy;
    float3 x3 = x0 - 0.5;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float4 p =
      permute(permute(permute(i.z + float4(0.0, i1.z, i2.z, 1.0))
                            + i.y + float4(0.0, i1.y, i2.y, 1.0))
                            + i.x + float4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)

    float4 x_ = floor(j / 7.0);
    float4 y_ = floor(j - 7.0 * x_);  // mod(j,N)

    float4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    float4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;

    float4 h = 1.0 - abs(x) - abs(y);

    float4 b0 = float4(x.xy, y.xy);
    float4 b1 = float4(x.zw, y.zw);

    //float4 s0 = float4(lessThan(b0, 0.0)) * 2.0 - 1.0;
    //float4 s1 = float4(lessThan(b1, 0.0)) * 2.0 - 1.0;
    float4 s0 = floor(b0) * 2.0 + 1.0;
    float4 s1 = floor(b1) * 2.0 + 1.0;
    float4 sh = -step(h, 0.0);

    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    float3 g0 = float3(a0.xy, h.x);
    float3 g1 = float3(a0.zw, h.y);
    float3 g2 = float3(a1.xy, h.z);
    float3 g3 = float3(a1.zw, h.w);

    // Normalise gradients
    float4 norm = taylorInvSqrt(float4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;

    // Compute gradient of noise function at P
    float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    float4 m2 = m * m;
    float4 m3 = m2 * m;
    float4 m4 = m2 * m2;
    float3 grad =
      -6.0 * m3.x * x0 * dot(x0, g0) + m4.x * g0 +
      -6.0 * m3.y * x1 * dot(x1, g1) + m4.y * g1 +
      -6.0 * m3.z * x2 * dot(x2, g2) + m4.z * g2 +
      -6.0 * m3.w * x3 * dot(x3, g3) + m4.w * g3;
    return 42.0 * grad;
}

#define PI 3.1415926535897932384626433832795
#define INFINITY 1e6
#define PHI (sqrt(5)*0.5 + 0.5)
#define deg2rad 0.0174533

#ifndef USE_OPTIMIZED_NORMAL
#define USE_OPTIMIZED_NORMAL 1
#endif


uniform float _DrawDistance = 1000;
uniform float _Steps = 64;
uniform float ConservativeStepFactor = 1;

float3 getLights(in float3 color, in float3 pos, in float3 normal);
float2 map(float3 p);

float compute_depth(float4 clippos) {
#if defined(UNITY_REVERSED_Z)
	return clippos.z / clippos.w;
#else
  return ((clippos.z / clippos.w) + 1.0) * 0.5;
#endif
}

float3 calcNormal(in float3 pos)
{
	#if USE_OPTIMIZED_NORMAL
    const float2 e = float2(1.0,-1.0)*0.5773*0.0005;
    return normalize(
            e.xyy*map( pos + e.xyy ).x + 
					  e.yyx*map( pos + e.yyx ).x + 
					  e.yxy*map( pos + e.yxy ).x + 
					  e.xxx*map( pos + e.xxx ).x );
	#else
	float3 eps = float3(0.0005, 0.0, 0.0);
	float3 nor = float3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
	#endif	
}


float  modc(float  a, float  b) { return a - b * floor(a/b); }
float2 modc(float2 a, float2 b) { return a - b * floor(a/b); }
float3 modc(float3 a, float3 b) { return a - b * floor(a/b); }
float4 modc(float4 a, float4 b) { return a - b * floor(a/b); }

float lengthn(float2 p, int n) { return pow(pow(p.x, n) + pow(p.y, n), 1. / n); }
float lengthn(float3 p, int n) { return pow(pow(p.x, n) + pow(p.y, n) + pow(p.z, n), 1. / n); }

// returns float3(radius, theta, phi) from float3(x, y, z)
float3 toSpherical(float3 p) {
  float radius = length(p);
  return float3(
    radius,
    acos(p.z / radius), 
    atan2(p.y, p.x));
}

// return float3(x, y, z) from float3(radius, theta, phi)
float3 fromSpherical(float3 sphericalCoords) {
  return float3(
    sphericalCoords.x * sin(sphericalCoords.y) * cos(sphericalCoords.z),
    sphericalCoords.x * sin(sphericalCoords.y) * sin(sphericalCoords.z),
    sphericalCoords.x * cos(sphericalCoords.y)
  );
}

float udRoundBox(float3 p, float3 b, float r)
{
	return length(max(abs(p) - b, 0.0)) - r;
}

float sdEllipsoid(in float3 p, in float3 r)
{
    return (length(p/r) - 1.0) * min(min(r.x, r.y), r.z);
}

float3 rotateX(float3 p, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return float3(p.x, c*p.y+s*p.z, -s*p.y+c*p.z);
}

float3 rotateY(float3 p, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return float3(c*p.x-s*p.z, p.y, s*p.x+c*p.z);
}

float3 rotateZ(float3 p, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return float3(c*p.x+s*p.y, -s*p.x+c*p.y, p.z);
}

float3 processColor(float2 hit, float3 raypos, float3 dir);


// OPERATIONS

float opSubtract(float d1, float d2) {
	return max(-d1, d2);
}

float2 opSubtract(float d1, float2 d2) {
  return float2(max(-d1.x, d2.x), d2.y);
}

float opIntersect(float d1, float d2) {
	return max(d1, d2);
}
// REPETITION, returns modified p to be used as primitive(newp)
float3 opRep(float3 p, float3 c)
{
	float3 q = modc(p, c) - c * 0.5;
	return q;
}

// UNION
float2 opU(float2 d1, float2 d2) {
	return (d1.x < d2.x) ? d1 : d2;
}
float opU(float d1, float d2) {
	return (d1 < d2) ? d1 : d2;
}

float smin(float a, float b, float k) {
	float h = clamp(0.5 + 0.5*(b - a) / k, 0, 1);
	return lerp(b, a, h) - k*h*(1 - h);
}

float2 smin(float2 a, float2 b, float k) {
	float h = clamp(0.5 + 0.5*(b.x - a.x) / k, 0, 1);
	return lerp(b, a, h) - k*h*(1 - h);
}

float4 tex3D_2D(in float3 pos, in float3 normal, sampler2D tex) {
	return 	tex2Dlod(tex, float4(pos.y, pos.z, 0, 0)) * abs(normal.x) +
			tex2Dlod(tex, float4(pos.x, pos.z, 0, 0)) * abs(normal.y) +
			tex2Dlod(tex, float4(pos.x, pos.y, 0, 0)) * abs(normal.z);
}

// PRIMITIVES

// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
float box(float3 p, float3 size) {
  float3 d = abs(p)-size;
  float b = min(max(d.x, max(d.y,d.z)), 0) + length(max(d, 0));
  return b;
}
float3 sphere(float3 p, float r) {
  return length(p) - r;
}

float getGradientValue(sampler2D tex, float value) {
  return tex2Dlod(tex, float4(clamp(value,0,1),0,0,0)).r;
}
float getCurveValue(sampler2D tex, float value) {
  return tex2Dlod(tex, float4(clamp(value,0,1),0,0,0)).r;
}

// easing
// accelerating from zero velocity
float easeInQuad (float t) { return t*t; }
// decelerating to zero velocity
float easeOutQuad (float t) { return t*(2-t); }
// acceleration until halfway, then deceleration
float easeInOutQuad (float t) { return t<.5 ? 2*t*t : -1+(4-2*t)*t; }
// accelerating from zero velocity 
float easeInCubic (float t) { return t*t*t; }
// decelerating to zero velocity 
float easeOutCubic (float t) { return (--t)*t*t+1; }
// acceleration until halfway, then deceleration 
float easeInOutCubic (float t) { return t<.5 ? 4*t*t*t : (t-1)*(2*t-2)*(2*t-2)+1; }
// accelerating from zero velocity 
float easeInQuart (float t) { return t*t*t*t; }
// decelerating to zero velocity 
float easeOutQuart (float t) { return 1-(--t)*t*t*t; }
// acceleration until halfway, then deceleration
float easeInOutQuart (float t) { return t<.5 ? 8*t*t*t*t : 1-8*(--t)*t*t*t; }
// accelerating from zero velocity
float easeInQuint (float t) { return t*t*t*t*t; }
// decelerating to zero velocity
float easeOutQuint (float t) { return 1+(--t)*t*t*t*t; }
// acceleration until halfway, then deceleration 
float easeInOutQuint (float t) { return t<.5 ? 16*t*t*t*t*t : 1+16*(--t)*t*t*t*t; }

// noise

// Pseudo-random number (from: lumina.sourceforge.net/Tutorials/Noise.html)
float rand(float2 co)
{
	return frac(cos(dot(co, float2(4.898, 7.23))) * 23421.631);
}

float get_camera_near_plane()
{
  return _ProjectionParams.y;
}

float omega = 1.2;

float2 simpleRaytrace(float3 ro, float3 rd, out float3 raypos, out int numSteps, inout bool found)
{
	const int maxstep = _Steps;
	float t = get_camera_near_plane();
	found = false;
	float2 d;

	[loop]
	for (numSteps = 0; numSteps < maxstep; ++numSteps)
	{
		// If we run past the depth buffer, or if we exceed the max draw distance,
		// stop and return nothing (transparent pixel).
		// this way raymarched objects and traditional meshes can coexist.
		if (t > _DrawDistance)
			break;

		raypos = ro + rd * t;   // World space position of sample
		d = map(raypos);		// Sample of distance field (see map())

		// If the sample <= 0, we have hit something (see map()).
		[branch]
		if (d.x < 0.001) {
			found = true;
			break;
		}

		t += d * ConservativeStepFactor;
	}
	
    return d;
}


#define RELAXATION 0

float2 trace(float3 o, float3 d, out float3 raypos, out int numSteps, inout bool found) {
  float t_min = get_camera_near_plane();
  float t_max = _DrawDistance - get_camera_near_plane();
  float t = t_min;
  float candidate_error = INFINITY;
  float candidate_t = t_min;
  float candidate_mat = 0;
  float previousRadius = 0;
  float stepLength = 0;
  float functionSign = map(o).x < 0 ? -1 : +1;
  float pixelRadius = .001; // _ScreenParams.z - 1.0;
  raypos = o;
  [loop]
  for (int i = 0; i < _Steps; ++i) {
    raypos = d * t + o;
    float2 hit = map(raypos);
    float signedRadius = functionSign * hit.x;
    float radius = abs(signedRadius);

    #if RELAXATION
    bool sorFail = omega > 1 && (radius + previousRadius) < stepLength;
    if (sorFail) {
      stepLength -= omega * stepLength;
      omega = 1;
    } else
      stepLength = signedRadius * omega;
    #else
      stepLength = signedRadius;
    #endif

    previousRadius = radius;
    float error = radius / t;
    if (
    #if RELAXATION
      !sorFail &&
    #endif
      error < candidate_error) {
      candidate_t = t;
      candidate_error = error;
      candidate_mat = hit.y;
    }

    [branch]
    if (
    #if RELAXATION
      !sorFail && 
    #endif
      error < pixelRadius || t > t_max)
    {
      found = true;
      break;
    }

    t += stepLength * ConservativeStepFactor;
    numSteps++;
  }

  if ((t > t_max || candidate_error > pixelRadius))
    found = false;
  else
    found = true;
  return float2(candidate_t, candidate_mat);
}
/*
 * lambert diffuse lighting model
 */

struct LightInput {
   float3 color;
   float3 pos;
   float3 normal;
};

struct LightInfo {
  float4 posAndRange;
  float4 colorAndIntensity;
  float3 direction;
};

float3 getDirectionalLight(in LightInput ray, in LightInfo light)
{
  float diffuse = max(0.0, dot(-ray.normal, light.direction)) * light.colorAndIntensity.a; // point w normal
  return diffuse * (light.colorAndIntensity.xyz * ray.color);
}

float3 getPointLight(in LightInput ray, in LightInfo light)
{
  float3 toLight = ray.pos - light.posAndRange.xyz;
  float range = clamp(length(toLight) / light.posAndRange.w, 0., 1.);
  float attenuation = 1.0 / (1.0 + 256.0 * range*range);     //http://forum.unity3d.com/threads/light-attentuation-equation.16006/
  float diffuse = max(0.0, dot(-ray.normal, normalize(toLight.xyz))) * light.colorAndIntensity.a * attenuation; // point w normal
  return diffuse * (light.colorAndIntensity.xyz * ray.color);
}

float3 getCelShadedPointLight(in LightInput ray, in LightInfo light)
{
  float3 toLight = ray.pos - light.posAndRange.xyz;
  float range = clamp(length(toLight) / light.posAndRange.w, 0., 1.);
  float attenuation = 1.0 / (1.0 + 256.0 * range*range);     //http://forum.unity3d.com/threads/light-attentuation-equation.16006/
  float diffuse = max(0.0, dot(-ray.normal, normalize(toLight.xyz))) * light.colorAndIntensity.a * attenuation; // point w normal
  diffuse = round(diffuse * 5) / 5;
  return diffuse * (light.colorAndIntensity.xyz * ray.color);
}

float3 getCelShadedDirectionalLight(in LightInput ray, in LightInfo light)
{
  float diffuse = max(0.0, dot(-ray.normal, light.direction)) * light.colorAndIntensity.a; // point w normal
  diffuse = round(diffuse * 5) / 5;
  return diffuse * (light.colorAndIntensity.xyz * ray.color);
}

float unlerpClamped(float ax, float a1, float a2) {
  return clamp(clamp(ax - a1, 0, 999999) / (a2 - a1), 0.0, 1.0);
}

// Repeat the "world" at p where "repeat" is the axes to repeat in.
// for example, to repeat every 1,1,1 cube in all directions, do repeatWorld(p, float3(1,1,1))
float3 repeatWorld(float3 p, float3 repeat) {
	return sign(p / repeat) * (p % repeat) - 0.5 * repeat;
}

float nrand(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float3 simplecolor(float4 settings) {
	return settings.xyz;
}

float3 stripePattern(float3 pos, float3 color1, float3 color2, float4 settings) {
	float a = (cos(
		(pos.y * settings.y) +
		(pos.z * settings.z) *
		(pos.x * settings.x))
		+ 1.) / 2.;
	a = modc(a + settings.w, 1.0f);
	return lerp(color1, color2, round(a));
}

float3 stripePattern2(float3 pos, float3 color1, float3 color2, float4 settings) {
  float a = (cos(
    (pos.y * settings.y) +
    (pos.z * settings.z) *
    (pos.x * settings.x))
    +1.) / 2.;
  a = modc(a + settings.w, 1.0f);
  return lerp(color1, color2, round(a));
}

float checkeredPattern(float3 p) {
  p *= 10.0;
      float u = 1.0 - floor(modc(p.x, 2.0));
  float v = 1.0 - floor(modc(p.y, 2.0));
  float w = 1.0 - floor(modc(p.z, 2.0));
  if ((u == 1.0 && v < 1.0) || (u < 1.0 && v == 1.0) || (v == 1.0 && w < 1.0) || (v < 1.0 && w == 1.0) || (u == 1.0 && w < 1.0) || (u < 1.0 && w == 1.0))
    return 0.5;
  else
    return 1.0;
}

float turbulence(float3 p, float size) {
  float value = 0.0, initialSize = size;
  while (size >= 1) {
    value += snoise(p/size) * size;
    size /= 2.0;
  }
  return (128.0 * value / initialSize);
}

float noise3d(float3 pos) {
  return clamp(turbulence(pos*200.0, 16.0)/32.0 * 2.0 + 0.5, 0., 1.);
}


//float3 MaterialFunc(float nf, float3 normal, float3 pos, float3 rayDir, out float objectID);
// float3 MaterialFunc(float nf, float3 normal, float3 pos, float3 rayDir, out float objectID) { objectID = 0; return float3(1, 0, 1); } // STUB

uniform float4 _AmbientColor;
uniform float AmbientOcclusion = 0;
uniform int AmbientOcclusionSteps = 8;

float3 TransformPoint(float4x4 mat, float3 pos) { return mul(mat, float4(pos.x, pos.y, pos.z, 1.0)).xyz; }
#define objPos TransformPoint

float ambientOcclusion(float3 p, float3 n) {
#define AO_DELTA 2
	float a = 0.0;
	float weight = AmbientOcclusion;
	for (int i = 1; i <= AmbientOcclusionSteps; i++) {
		float d = (float(i) / float(AmbientOcclusionSteps)) * AO_DELTA; 
		a += weight * (d - map(p + n * d));
		weight *= 0.5;
	}
	return saturate(1.0 - a);
}

float hardshadow(in float3 ro, in float3 rd, float maxt, int ShadowSteps)
{
    float mint = 0.05f;
    float t = mint;
    for (int i = 0; i < ShadowSteps; ++i)
    {
        if (t >= maxt) break;
        float h = map(ro + rd*t);
        if (h < 0.001)
            return 0.0;
        t += h;
    }
    return 1.0;
}

float softshadow(in float3 ro, in float3 rd, float maxt, float k, int ShadowSteps) {
	float mint = 0.05;
	float res = 1.0;
	float t = mint;
	for (int i = 0; i < ShadowSteps; ++i) {
		if (t >= maxt) break;
		float h = map(ro + rd*t);
		if (h < 0.002) return 0.0;
		res = min(res, k*h / t);
		t += h;
	}
	return res;
}

struct vertexFSTriangleInput
{
	float4 vertex : POSITION;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

#if RENDER_OBJECT
struct v2f
{
    float4 pos         : SV_POSITION;
    float4 screenPos   : TEXCOORD0;
    float4 worldPos    : TEXCOORD1;
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
#else
struct v2f
{
	float4 vertex : SV_POSITION;
	float4 interpolatedRay : TEXCOORD0; 
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};
#endif

uniform float4x4 _FrustumCornersWS;
#if UNITY_SINGLE_PASS_STEREO
uniform float4x4 _FrustumCornersWS2;
#endif

v2f vert(vertexFSTriangleInput input)
{
	v2f o;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

	#if RENDER_OBJECT
		o.pos = UnityObjectToClipPos(input.vertex);
		o.screenPos = o.pos;
		o.worldPos = mul(unity_ObjectToWorld, input.vertex);
	#else
		o.vertex = input.vertex;
		o.vertex.xy = (o.vertex.xy - float2(0.5, 0.5)) * float2(2, 2);

		int frustumIndex = input.vertex.x + 2 * (1 - input.vertex.y);
    #if UNITY_SINGLE_PASS_STEREO
      if (unity_StereoEyeIndex == 0)
        o.interpolatedRay = _FrustumCornersWS[frustumIndex];
      else
        o.interpolatedRay = _FrustumCornersWS2[frustumIndex];
    #else
      o.interpolatedRay = _FrustumCornersWS[frustumIndex];
    #endif

	#endif

	return o;
}

struct FragOut
{
	fixed4 col : COLOR0;
	float4 col1 : COLOR1;
	float depth : SV_Depth;
};

fixed4 raymarch(float3 ro, float3 rd, float s, inout float3 raypos, out float objectID);


#ifndef _CAMERA_H_
#define _CAMERA_H_

// thanks https://github.com/hecomi/uRaymarching

inline float3 GetCameraPosition()    { return _WorldSpaceCameraPos;      }
inline float3 GetCameraForward()     { return -UNITY_MATRIX_V[2].xyz;    }
inline float3 GetCameraUp()          { return UNITY_MATRIX_V[1].xyz;     }
inline float3 GetCameraRight()       { return UNITY_MATRIX_V[0].xyz;     }
inline float  GetCameraFocalLength() { return abs(UNITY_MATRIX_P[1][1]); }
inline float  GetCameraNearClip()    { return _ProjectionParams.y;       }
inline float  GetCameraFarClip()     { return _ProjectionParams.z;       }
inline float  GetCameraMaxDistance() { return GetCameraFarClip() - GetCameraNearClip(); }

inline float3 _GetCameraDirection(float2 sp)
{
    float3 camDir      = GetCameraForward();
    float3 camUp       = GetCameraUp();
    float3 camSide     = GetCameraRight();
    float  focalLen    = GetCameraFocalLength();

    return normalize((camSide * sp.x) + (camUp * sp.y) + (camDir * focalLen));
}

inline float3 GetCameraDirection(float4 screenPos)
{
#if UNITY_UV_STARTS_AT_TOP
    screenPos.y *= -1.0;
#endif
    screenPos.x *= _ScreenParams.x / _ScreenParams.y;
    screenPos.xy /= screenPos.w;

    return _GetCameraDirection(screenPos.xy);
}

#endif



#endif
//
// Any code you add here is accessible by Snippets.
//


// Grey scale.
float getGrey(float3 col){ return dot(col, float3(0.299, 0.587, 0.114)); }

// Tri-Planar blending function. Based on an old Nvidia writeup:
// GPU Gems 3 - Ryan Geiss: http://http.developer.nvidia.com/GPUGems3/gpugems3_ch01.html
float3 triplanarTex3D(in float3 p, in float3 normal, sampler2D tex) {
  normal = max(normal*normal, 0.001);
  normal /= (normal.x + normal.y + normal.z );  
	return (tex2Dlod(tex, float4(p.yz, 0, 0)) * normal.x + 
    tex2Dlod(tex, float4(p.zx, 0, 0)) * normal.y + 
    tex2Dlod(tex, float4(p.xy, 0, 0)) * normal.z).xyz;
}

// Texture bump mapping. Four tri-planar lookups, or 12 texture lookups in total.
// Source https://www.shadertoy.com/view/Xs33Df
float3 doBumpMap( in float3 p, in float3 nor, sampler2D tex, float bumpfactor){
  const float eps = 0.001;
  float3 grad = float3( getGrey(triplanarTex3D(float3(p.x-eps, p.y, p.z), nor, tex)),
    getGrey(triplanarTex3D(float3(p.x, p.y-eps, p.z), nor, tex)),
    getGrey(triplanarTex3D(float3(p.x, p.y, p.z-eps), nor, tex)));
  
  grad = (grad - getGrey(triplanarTex3D(p , nor, tex)))/eps; 
          
  grad -= nor*dot(nor, grad);          
                    
  return normalize( nor + grad*bumpfactor );
}

float desertWaves(float3 p, float height)
{
  float disp = min(abs(atan(p.x)), abs(atan(p.z) ))* height;
  disp = 1.0;
  disp *= snoise(p.xz)/5.0;
  return p.y + disp;
}

float metaDesertWaves(float3 p, float height)
{
  float q = desertWaves(p, height);


    const float2 e = float2(1.0,-1.0)*0.5773*0.0005;
    float3 n = normalize( e.xyy*desertWaves( p + e.xyy, height ) + 
					  e.yyx*desertWaves( p+ e.yyx, height ) + 
					  e.yxy*desertWaves( p + e.yxy, height ) + 
					  e.xxx*desertWaves( p+ e.xxx, height ) );

  q = pow(q,1.5 + n.y);

return q;
}

float fersertWaves(float3 p, float height) {
  float disp = 1.0;
  float noise = snoise(p.xz)/5.0;
  
  return p.y + disp;
}

// Light Sun
uniform float4 Sun_1769698620PosAndRange;
uniform float4 Sun_1769698620ColorAndIntensity;
uniform float3 Sun_1769698620Direction;
uniform float Sun_1769698620Penumbra;
uniform int Sun_1769698620ShadowSteps;
// Light Sun (1)
uniform float4 Sun1_1487373619PosAndRange;
uniform float4 Sun1_1487373619ColorAndIntensity;
uniform float3 Sun1_1487373619Direction;
uniform float Sun1_1487373619Penumbra;
uniform int Sun1_1487373619ShadowSteps;

// UNIFORMS AND FUNCTIONS
uniform float3 x_1984766474_86f1660c_offset;
uniform float x_1984766474_86f1660c_angle;
uniform float3 x_1984766474_86f1660c_axis;
float3 modifier_Twist(float3 p , float3 _INP_offset, float _INP_angle, float3 _INP_axis) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Modifiers/Twist.asset
    p -= _INP_offset.xyz;
    float a = _INP_angle * PI / 180.;
    
    float twistP;
    float2 twistOther;
    if (_INP_axis.x > 0)
    {  twistP = p.x; twistOther = p.yz; }
    else if (_INP_axis.y > 0)
    {  twistP = p.y; twistOther = p.xz; }
    else
    {  twistP = p.z; twistOther = p.xy; }
    
    
    float c = cos(a*twistP);
    float s = sin(a*twistP);
    float2x2  m = float2x2(c,-s,s,c);
    float2 mm = mul(m,twistOther);
    float3 mp = 
      _INP_axis.x * float3(twistP,mm.x,mm.y) +
      _INP_axis.y * float3(mm.x,twistP,mm.y) +
      _INP_axis.z * float3(mm.x,mm.y,twistP);
    
    mp += _INP_offset.xyz;
    return mp;
}
uniform float4x4 _1984766474Matrix;
uniform float4x4 _1984766474InverseMatrix;
uniform float x_3429890895_1d59cc68_freq;
uniform float x_3429890895_1d59cc68_intensity;
uniform float x_3429890895_1d59cc68_speed;
uniform float x_1884009921_1d59cc68_freq;
uniform float x_1884009921_1d59cc68_intensity;
uniform float x_1884009921_1d59cc68_speed;
uniform float x_465736699_1d59cc68_freq;
uniform float x_465736699_1d59cc68_intensity;
uniform float x_465736699_1d59cc68_speed;
uniform float x_465736701_1d59cc68_freq;
uniform float x_465736701_1d59cc68_intensity;
uniform float x_465736701_1d59cc68_speed;
uniform float x_2374754544_1d59cc68_freq;
uniform float x_2374754544_1d59cc68_intensity;
uniform float x_2374754544_1d59cc68_speed;
uniform float x_2125928976_1d59cc68_freq;
uniform float x_2125928976_1d59cc68_intensity;
uniform float x_2125928976_1d59cc68_speed;
uniform float x_264223599_1d59cc68_freq;
uniform float x_264223599_1d59cc68_intensity;
uniform float x_264223599_1d59cc68_speed;
uniform float x_680804556_1d59cc68_freq;
uniform float x_680804556_1d59cc68_intensity;
uniform float x_680804556_1d59cc68_speed;
uniform float x_1769698612_1d59cc68_freq;
uniform float x_1769698612_1d59cc68_intensity;
uniform float x_1769698612_1d59cc68_speed;
float3 modifier_Displacement(float3 p , float _INP_freq, float _INP_intensity, float _INP_speed) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Modifiers/Displacement.asset
    float timeOffset = _Time.z * _INP_speed;
    return p + sin(_INP_freq*p.x + timeOffset)*sin(_INP_freq*p.y + 2.1f + timeOffset)*sin(_INP_freq*p.z + 4.2f + timeOffset)*_INP_intensity;
}
uniform float4x4 _3429890895Matrix;
uniform float4x4 _3429890895InverseMatrix;
uniform float4x4 _1884009921Matrix;
uniform float4x4 _1884009921InverseMatrix;
uniform float4x4 _465736699Matrix;
uniform float4x4 _465736699InverseMatrix;
uniform float4x4 _465736701Matrix;
uniform float4x4 _465736701InverseMatrix;
uniform float4x4 _2374754544Matrix;
uniform float4x4 _2374754544InverseMatrix;
uniform float4x4 _2125928976Matrix;
uniform float4x4 _2125928976InverseMatrix;
uniform float4x4 _264223599Matrix;
uniform float4x4 _264223599InverseMatrix;
uniform float4x4 _680804556Matrix;
uniform float4x4 _680804556InverseMatrix;
uniform float4x4 _1769698612Matrix;
uniform float4x4 _1769698612InverseMatrix;
uniform float x_465736696_7f5e1bd4_separation;
uniform float x_465736696_7f5e1bd4_intensity;
uniform float x_3571053390_7f5e1bd4_separation;
uniform float x_3571053390_7f5e1bd4_intensity;
uniform float x_3712215888_7f5e1bd4_separation;
uniform float x_3712215888_7f5e1bd4_intensity;
uniform float x_2052023618_7f5e1bd4_separation;
uniform float x_2052023618_7f5e1bd4_intensity;
uniform float x_1070792623_7f5e1bd4_separation;
uniform float x_1070792623_7f5e1bd4_intensity;
uniform float x_1346211114_7f5e1bd4_separation;
uniform float x_1346211114_7f5e1bd4_intensity;
uniform float x_2650173029_7f5e1bd4_separation;
uniform float x_2650173029_7f5e1bd4_intensity;
uniform float x_3853378399_7f5e1bd4_separation;
uniform float x_3853378399_7f5e1bd4_intensity;
float3 modifier_Pixellate(float3 p , float _INP_separation, float _INP_intensity) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Modifiers/Pixellate.asset
    float3 w = p;
    w /= _INP_separation;
    w = round(w);
    w *= _INP_separation;
    
    return lerp(p,w,_INP_intensity);
}
uniform float4x4 _465736696Matrix;
uniform float4x4 _465736696InverseMatrix;
uniform float4x4 _3571053390Matrix;
uniform float4x4 _3571053390InverseMatrix;
uniform float4x4 _3712215888Matrix;
uniform float4x4 _3712215888InverseMatrix;
uniform float4x4 _2052023618Matrix;
uniform float4x4 _2052023618InverseMatrix;
uniform float4x4 _1070792623Matrix;
uniform float4x4 _1070792623InverseMatrix;
uniform float4x4 _1346211114Matrix;
uniform float4x4 _1346211114InverseMatrix;
uniform float4x4 _2650173029Matrix;
uniform float4x4 _2650173029InverseMatrix;
uniform float4x4 _3853378399Matrix;
uniform float4x4 _3853378399InverseMatrix;
uniform float x_821967066_f5bf6f8d_height;
uniform float x_821967066_f5bf6f8d_width;
uniform float x_821967066_f5bf6f8d_radius;
uniform float x_821967066_f5bf6f8d_morph;
uniform float x_3954134948_f5bf6f8d_height;
uniform float x_3954134948_f5bf6f8d_width;
uniform float x_3954134948_f5bf6f8d_radius;
uniform float x_3954134948_f5bf6f8d_morph;
uniform float x_1386617069_f5bf6f8d_height;
uniform float x_1386617069_f5bf6f8d_width;
uniform float x_1386617069_f5bf6f8d_radius;
uniform float x_1386617069_f5bf6f8d_morph;
uniform float x_2408253973_f5bf6f8d_height;
uniform float x_2408253973_f5bf6f8d_width;
uniform float x_2408253973_f5bf6f8d_radius;
uniform float x_2408253973_f5bf6f8d_morph;
uniform float x_3429890890_f5bf6f8d_height;
uniform float x_3429890890_f5bf6f8d_width;
uniform float x_3429890890_f5bf6f8d_radius;
uniform float x_3429890890_f5bf6f8d_morph;
uniform float x_1487373610_f5bf6f8d_height;
uniform float x_1487373610_f5bf6f8d_width;
uniform float x_1487373610_f5bf6f8d_radius;
uniform float x_1487373610_f5bf6f8d_morph;
uniform float x_2509010532_f5bf6f8d_height;
uniform float x_2509010532_f5bf6f8d_width;
uniform float x_2509010532_f5bf6f8d_radius;
uniform float x_2509010532_f5bf6f8d_morph;
uniform float x_2233592071_f5bf6f8d_height;
uniform float x_2233592071_f5bf6f8d_width;
uniform float x_2233592071_f5bf6f8d_radius;
uniform float x_2233592071_f5bf6f8d_morph;
uniform float x_3812972447_f5bf6f8d_height;
uniform float x_3812972447_f5bf6f8d_width;
uniform float x_3812972447_f5bf6f8d_radius;
uniform float x_3812972447_f5bf6f8d_morph;
uniform float x_1769698615_f5bf6f8d_height;
uniform float x_1769698615_f5bf6f8d_width;
uniform float x_1769698615_f5bf6f8d_radius;
uniform float x_1769698615_f5bf6f8d_morph;
uniform float x_264223575_f5bf6f8d_height;
uniform float x_264223575_f5bf6f8d_width;
uniform float x_264223575_f5bf6f8d_radius;
uniform float x_264223575_f5bf6f8d_morph;
uniform float x_438885504_f5bf6f8d_height;
uniform float x_438885504_f5bf6f8d_width;
uniform float x_438885504_f5bf6f8d_radius;
uniform float x_438885504_f5bf6f8d_morph;
uniform float x_3537553951_f5bf6f8d_height;
uniform float x_3537553951_f5bf6f8d_width;
uniform float x_3537553951_f5bf6f8d_radius;
uniform float x_3537553951_f5bf6f8d_morph;
uniform float x_2233592068_f5bf6f8d_height;
uniform float x_2233592068_f5bf6f8d_width;
uniform float x_2233592068_f5bf6f8d_radius;
uniform float x_2233592068_f5bf6f8d_morph;
uniform float x_3893784310_f5bf6f8d_height;
uniform float x_3893784310_f5bf6f8d_width;
uniform float x_3893784310_f5bf6f8d_radius;
uniform float x_3893784310_f5bf6f8d_morph;
uniform float x_3712215887_f5bf6f8d_height;
uniform float x_3712215887_f5bf6f8d_width;
uniform float x_3712215887_f5bf6f8d_radius;
uniform float x_3712215887_f5bf6f8d_morph;
float object_HexSphere(float3 p , float _INP_height, float _INP_width, float _INP_radius, float _INP_morph) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Objects/HexSphere.asset
    float3 q = abs(p);
    //return s;
    return lerp(max(q.z-_INP_height,max((q.x*0.866025+q.y*0.5),q.y)-_INP_width),
    length(p) - _INP_radius,
    _INP_morph);
    
    // The MIT License
    // Copyright © 2013 Inigo Quilez
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}
// uniforms for HexSphere
uniform float4x4 _821967066Matrix;
uniform float _821967066MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _3954134948Matrix;
uniform float _3954134948MinScale;
// uniforms for HexSphere
uniform float4x4 _1386617069Matrix;
uniform float _1386617069MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _2408253973Matrix;
uniform float _2408253973MinScale;
// uniforms for HexSphere
uniform float4x4 _3429890890Matrix;
uniform float _3429890890MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _1487373610Matrix;
uniform float _1487373610MinScale;
// uniforms for HexSphere
uniform float4x4 _2509010532Matrix;
uniform float _2509010532MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _2233592071Matrix;
uniform float _2233592071MinScale;
// uniforms for HexSphere
uniform float4x4 _3812972447Matrix;
uniform float _3812972447MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _1769698615Matrix;
uniform float _1769698615MinScale;
// uniforms for HexSphere
uniform float4x4 _264223575Matrix;
uniform float _264223575MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _438885504Matrix;
uniform float _438885504MinScale;
// uniforms for HexSphere
uniform float4x4 _3537553951Matrix;
uniform float _3537553951MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _2233592068Matrix;
uniform float _2233592068MinScale;
// uniforms for HexSphere
uniform float4x4 _3893784310Matrix;
uniform float _3893784310MinScale;
// uniforms for HexSphere (1)
uniform float4x4 _3712215887Matrix;
uniform float _3712215887MinScale;
uniform float x_438885515_44192f17_intensity;
float2 blend_Smooth(float2 a, float2 b , float _INP_intensity) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Blends/Smooth.asset
    float h = saturate(0.5 + 0.5*(b - a) / _INP_intensity);
    return lerp(b, a, h) - _INP_intensity*h*(1 - h);
}
uniform float4 x_821967066_9b1ccc08_color;
uniform float x_821967066_9b1ccc08_contrast;
uniform float4 x_3954134948_9b1ccc08_color;
uniform float x_3954134948_9b1ccc08_contrast;
uniform float4 x_1386617069_9b1ccc08_color;
uniform float x_1386617069_9b1ccc08_contrast;
uniform float4 x_2408253973_9b1ccc08_color;
uniform float x_2408253973_9b1ccc08_contrast;
uniform float4 x_3429890890_9b1ccc08_color;
uniform float x_3429890890_9b1ccc08_contrast;
uniform float4 x_1487373610_9b1ccc08_color;
uniform float x_1487373610_9b1ccc08_contrast;
uniform float4 x_2509010532_9b1ccc08_color;
uniform float x_2509010532_9b1ccc08_contrast;
uniform float4 x_2233592071_9b1ccc08_color;
uniform float x_2233592071_9b1ccc08_contrast;
uniform float4 x_3812972447_9b1ccc08_color;
uniform float x_3812972447_9b1ccc08_contrast;
uniform float4 x_1769698615_9b1ccc08_color;
uniform float x_1769698615_9b1ccc08_contrast;
uniform float4 x_264223575_9b1ccc08_color;
uniform float x_264223575_9b1ccc08_contrast;
uniform float4 x_438885504_9b1ccc08_color;
uniform float x_438885504_9b1ccc08_contrast;
uniform float4 x_3537553951_9b1ccc08_color;
uniform float x_3537553951_9b1ccc08_contrast;
uniform float4 x_2233592068_9b1ccc08_color;
uniform float x_2233592068_9b1ccc08_contrast;
uniform float4 x_3893784310_9b1ccc08_color;
uniform float x_3893784310_9b1ccc08_contrast;
uniform float4 x_3712215887_9b1ccc08_color;
uniform float x_3712215887_9b1ccc08_contrast;
float3 material_GemGefObjectsbk(inout float3 normal, float3 p, float3 rayDir, float4 _INP_color, float _INP_contrast) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Materials/GemGefObjects bk.asset
    return _INP_color;
}
float3 MaterialFunc(float nf, inout float3 normal, float3 p, float3 rayDir, out float objectID)
{
    objectID = ceil(nf) / (float)16;
    [branch] if (nf <= 1) {
    //    objectID = 0.0625;
        return material_GemGefObjectsbk(normal, objPos(_821967066Matrix, p), rayDir, x_821967066_9b1ccc08_color, x_821967066_9b1ccc08_contrast);
    }
    else if(nf <= 2) {
    //    objectID = 0.125;
        return material_GemGefObjectsbk(normal, objPos(_3954134948Matrix, p), rayDir, x_3954134948_9b1ccc08_color, x_3954134948_9b1ccc08_contrast);
    }
    else if(nf <= 3) {
    //    objectID = 0.1875;
        return material_GemGefObjectsbk(normal, objPos(_1386617069Matrix, p), rayDir, x_1386617069_9b1ccc08_color, x_1386617069_9b1ccc08_contrast);
    }
    else if(nf <= 4) {
    //    objectID = 0.25;
        return material_GemGefObjectsbk(normal, objPos(_2408253973Matrix, p), rayDir, x_2408253973_9b1ccc08_color, x_2408253973_9b1ccc08_contrast);
    }
    else if(nf <= 5) {
    //    objectID = 0.3125;
        return material_GemGefObjectsbk(normal, objPos(_3429890890Matrix, p), rayDir, x_3429890890_9b1ccc08_color, x_3429890890_9b1ccc08_contrast);
    }
    else if(nf <= 6) {
    //    objectID = 0.375;
        return material_GemGefObjectsbk(normal, objPos(_1487373610Matrix, p), rayDir, x_1487373610_9b1ccc08_color, x_1487373610_9b1ccc08_contrast);
    }
    else if(nf <= 7) {
    //    objectID = 0.4375;
        return material_GemGefObjectsbk(normal, objPos(_2509010532Matrix, p), rayDir, x_2509010532_9b1ccc08_color, x_2509010532_9b1ccc08_contrast);
    }
    else if(nf <= 8) {
    //    objectID = 0.5;
        return material_GemGefObjectsbk(normal, objPos(_2233592071Matrix, p), rayDir, x_2233592071_9b1ccc08_color, x_2233592071_9b1ccc08_contrast);
    }
    else if(nf <= 9) {
    //    objectID = 0.5625;
        return material_GemGefObjectsbk(normal, objPos(_3812972447Matrix, p), rayDir, x_3812972447_9b1ccc08_color, x_3812972447_9b1ccc08_contrast);
    }
    else if(nf <= 10) {
    //    objectID = 0.625;
        return material_GemGefObjectsbk(normal, objPos(_1769698615Matrix, p), rayDir, x_1769698615_9b1ccc08_color, x_1769698615_9b1ccc08_contrast);
    }
    else if(nf <= 11) {
    //    objectID = 0.6875;
        return material_GemGefObjectsbk(normal, objPos(_264223575Matrix, p), rayDir, x_264223575_9b1ccc08_color, x_264223575_9b1ccc08_contrast);
    }
    else if(nf <= 12) {
    //    objectID = 0.75;
        return material_GemGefObjectsbk(normal, objPos(_438885504Matrix, p), rayDir, x_438885504_9b1ccc08_color, x_438885504_9b1ccc08_contrast);
    }
    else if(nf <= 13) {
    //    objectID = 0.8125;
        return material_GemGefObjectsbk(normal, objPos(_3537553951Matrix, p), rayDir, x_3537553951_9b1ccc08_color, x_3537553951_9b1ccc08_contrast);
    }
    else if(nf <= 14) {
    //    objectID = 0.875;
        return material_GemGefObjectsbk(normal, objPos(_2233592068Matrix, p), rayDir, x_2233592068_9b1ccc08_color, x_2233592068_9b1ccc08_contrast);
    }
    else if(nf <= 15) {
    //    objectID = 0.9375;
        return material_GemGefObjectsbk(normal, objPos(_3893784310Matrix, p), rayDir, x_3893784310_9b1ccc08_color, x_3893784310_9b1ccc08_contrast);
    }
    else if(nf <= 16) {
    //    objectID = 1;
        return material_GemGefObjectsbk(normal, objPos(_3712215887Matrix, p), rayDir, x_3712215887_9b1ccc08_color, x_3712215887_9b1ccc08_contrast);
    }
        objectID = 0;
        return float3(1.0, 0.0, 1.0);
    }

#define raymarch defaultRaymarch

float2 map(float3 p) {
	float2 result = float2(1.0, 0.0);
	
{
    float3 p_1984766474 = objPos(_1984766474InverseMatrix, modifier_Twist(objPos(_1984766474Matrix, p), x_1984766474_86f1660c_offset, x_1984766474_86f1660c_angle, x_1984766474_86f1660c_axis));
    float3 p_3429890895 = objPos(_3429890895InverseMatrix, modifier_Displacement(objPos(_3429890895Matrix, p_1984766474), x_3429890895_1d59cc68_freq, x_3429890895_1d59cc68_intensity, x_3429890895_1d59cc68_speed));
    float3 p_465736696 = objPos(_465736696InverseMatrix, modifier_Pixellate(objPos(_465736696Matrix, p_3429890895), x_465736696_7f5e1bd4_separation, x_465736696_7f5e1bd4_intensity));
    float3 p_1884009921 = objPos(_1884009921InverseMatrix, modifier_Displacement(objPos(_1884009921Matrix, p_465736696), x_1884009921_1d59cc68_freq, x_1884009921_1d59cc68_intensity, x_1884009921_1d59cc68_speed));
    float _821967066Distance = object_HexSphere(objPos(_821967066Matrix, p_1884009921), x_821967066_f5bf6f8d_height, x_821967066_f5bf6f8d_width, x_821967066_f5bf6f8d_radius, x_821967066_f5bf6f8d_morph) * _821967066MinScale;
    float _3954134948Distance = object_HexSphere(objPos(_3954134948Matrix, p_1884009921), x_3954134948_f5bf6f8d_height, x_3954134948_f5bf6f8d_width, x_3954134948_f5bf6f8d_radius, x_3954134948_f5bf6f8d_morph) * _3954134948MinScale;
    float3 p_3571053390 = objPos(_3571053390InverseMatrix, modifier_Pixellate(objPos(_3571053390Matrix, p_3429890895), x_3571053390_7f5e1bd4_separation, x_3571053390_7f5e1bd4_intensity));
    float3 p_465736699 = objPos(_465736699InverseMatrix, modifier_Displacement(objPos(_465736699Matrix, p_3571053390), x_465736699_1d59cc68_freq, x_465736699_1d59cc68_intensity, x_465736699_1d59cc68_speed));
    float _1386617069Distance = object_HexSphere(objPos(_1386617069Matrix, p_465736699), x_1386617069_f5bf6f8d_height, x_1386617069_f5bf6f8d_width, x_1386617069_f5bf6f8d_radius, x_1386617069_f5bf6f8d_morph) * _1386617069MinScale;
    float _2408253973Distance = object_HexSphere(objPos(_2408253973Matrix, p_465736699), x_2408253973_f5bf6f8d_height, x_2408253973_f5bf6f8d_width, x_2408253973_f5bf6f8d_radius, x_2408253973_f5bf6f8d_morph) * _2408253973MinScale;
    float3 p_3712215888 = objPos(_3712215888InverseMatrix, modifier_Pixellate(objPos(_3712215888Matrix, p_3429890895), x_3712215888_7f5e1bd4_separation, x_3712215888_7f5e1bd4_intensity));
    float3 p_465736701 = objPos(_465736701InverseMatrix, modifier_Displacement(objPos(_465736701Matrix, p_3712215888), x_465736701_1d59cc68_freq, x_465736701_1d59cc68_intensity, x_465736701_1d59cc68_speed));
    float _3429890890Distance = object_HexSphere(objPos(_3429890890Matrix, p_465736701), x_3429890890_f5bf6f8d_height, x_3429890890_f5bf6f8d_width, x_3429890890_f5bf6f8d_radius, x_3429890890_f5bf6f8d_morph) * _3429890890MinScale;
    float _1487373610Distance = object_HexSphere(objPos(_1487373610Matrix, p_465736701), x_1487373610_f5bf6f8d_height, x_1487373610_f5bf6f8d_width, x_1487373610_f5bf6f8d_radius, x_1487373610_f5bf6f8d_morph) * _1487373610MinScale;
    float3 p_2052023618 = objPos(_2052023618InverseMatrix, modifier_Pixellate(objPos(_2052023618Matrix, p_3429890895), x_2052023618_7f5e1bd4_separation, x_2052023618_7f5e1bd4_intensity));
    float3 p_2374754544 = objPos(_2374754544InverseMatrix, modifier_Displacement(objPos(_2374754544Matrix, p_2052023618), x_2374754544_1d59cc68_freq, x_2374754544_1d59cc68_intensity, x_2374754544_1d59cc68_speed));
    float _2509010532Distance = object_HexSphere(objPos(_2509010532Matrix, p_2374754544), x_2509010532_f5bf6f8d_height, x_2509010532_f5bf6f8d_width, x_2509010532_f5bf6f8d_radius, x_2509010532_f5bf6f8d_morph) * _2509010532MinScale;
    float _2233592071Distance = object_HexSphere(objPos(_2233592071Matrix, p_2374754544), x_2233592071_f5bf6f8d_height, x_2233592071_f5bf6f8d_width, x_2233592071_f5bf6f8d_radius, x_2233592071_f5bf6f8d_morph) * _2233592071MinScale;
    float3 p_1070792623 = objPos(_1070792623InverseMatrix, modifier_Pixellate(objPos(_1070792623Matrix, p_3429890895), x_1070792623_7f5e1bd4_separation, x_1070792623_7f5e1bd4_intensity));
    float3 p_2125928976 = objPos(_2125928976InverseMatrix, modifier_Displacement(objPos(_2125928976Matrix, p_1070792623), x_2125928976_1d59cc68_freq, x_2125928976_1d59cc68_intensity, x_2125928976_1d59cc68_speed));
    float _3812972447Distance = object_HexSphere(objPos(_3812972447Matrix, p_2125928976), x_3812972447_f5bf6f8d_height, x_3812972447_f5bf6f8d_width, x_3812972447_f5bf6f8d_radius, x_3812972447_f5bf6f8d_morph) * _3812972447MinScale;
    float _1769698615Distance = object_HexSphere(objPos(_1769698615Matrix, p_2125928976), x_1769698615_f5bf6f8d_height, x_1769698615_f5bf6f8d_width, x_1769698615_f5bf6f8d_radius, x_1769698615_f5bf6f8d_morph) * _1769698615MinScale;
    float3 p_1346211114 = objPos(_1346211114InverseMatrix, modifier_Pixellate(objPos(_1346211114Matrix, p_3429890895), x_1346211114_7f5e1bd4_separation, x_1346211114_7f5e1bd4_intensity));
    float3 p_264223599 = objPos(_264223599InverseMatrix, modifier_Displacement(objPos(_264223599Matrix, p_1346211114), x_264223599_1d59cc68_freq, x_264223599_1d59cc68_intensity, x_264223599_1d59cc68_speed));
    float _264223575Distance = object_HexSphere(objPos(_264223575Matrix, p_264223599), x_264223575_f5bf6f8d_height, x_264223575_f5bf6f8d_width, x_264223575_f5bf6f8d_radius, x_264223575_f5bf6f8d_morph) * _264223575MinScale;
    float _438885504Distance = object_HexSphere(objPos(_438885504Matrix, p_264223599), x_438885504_f5bf6f8d_height, x_438885504_f5bf6f8d_width, x_438885504_f5bf6f8d_radius, x_438885504_f5bf6f8d_morph) * _438885504MinScale;
    float3 p_2650173029 = objPos(_2650173029InverseMatrix, modifier_Pixellate(objPos(_2650173029Matrix, p_3429890895), x_2650173029_7f5e1bd4_separation, x_2650173029_7f5e1bd4_intensity));
    float3 p_680804556 = objPos(_680804556InverseMatrix, modifier_Displacement(objPos(_680804556Matrix, p_2650173029), x_680804556_1d59cc68_freq, x_680804556_1d59cc68_intensity, x_680804556_1d59cc68_speed));
    float _3537553951Distance = object_HexSphere(objPos(_3537553951Matrix, p_680804556), x_3537553951_f5bf6f8d_height, x_3537553951_f5bf6f8d_width, x_3537553951_f5bf6f8d_radius, x_3537553951_f5bf6f8d_morph) * _3537553951MinScale;
    float _2233592068Distance = object_HexSphere(objPos(_2233592068Matrix, p_680804556), x_2233592068_f5bf6f8d_height, x_2233592068_f5bf6f8d_width, x_2233592068_f5bf6f8d_radius, x_2233592068_f5bf6f8d_morph) * _2233592068MinScale;
    float3 p_3853378399 = objPos(_3853378399InverseMatrix, modifier_Pixellate(objPos(_3853378399Matrix, p_3429890895), x_3853378399_7f5e1bd4_separation, x_3853378399_7f5e1bd4_intensity));
    float3 p_1769698612 = objPos(_1769698612InverseMatrix, modifier_Displacement(objPos(_1769698612Matrix, p_3853378399), x_1769698612_1d59cc68_freq, x_1769698612_1d59cc68_intensity, x_1769698612_1d59cc68_speed));
    float _3893784310Distance = object_HexSphere(objPos(_3893784310Matrix, p_1769698612), x_3893784310_f5bf6f8d_height, x_3893784310_f5bf6f8d_width, x_3893784310_f5bf6f8d_radius, x_3893784310_f5bf6f8d_morph) * _3893784310MinScale;
    float _3712215887Distance = object_HexSphere(objPos(_3712215887Matrix, p_1769698612), x_3712215887_f5bf6f8d_height, x_3712215887_f5bf6f8d_width, x_3712215887_f5bf6f8d_radius, x_3712215887_f5bf6f8d_morph) * _3712215887MinScale;
    result = blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(opU(float2(_821967066Distance, /*material ID*/0.5), float2(_3954134948Distance, /*material ID*/1.5)), opU(float2(_1386617069Distance, /*material ID*/2.5), float2(_2408253973Distance, /*material ID*/3.5)), x_438885515_44192f17_intensity), opU(float2(_3429890890Distance, /*material ID*/4.5), float2(_1487373610Distance, /*material ID*/5.5)), x_438885515_44192f17_intensity), opU(float2(_2509010532Distance, /*material ID*/6.5), float2(_2233592071Distance, /*material ID*/7.5)), x_438885515_44192f17_intensity), opU(float2(_3812972447Distance, /*material ID*/8.5), float2(_1769698615Distance, /*material ID*/9.5)), x_438885515_44192f17_intensity), opU(float2(_264223575Distance, /*material ID*/10.5), float2(_438885504Distance, /*material ID*/11.5)), x_438885515_44192f17_intensity), opU(float2(_3537553951Distance, /*material ID*/12.5), float2(_2233592068Distance, /*material ID*/13.5)), x_438885515_44192f17_intensity), opU(float2(_3893784310Distance, /*material ID*/14.5), float2(_3712215887Distance, /*material ID*/15.5)), x_438885515_44192f17_intensity);
    }
	return result;
}

float3 getLights(in float3 color, in float3 pos, in float3 normal) {
	LightInput input;
	input.pos = pos;
	input.color = color;
	input.normal = normal;

	float3 lightValue = float3(0, 0, 0);
	
{
LightInfo light;
light.posAndRange = Sun_1769698620PosAndRange;
light.colorAndIntensity = Sun_1769698620ColorAndIntensity;
light.direction = Sun_1769698620Direction;
lightValue += getDirectionalLight(input, light)* softshadow(input.pos, -light.direction, INFINITY, Sun_1769698620Penumbra, Sun_1769698620ShadowSteps);
}
{
LightInfo light;
light.posAndRange = Sun1_1487373619PosAndRange;
light.colorAndIntensity = Sun1_1487373619ColorAndIntensity;
light.direction = Sun1_1487373619Direction;
lightValue += getDirectionalLight(input, light)* softshadow(input.pos, -light.direction, INFINITY, Sun1_1487373619Penumbra, Sun1_1487373619ShadowSteps);
}
	return lightValue;
}

fixed4 defaultRaymarch(float3 ro, float3 rd, float s, inout float3 raypos, out float objectID)
{
	bool found = false;
	objectID = 0.0;

	float2 d;
	float t = 0; // current distance traveled along ray
	float3 p = float3(0, 0, 0);

#if FADE_TO_SKYBOX
	const float skyboxAlpha = 0;
#else
	const float skyboxAlpha = 1;
#endif

#if FOG_ENABLED
	fixed4 ret = fixed4(FogColor, skyboxAlpha);
#else
	fixed4 ret = fixed4(0,0,0,0);
#endif

	int numSteps;
	d = trace(ro, rd, raypos, numSteps, found);
	t = d.x;
	p = raypos;

#if DEBUG_STEPS
	float3 c = float3(1,0,0) * (1-(t / (float)numSteps));
	return fixed4(c, 1);
#elif DEBUG_MATERIALS
	float3 c = float3(1,1,1) * (d.y / 20);
	return fixed4(c, 1);
#endif

	[branch]
	if (found)
	{
		// First, we sample the map() function around our hit point to find the normal.
		float3 n = calcNormal(p);

		// Then, we get the color of the world at that point, based on our material ids.
		float3 color = MaterialFunc(d.y, n, p, rd, objectID);
		float3 light = getLights(color, p, n);

		// The ambient color is applied.
		color *= _AmbientColor.xyz;

		// And lights are added.
		color += light;

		// If enabled, darken with ambient occlusion.
		#if AO_ENABLED
		color *= ambientOcclusion(p, n);
		#endif

		// If fog is enabled, lerp towards the fog color based on the distance.
		#if FOG_ENABLED
		color = lerp(color, FogColor, 1.0-exp2(-FogDensity * t * t));
		#endif

		// If fading to the skybox is enabled, reduce the alpha value of the output pizel.
		#if FADE_TO_SKYBOX
		float alpha = lerp(1.0, 0, 1.0 - (_DrawDistance - t) / FadeToSkyboxDistance);
		#else
		float alpha = 1.0;
		#endif

		ret = fixed4(color, alpha);
	}

	raypos = p;
	return ret;
}


FragOut frag (v2f i)
{
    UNITY_SETUP_INSTANCE_ID(i);

    #if RENDER_OBJECT
    float3 rayDir = GetCameraDirection(i.screenPos);
    #else
    float3 rayDir = normalize(i.interpolatedRay);
    #endif

  	float3 rayOrigin = _WorldSpaceCameraPos + _ProjectionParams.y * rayDir;
    
	float3 raypos = float3(0, 0, 0);
	float objectID = 0.0;
	
	FragOut o;
	o.col = raymarch(rayOrigin, rayDir, _DrawDistance, raypos, objectID);
	o.col1 = float4(objectID, 0, 0, 1);
  #if !SKIP_DEPTH_WRITE
	o.depth = compute_depth(mul(UNITY_MATRIX_VP, float4(raypos, 1.0)));
	
	#if !FOG_ENABLED
	clip(o.col.a < 0.001 ? -1.0 : 1.0);
	#endif
  #endif
	
	return o;
}

ENDCG

}
}
}