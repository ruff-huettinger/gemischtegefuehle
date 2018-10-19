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
  
  for Raymarcher named 'Raymarcher' in scene '_test01_'.

*/


Shader "Hidden/__test01__340338605.generated"
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

// Light Main Light
uniform float4 MainLight_1597974PosAndRange;
uniform float4 MainLight_1597974ColorAndIntensity;
uniform float3 MainLight_1597974Direction;
uniform float MainLight_1597974Penumbra;
uniform int MainLight_1597974ShadowSteps;
// Light Fill Light
uniform float4 FillLight_1597761PosAndRange;
uniform float4 FillLight_1597761ColorAndIntensity;
uniform float3 FillLight_1597761Direction;
uniform float FillLight_1597761Penumbra;
uniform int FillLight_1597761ShadowSteps;

// UNIFORMS AND FUNCTIONS
uniform float x_1575809_ce8993a9_x;
uniform float x_1575809_ce8993a9_y;
uniform float x_1575809_ce8993a9_z;
float object_Box(float3 p , float _INP_x, float _INP_y, float _INP_z) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Objects/Box.asset
    float3 d = abs(p)-float3(_INP_x,_INP_y,_INP_z);
    float b = min(max(d.x, max(d.y,d.z)), 0) + length(max(d, 0));
    return b;
    
    // The MIT License
    // Copyright © 2013 Inigo Quilez
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    
}
uniform float x_1597017_6492bb9b_radius;
uniform float x_1575908_6492bb9b_radius;
uniform float x_1574887_6492bb9b_radius;
uniform float x_1574817_6492bb9b_radius;
uniform float x_1596920_6492bb9b_radius;
uniform float x_1575720_6492bb9b_radius;
uniform float x_1573889_6492bb9b_radius;
uniform float x_1597823_6492bb9b_radius;
uniform float x_1573918_6492bb9b_radius;
uniform float x_1573957_6492bb9b_radius;
uniform float x_1574724_6492bb9b_radius;
uniform float x_1574761_6492bb9b_radius;
uniform float x_1574015_6492bb9b_radius;
uniform float x_1575873_6492bb9b_radius;
uniform float x_1574732_6492bb9b_radius;
uniform float x_1597887_6492bb9b_radius;
uniform float x_1597757_6492bb9b_radius;
uniform float x_1575691_6492bb9b_radius;
uniform float x_1574852_6492bb9b_radius;
uniform float x_1574695_6492bb9b_radius;
uniform float x_1575937_6492bb9b_radius;
uniform float x_1597949_6492bb9b_radius;
uniform float x_1596990_6492bb9b_radius;
uniform float x_1597794_6492bb9b_radius;
uniform float x_1574974_6492bb9b_radius;
uniform float x_1575782_6492bb9b_radius;
uniform float x_1596862_6492bb9b_radius;
uniform float x_1574945_6492bb9b_radius;
uniform float x_1573986_6492bb9b_radius;
uniform float x_1596804_6492bb9b_radius;
uniform float x_1575753_6492bb9b_radius;
uniform float x_1596891_6492bb9b_radius;
uniform float x_1596831_6492bb9b_radius;
uniform float x_1575815_6492bb9b_radius;
uniform float x_1573858_6492bb9b_radius;
float object_Sphere(float3 p , float _INP_radius) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Objects/Sphere.asset
    return length(p) - _INP_radius;
}
uniform float x_1573831_399aefe0_radius;
uniform float x_1573831_399aefe0_height;
uniform float x_1597914_399aefe0_radius;
uniform float x_1597914_399aefe0_height;
uniform float x_1574788_399aefe0_radius;
uniform float x_1574788_399aefe0_height;
float object_Cylinder(float3 p , float _INP_radius, float _INP_height) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Objects/Cylinder.asset
    float2 d = abs(float2(length(p.xz),p.y)) - float2(_INP_radius, _INP_height);
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
    
    // The MIT License
    // Copyright © 2013 Inigo Quilez
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}
// uniforms for bg box
uniform float4x4 _1575809Matrix;
uniform float _1575809MinScale;
// uniforms for Sphere
uniform float4x4 _1597017Matrix;
uniform float _1597017MinScale;
// uniforms for Sphere
uniform float4x4 _1575908Matrix;
uniform float _1575908MinScale;
// uniforms for Sphere
uniform float4x4 _1574887Matrix;
uniform float _1574887MinScale;
// uniforms for Sphere
uniform float4x4 _1574817Matrix;
uniform float _1574817MinScale;
// uniforms for Sphere
uniform float4x4 _1596920Matrix;
uniform float _1596920MinScale;
// uniforms for Sphere
uniform float4x4 _1575720Matrix;
uniform float _1575720MinScale;
// uniforms for Sphere
uniform float4x4 _1573889Matrix;
uniform float _1573889MinScale;
// uniforms for Sphere
uniform float4x4 _1597823Matrix;
uniform float _1597823MinScale;
// uniforms for Sphere
uniform float4x4 _1573918Matrix;
uniform float _1573918MinScale;
// uniforms for Sphere
uniform float4x4 _1573957Matrix;
uniform float _1573957MinScale;
// uniforms for Sphere
uniform float4x4 _1574724Matrix;
uniform float _1574724MinScale;
// uniforms for Sphere
uniform float4x4 _1574761Matrix;
uniform float _1574761MinScale;
// uniforms for Sphere
uniform float4x4 _1574015Matrix;
uniform float _1574015MinScale;
// uniforms for Sphere
uniform float4x4 _1575873Matrix;
uniform float _1575873MinScale;
// uniforms for Sphere
uniform float4x4 _1574732Matrix;
uniform float _1574732MinScale;
// uniforms for Sphere
uniform float4x4 _1597887Matrix;
uniform float _1597887MinScale;
// uniforms for Sphere
uniform float4x4 _1597757Matrix;
uniform float _1597757MinScale;
// uniforms for Sphere
uniform float4x4 _1575691Matrix;
uniform float _1575691MinScale;
// uniforms for Sphere
uniform float4x4 _1574852Matrix;
uniform float _1574852MinScale;
// uniforms for Sphere
uniform float4x4 _1574695Matrix;
uniform float _1574695MinScale;
// uniforms for Sphere
uniform float4x4 _1575937Matrix;
uniform float _1575937MinScale;
// uniforms for Sphere
uniform float4x4 _1597949Matrix;
uniform float _1597949MinScale;
// uniforms for Sphere
uniform float4x4 _1596990Matrix;
uniform float _1596990MinScale;
// uniforms for Sphere
uniform float4x4 _1597794Matrix;
uniform float _1597794MinScale;
// uniforms for Sphere
uniform float4x4 _1574974Matrix;
uniform float _1574974MinScale;
// uniforms for Sphere
uniform float4x4 _1575782Matrix;
uniform float _1575782MinScale;
// uniforms for Sphere
uniform float4x4 _1596862Matrix;
uniform float _1596862MinScale;
// uniforms for Sphere
uniform float4x4 _1574945Matrix;
uniform float _1574945MinScale;
// uniforms for Sphere
uniform float4x4 _1573986Matrix;
uniform float _1573986MinScale;
// uniforms for Sphere
uniform float4x4 _1596804Matrix;
uniform float _1596804MinScale;
// uniforms for Sphere
uniform float4x4 _1575753Matrix;
uniform float _1575753MinScale;
// uniforms for Sphere
uniform float4x4 _1596891Matrix;
uniform float _1596891MinScale;
// uniforms for Sphere
uniform float4x4 _1596831Matrix;
uniform float _1596831MinScale;
// uniforms for Cylinder
uniform float4x4 _1573831Matrix;
uniform float _1573831MinScale;
// uniforms for Sphere
uniform float4x4 _1575815Matrix;
uniform float _1575815MinScale;
// uniforms for Cylinder
uniform float4x4 _1597914Matrix;
uniform float _1597914MinScale;
// uniforms for Sphere
uniform float4x4 _1573858Matrix;
uniform float _1573858MinScale;
// uniforms for Cylinder
uniform float4x4 _1574788Matrix;
uniform float _1574788MinScale;
uniform float x_1573796_44192f17_intensity;
uniform float x_1574916_44192f17_intensity;
uniform float x_1573736_44192f17_intensity;
uniform float x_1596982_44192f17_intensity;
uniform float x_1596796_44192f17_intensity;
uniform float x_1574879_44192f17_intensity;
uniform float x_1573825_44192f17_intensity;
uniform float x_1575879_44192f17_intensity;
uniform float x_1574823_44192f17_intensity;
float2 blend_Smooth(float2 a, float2 b , float _INP_intensity) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Blends/Smooth.asset
    float h = saturate(0.5 + 0.5*(b - a) / _INP_intensity);
    return lerp(b, a, h) - _INP_intensity*h*(1 - h);
}
float2 blend_Subtract(float2 a, float2 b /*, [object params] */) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Blends/Subtract.asset
    return float2(max(-a.x, b.x), b.y);
}
float2 blend_Intersection(float2 a, float2 b /*, [object params] */) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Blends/Intersection.asset
    return max(a, b);
    
}
uniform float x_1597044_131749b2_whichObject;
float2 blend_Morph(float2 a, float2 b , float _INP_whichObject) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Blends/Morph.asset
    return lerp(a, b, _INP_whichObject);
}
uniform float2 x_1575809_07ee3232_position;
uniform sampler2D x_1575809_07ee3232_gradient;
float3 material_Gradient(inout float3 normal, float3 p, float3 rayDir, float2 _INP_position, sampler2D _INP_gradient) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Materials/Gradient.asset
    float f = clamp((p.y - _INP_position.x) / _INP_position.y,0,1);
    return tex2Dlod(_INP_gradient, float4(f, 0, 0, 0));
}
uniform float4 x_1597017_da843a44_color;
uniform float4 x_1575908_da843a44_color;
uniform float4 x_1574887_da843a44_color;
uniform float4 x_1574817_da843a44_color;
uniform float4 x_1596920_da843a44_color;
uniform float4 x_1575720_da843a44_color;
uniform float4 x_1573889_da843a44_color;
uniform float4 x_1597823_da843a44_color;
uniform float4 x_1573918_da843a44_color;
uniform float4 x_1573957_da843a44_color;
uniform float4 x_1574724_da843a44_color;
uniform float4 x_1574761_da843a44_color;
uniform float4 x_1574015_da843a44_color;
uniform float4 x_1575873_da843a44_color;
uniform float4 x_1574732_da843a44_color;
uniform float4 x_1597887_da843a44_color;
uniform float4 x_1597757_da843a44_color;
uniform float4 x_1575691_da843a44_color;
uniform float4 x_1574852_da843a44_color;
uniform float4 x_1574695_da843a44_color;
uniform float4 x_1575937_da843a44_color;
uniform float4 x_1597949_da843a44_color;
uniform float4 x_1596990_da843a44_color;
uniform float4 x_1597794_da843a44_color;
uniform float4 x_1574974_da843a44_color;
uniform float4 x_1575782_da843a44_color;
uniform float4 x_1596862_da843a44_color;
uniform float4 x_1574945_da843a44_color;
uniform float4 x_1573986_da843a44_color;
uniform float4 x_1596804_da843a44_color;
uniform float4 x_1575753_da843a44_color;
uniform float4 x_1596891_da843a44_color;
uniform float4 x_1596831_da843a44_color;
uniform float4 x_1573831_da843a44_color;
uniform float4 x_1575815_da843a44_color;
uniform float4 x_1597914_da843a44_color;
uniform float4 x_1573858_da843a44_color;
uniform float4 x_1574788_da843a44_color;
float3 material_SimpleColor(inout float3 normal, float3 p, float3 rayDir, float4 _INP_color) {
    // Generated from Assets/Raymarching Toolkit/Assets/Snippets/Materials/SimpleColor.asset
    return _INP_color;
}
float3 MaterialFunc(float nf, inout float3 normal, float3 p, float3 rayDir, out float objectID)
{
    objectID = ceil(nf) / (float)39;
    [branch] if (nf <= 1) {
    //    objectID = 0.02564103;
        return material_Gradient(normal, objPos(_1575809Matrix, p), rayDir, x_1575809_07ee3232_position, x_1575809_07ee3232_gradient);
    }
    else if(nf <= 2) {
    //    objectID = 0.05128205;
        return material_SimpleColor(normal, objPos(_1597017Matrix, p), rayDir, x_1597017_da843a44_color);
    }
    else if(nf <= 3) {
    //    objectID = 0.07692308;
        return material_SimpleColor(normal, objPos(_1575908Matrix, p), rayDir, x_1575908_da843a44_color);
    }
    else if(nf <= 4) {
    //    objectID = 0.1025641;
        return material_SimpleColor(normal, objPos(_1574887Matrix, p), rayDir, x_1574887_da843a44_color);
    }
    else if(nf <= 5) {
    //    objectID = 0.1282051;
        return material_SimpleColor(normal, objPos(_1574817Matrix, p), rayDir, x_1574817_da843a44_color);
    }
    else if(nf <= 6) {
    //    objectID = 0.1538462;
        return material_SimpleColor(normal, objPos(_1596920Matrix, p), rayDir, x_1596920_da843a44_color);
    }
    else if(nf <= 7) {
    //    objectID = 0.1794872;
        return material_SimpleColor(normal, objPos(_1575720Matrix, p), rayDir, x_1575720_da843a44_color);
    }
    else if(nf <= 8) {
    //    objectID = 0.2051282;
        return material_SimpleColor(normal, objPos(_1573889Matrix, p), rayDir, x_1573889_da843a44_color);
    }
    else if(nf <= 9) {
    //    objectID = 0.2307692;
        return material_SimpleColor(normal, objPos(_1597823Matrix, p), rayDir, x_1597823_da843a44_color);
    }
    else if(nf <= 10) {
    //    objectID = 0.2564103;
        return material_SimpleColor(normal, objPos(_1573918Matrix, p), rayDir, x_1573918_da843a44_color);
    }
    else if(nf <= 11) {
    //    objectID = 0.2820513;
        return material_SimpleColor(normal, objPos(_1573957Matrix, p), rayDir, x_1573957_da843a44_color);
    }
    else if(nf <= 12) {
    //    objectID = 0.3076923;
        return material_SimpleColor(normal, objPos(_1574724Matrix, p), rayDir, x_1574724_da843a44_color);
    }
    else if(nf <= 13) {
    //    objectID = 0.3333333;
        return material_SimpleColor(normal, objPos(_1574761Matrix, p), rayDir, x_1574761_da843a44_color);
    }
    else if(nf <= 14) {
    //    objectID = 0.3589744;
        return material_SimpleColor(normal, objPos(_1574015Matrix, p), rayDir, x_1574015_da843a44_color);
    }
    else if(nf <= 15) {
    //    objectID = 0.3846154;
        return material_SimpleColor(normal, objPos(_1575873Matrix, p), rayDir, x_1575873_da843a44_color);
    }
    else if(nf <= 16) {
    //    objectID = 0.4102564;
        return material_SimpleColor(normal, objPos(_1574732Matrix, p), rayDir, x_1574732_da843a44_color);
    }
    else if(nf <= 17) {
    //    objectID = 0.4358974;
        return material_SimpleColor(normal, objPos(_1597887Matrix, p), rayDir, x_1597887_da843a44_color);
    }
    else if(nf <= 18) {
    //    objectID = 0.4615385;
        return material_SimpleColor(normal, objPos(_1597757Matrix, p), rayDir, x_1597757_da843a44_color);
    }
    else if(nf <= 19) {
    //    objectID = 0.4871795;
        return material_SimpleColor(normal, objPos(_1575691Matrix, p), rayDir, x_1575691_da843a44_color);
    }
    else if(nf <= 20) {
    //    objectID = 0.5128205;
        return material_SimpleColor(normal, objPos(_1574852Matrix, p), rayDir, x_1574852_da843a44_color);
    }
    else if(nf <= 21) {
    //    objectID = 0.5384616;
        return material_SimpleColor(normal, objPos(_1574695Matrix, p), rayDir, x_1574695_da843a44_color);
    }
    else if(nf <= 22) {
    //    objectID = 0.5641026;
        return material_SimpleColor(normal, objPos(_1575937Matrix, p), rayDir, x_1575937_da843a44_color);
    }
    else if(nf <= 23) {
    //    objectID = 0.5897436;
        return material_SimpleColor(normal, objPos(_1597949Matrix, p), rayDir, x_1597949_da843a44_color);
    }
    else if(nf <= 24) {
    //    objectID = 0.6153846;
        return material_SimpleColor(normal, objPos(_1596990Matrix, p), rayDir, x_1596990_da843a44_color);
    }
    else if(nf <= 25) {
    //    objectID = 0.6410257;
        return material_SimpleColor(normal, objPos(_1597794Matrix, p), rayDir, x_1597794_da843a44_color);
    }
    else if(nf <= 26) {
    //    objectID = 0.6666667;
        return material_SimpleColor(normal, objPos(_1574974Matrix, p), rayDir, x_1574974_da843a44_color);
    }
    else if(nf <= 27) {
    //    objectID = 0.6923077;
        return material_SimpleColor(normal, objPos(_1575782Matrix, p), rayDir, x_1575782_da843a44_color);
    }
    else if(nf <= 28) {
    //    objectID = 0.7179487;
        return material_SimpleColor(normal, objPos(_1596862Matrix, p), rayDir, x_1596862_da843a44_color);
    }
    else if(nf <= 29) {
    //    objectID = 0.7435898;
        return material_SimpleColor(normal, objPos(_1574945Matrix, p), rayDir, x_1574945_da843a44_color);
    }
    else if(nf <= 30) {
    //    objectID = 0.7692308;
        return material_SimpleColor(normal, objPos(_1573986Matrix, p), rayDir, x_1573986_da843a44_color);
    }
    else if(nf <= 31) {
    //    objectID = 0.7948718;
        return material_SimpleColor(normal, objPos(_1596804Matrix, p), rayDir, x_1596804_da843a44_color);
    }
    else if(nf <= 32) {
    //    objectID = 0.8205128;
        return material_SimpleColor(normal, objPos(_1575753Matrix, p), rayDir, x_1575753_da843a44_color);
    }
    else if(nf <= 33) {
    //    objectID = 0.8461539;
        return material_SimpleColor(normal, objPos(_1596891Matrix, p), rayDir, x_1596891_da843a44_color);
    }
    else if(nf <= 34) {
    //    objectID = 0.8717949;
        return material_SimpleColor(normal, objPos(_1596831Matrix, p), rayDir, x_1596831_da843a44_color);
    }
    else if(nf <= 35) {
    //    objectID = 0.8974359;
        return material_SimpleColor(normal, objPos(_1573831Matrix, p), rayDir, x_1573831_da843a44_color);
    }
    else if(nf <= 36) {
    //    objectID = 0.9230769;
        return material_SimpleColor(normal, objPos(_1575815Matrix, p), rayDir, x_1575815_da843a44_color);
    }
    else if(nf <= 37) {
    //    objectID = 0.948718;
        return material_SimpleColor(normal, objPos(_1597914Matrix, p), rayDir, x_1597914_da843a44_color);
    }
    else if(nf <= 38) {
    //    objectID = 0.974359;
        return material_SimpleColor(normal, objPos(_1573858Matrix, p), rayDir, x_1573858_da843a44_color);
    }
    else if(nf <= 39) {
    //    objectID = 1;
        return material_SimpleColor(normal, objPos(_1574788Matrix, p), rayDir, x_1574788_da843a44_color);
    }
        objectID = 0;
        return float3(1.0, 0.0, 1.0);
    }

#define raymarch defaultRaymarch

float2 map(float3 p) {
	float2 result = float2(1.0, 0.0);
	
{
    float _1575809Distance = object_Box(objPos(_1575809Matrix, p), x_1575809_ce8993a9_x, x_1575809_ce8993a9_y, x_1575809_ce8993a9_z) * _1575809MinScale;
    float _1597017Distance = object_Sphere(objPos(_1597017Matrix, p), x_1597017_6492bb9b_radius) * _1597017MinScale;
    float _1575908Distance = object_Sphere(objPos(_1575908Matrix, p), x_1575908_6492bb9b_radius) * _1575908MinScale;
    float _1574887Distance = object_Sphere(objPos(_1574887Matrix, p), x_1574887_6492bb9b_radius) * _1574887MinScale;
    float _1574817Distance = object_Sphere(objPos(_1574817Matrix, p), x_1574817_6492bb9b_radius) * _1574817MinScale;
    float _1596920Distance = object_Sphere(objPos(_1596920Matrix, p), x_1596920_6492bb9b_radius) * _1596920MinScale;
    float _1575720Distance = object_Sphere(objPos(_1575720Matrix, p), x_1575720_6492bb9b_radius) * _1575720MinScale;
    float _1573889Distance = object_Sphere(objPos(_1573889Matrix, p), x_1573889_6492bb9b_radius) * _1573889MinScale;
    float _1597823Distance = object_Sphere(objPos(_1597823Matrix, p), x_1597823_6492bb9b_radius) * _1597823MinScale;
    float _1573918Distance = object_Sphere(objPos(_1573918Matrix, p), x_1573918_6492bb9b_radius) * _1573918MinScale;
    float _1573957Distance = object_Sphere(objPos(_1573957Matrix, p), x_1573957_6492bb9b_radius) * _1573957MinScale;
    float _1574724Distance = object_Sphere(objPos(_1574724Matrix, p), x_1574724_6492bb9b_radius) * _1574724MinScale;
    float _1574761Distance = object_Sphere(objPos(_1574761Matrix, p), x_1574761_6492bb9b_radius) * _1574761MinScale;
    float _1574015Distance = object_Sphere(objPos(_1574015Matrix, p), x_1574015_6492bb9b_radius) * _1574015MinScale;
    float _1575873Distance = object_Sphere(objPos(_1575873Matrix, p), x_1575873_6492bb9b_radius) * _1575873MinScale;
    float _1574732Distance = object_Sphere(objPos(_1574732Matrix, p), x_1574732_6492bb9b_radius) * _1574732MinScale;
    float _1597887Distance = object_Sphere(objPos(_1597887Matrix, p), x_1597887_6492bb9b_radius) * _1597887MinScale;
    float _1597757Distance = object_Sphere(objPos(_1597757Matrix, p), x_1597757_6492bb9b_radius) * _1597757MinScale;
    float _1575691Distance = object_Sphere(objPos(_1575691Matrix, p), x_1575691_6492bb9b_radius) * _1575691MinScale;
    float _1574852Distance = object_Sphere(objPos(_1574852Matrix, p), x_1574852_6492bb9b_radius) * _1574852MinScale;
    float _1574695Distance = object_Sphere(objPos(_1574695Matrix, p), x_1574695_6492bb9b_radius) * _1574695MinScale;
    float _1575937Distance = object_Sphere(objPos(_1575937Matrix, p), x_1575937_6492bb9b_radius) * _1575937MinScale;
    float _1597949Distance = object_Sphere(objPos(_1597949Matrix, p), x_1597949_6492bb9b_radius) * _1597949MinScale;
    float _1596990Distance = object_Sphere(objPos(_1596990Matrix, p), x_1596990_6492bb9b_radius) * _1596990MinScale;
    float _1597794Distance = object_Sphere(objPos(_1597794Matrix, p), x_1597794_6492bb9b_radius) * _1597794MinScale;
    float _1574974Distance = object_Sphere(objPos(_1574974Matrix, p), x_1574974_6492bb9b_radius) * _1574974MinScale;
    float _1575782Distance = object_Sphere(objPos(_1575782Matrix, p), x_1575782_6492bb9b_radius) * _1575782MinScale;
    float _1596862Distance = object_Sphere(objPos(_1596862Matrix, p), x_1596862_6492bb9b_radius) * _1596862MinScale;
    float _1574945Distance = object_Sphere(objPos(_1574945Matrix, p), x_1574945_6492bb9b_radius) * _1574945MinScale;
    float _1573986Distance = object_Sphere(objPos(_1573986Matrix, p), x_1573986_6492bb9b_radius) * _1573986MinScale;
    float _1596804Distance = object_Sphere(objPos(_1596804Matrix, p), x_1596804_6492bb9b_radius) * _1596804MinScale;
    float _1575753Distance = object_Sphere(objPos(_1575753Matrix, p), x_1575753_6492bb9b_radius) * _1575753MinScale;
    float _1596891Distance = object_Sphere(objPos(_1596891Matrix, p), x_1596891_6492bb9b_radius) * _1596891MinScale;
    float _1596831Distance = object_Sphere(objPos(_1596831Matrix, p), x_1596831_6492bb9b_radius) * _1596831MinScale;
    float _1573831Distance = object_Cylinder(objPos(_1573831Matrix, p), x_1573831_399aefe0_radius, x_1573831_399aefe0_height) * _1573831MinScale;
    float _1575815Distance = object_Sphere(objPos(_1575815Matrix, p), x_1575815_6492bb9b_radius) * _1575815MinScale;
    float _1597914Distance = object_Cylinder(objPos(_1597914Matrix, p), x_1597914_399aefe0_radius, x_1597914_399aefe0_height) * _1597914MinScale;
    float _1573858Distance = object_Sphere(objPos(_1573858Matrix, p), x_1573858_6492bb9b_radius) * _1573858MinScale;
    float _1574788Distance = object_Cylinder(objPos(_1574788Matrix, p), x_1574788_399aefe0_radius, x_1574788_399aefe0_height) * _1574788MinScale;
    result = opU(opU(opU(opU(float2(_1575809Distance, /*material ID*/0.5), blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(blend_Smooth(float2(_1597017Distance, /*material ID*/1.5), float2(_1575908Distance, /*material ID*/2.5), x_1574916_44192f17_intensity), float2(_1574887Distance, /*material ID*/3.5), x_1574916_44192f17_intensity), float2(_1574817Distance, /*material ID*/4.5), x_1574916_44192f17_intensity), blend_Smooth(blend_Smooth(blend_Smooth(float2(_1596920Distance, /*material ID*/5.5), float2(_1575720Distance, /*material ID*/6.5), x_1573736_44192f17_intensity), float2(_1573889Distance, /*material ID*/7.5), x_1573736_44192f17_intensity), float2(_1597823Distance, /*material ID*/8.5), x_1573736_44192f17_intensity), x_1573796_44192f17_intensity), blend_Smooth(blend_Smooth(blend_Smooth(float2(_1573918Distance, /*material ID*/9.5), float2(_1573957Distance, /*material ID*/10.5), x_1596982_44192f17_intensity), float2(_1574724Distance, /*material ID*/11.5), x_1596982_44192f17_intensity), float2(_1574761Distance, /*material ID*/12.5), x_1596982_44192f17_intensity), x_1573796_44192f17_intensity), blend_Smooth(blend_Smooth(blend_Smooth(float2(_1574015Distance, /*material ID*/13.5), float2(_1575873Distance, /*material ID*/14.5), x_1596796_44192f17_intensity), float2(_1574732Distance, /*material ID*/15.5), x_1596796_44192f17_intensity), float2(_1597887Distance, /*material ID*/16.5), x_1596796_44192f17_intensity), x_1573796_44192f17_intensity), blend_Smooth(blend_Smooth(blend_Smooth(float2(_1597757Distance, /*material ID*/17.5), float2(_1575691Distance, /*material ID*/18.5), x_1574879_44192f17_intensity), float2(_1574852Distance, /*material ID*/19.5), x_1574879_44192f17_intensity), float2(_1574695Distance, /*material ID*/20.5), x_1574879_44192f17_intensity), x_1573796_44192f17_intensity), blend_Smooth(blend_Smooth(blend_Smooth(float2(_1575937Distance, /*material ID*/21.5), float2(_1597949Distance, /*material ID*/22.5), x_1573825_44192f17_intensity), float2(_1596990Distance, /*material ID*/23.5), x_1573825_44192f17_intensity), float2(_1597794Distance, /*material ID*/24.5), x_1573825_44192f17_intensity), x_1573796_44192f17_intensity), blend_Smooth(blend_Smooth(blend_Smooth(float2(_1574974Distance, /*material ID*/25.5), float2(_1575782Distance, /*material ID*/26.5), x_1575879_44192f17_intensity), float2(_1596862Distance, /*material ID*/27.5), x_1575879_44192f17_intensity), float2(_1574945Distance, /*material ID*/28.5), x_1575879_44192f17_intensity), x_1573796_44192f17_intensity), blend_Smooth(blend_Smooth(blend_Smooth(float2(_1573986Distance, /*material ID*/29.5), float2(_1596804Distance, /*material ID*/30.5), x_1574823_44192f17_intensity), float2(_1575753Distance, /*material ID*/31.5), x_1574823_44192f17_intensity), float2(_1596891Distance, /*material ID*/32.5), x_1574823_44192f17_intensity), x_1573796_44192f17_intensity)), blend_Subtract(float2(_1596831Distance, /*material ID*/33.5), float2(_1573831Distance, /*material ID*/34.5))), blend_Intersection(float2(_1575815Distance, /*material ID*/35.5), float2(_1597914Distance, /*material ID*/36.5))), blend_Morph(float2(_1573858Distance, /*material ID*/37.5), float2(_1574788Distance, /*material ID*/38.5), x_1597044_131749b2_whichObject));
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
light.posAndRange = MainLight_1597974PosAndRange;
light.colorAndIntensity = MainLight_1597974ColorAndIntensity;
light.direction = MainLight_1597974Direction;
lightValue += getDirectionalLight(input, light)* softshadow(input.pos, -light.direction, INFINITY, MainLight_1597974Penumbra, MainLight_1597974ShadowSteps);
}
{
LightInfo light;
light.posAndRange = FillLight_1597761PosAndRange;
light.colorAndIntensity = FillLight_1597761ColorAndIntensity;
light.direction = FillLight_1597761Direction;
lightValue += getDirectionalLight(input, light);
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