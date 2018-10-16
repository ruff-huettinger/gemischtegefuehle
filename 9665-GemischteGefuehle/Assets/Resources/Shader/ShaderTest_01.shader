Shader "_test/ShaderTest_01"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			// make fog work
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			//@author: vux
			//@help: template for standard shaders
			//@tags: template
			//@credits: 

		Texture2D texture2d <string uiname = "Texture"; >;

	SamplerState linearSampler : IMMUTABLE
	{
		Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
	};

	cbuffer cbPerDraw : register(b0)
	{
		float4x4 tVP : LAYERVIEWPROJECTION;
		float time;
	};

	cbuffer cbPerObj : register(b1)
	{
		float4x4 tW : WORLD;
		float movementFractVar;
		float movementVar;
		float SPIRAL_NOISE_ITER;
		float sliderDamp;
		float4 Col1 <bool color = true; > = { 0.5,0.5,0.5,1.0 };
		float4 Col2 <bool color = true; > = { 0.5,0.5,0.5,1.0 };
		float4 Col3 <bool color = true; > = { 1.0,1.0,0.5,1.0 };
		float4 Col4 <bool color = true; > = { 0.4,0.3,0.5,1.0 };
		float4 id;
		float2 iMouse;
		float2 Resolution;
	};

	struct VS_IN
	{
		float4 PosO : POSITION;
		float4 TexCd : TEXCOORD0;

	};

	struct vs2ps
	{
		float4 PosWVP: SV_Position;
		float4 TexCd: TEXCOORD0;
	};

	vs2ps vert(VS_IN input)
	{
		vs2ps output;
		output.PosWVP = mul(input.PosO,mul(tW,tVP));
		output.TexCd = input.TexCd;
		return output;
	}


	float hash(const in float3 p) {
		return frac(sin(dot(p,float3(127.,311.7,758.5453123)))*43758.5453123);
	}

	//-------------------------------------------------------------------------------------
	float pn(in float3 x) {
		float3 p = floor(x),
			f = frac(x);
		f *= f * (3. - f - f);
		float2 uv = (p.xy + (float2)2.4*p.z) + f.xy;
		float2 rg = (float2)0;
		return time * lerp(rg.x, rg.y, f.z) - 1.;
	}

	//-------------------------------------------------------------------------------------
	//float normalizer = 1.0;
	const float nudge = 20.;	// size of perpendicular vector
								// pythagorean theorem on that perpendicular to maintain scale

	float SpiralNoiseC(float3 p, float4 id) {
		float normalizer = 1.0 / sqrt(1.0 + nudge * nudge);
		float iter = 2., n = movementFractVar - id.x; // noise amount
		for (int i = 0; i < SPIRAL_NOISE_ITER; i++) {
			// add sin and cos scaled inverse with the frequency
			n += -abs(sin(p.y*iter) + cos(p.x*iter)) / iter;	// abs for a ridged look
																// rotate by adding perpendicular and scaling down
			p.xy += float2(p.y, -p.x) * nudge;
			p.xy *= normalizer;
			// rotate on other axis

			p.xz += float2(p.z, -p.x) * nudge;
			p.xz *= normalizer;
			// increase the frequency
			iter *= id.y + .733733;
			//iter *= id.y + iGlobalTime*0.0001;
		}
		return n;
	}


	//-------------------------------------------------------------------------------------
	float fbm(float3 p)
	{
		return pn(p*.06125)*.5 + pn(p*.125)*.25 + pn(p*.25)*.125 + pn(p*.4)*.2;
	}

	//-------------------------------------------------------------------------------------
	//-------------------------------------------------------------------------------------
	//1 ShaneOrganic
	float map1(float3 p, float4 id) {
		float k = movementFractVar * id.w + .1;  // p/=k;
		p *= (.5 + 4.*id.y);
		return k * (.1 + abs(dot(p = cos(p*.6 + sin(p.zxy*1.8)), p) - 1.1)*3. + pn(p*4.5)*.12);
	}

	//-------------------------------------------------------------------------------------
	//2 normal
	float map2(float3 p, float4 id) {
		float k = movementFractVar * id.w + .1; //  p/=k;
		return k * (.5 + SpiralNoiseC(p.zxy*.4132 + 333., id)*3. + pn(p*8.5)*.12);
	}

	//-------------------------------------------------------------------------------------
	//3 mine
	float map3(float3 p, float4 id) {
		float k = movementFractVar * id.w + .1;  // p/=k;
		p *= (.5 + 4.*(id.y));
		return k * (.1 + abs(dot(p = cos(p*.6 + fbm((p.zxy))), p) - id.w)*3. + fbm(p*4.5)*.12);
	}
	//-------------------------------------------------------------------------------------
	//4 mineB
	float map4(float3 p, float4 id) {
		float k = movementFractVar * id.w + .1; //  p/=k;
		return k * (SpiralNoiseC(p.zxy, id) + pn(p));
	}
	//-------------------------------------------------------------------------------------
	//5 mineC lattice
	float map5(float3 p, float4 id) {
		float2 c;

		// SECTION 1
		//
		// Repeat field entity one, which is just some tubes repeated in all directions every
		// two units, then combined with a smooth minimum function. Otherwise known as a lattice.
		p = abs(frac(p*id.x)*3. - 1.5);
		//c.x = sminP(length(p.xy),sminP(length(p.yz),length(p.xz), 0.25), 0.25)-0.75; // EQN 1
		//c.x = sqrt(min(dot(p.xy, p.xy),min(dot(p.yz, p.yz),dot(p.xz, p.xz))))-0.75; // EQN 2
		c.x = min(max(p.x, p.y),min(max(p.y, p.z),max(p.x, p.z))) - id.w; // EQN 3
																		  //p = abs(p);
																		  //c.x = max(p.x,max(p.y,p.z)) - .5;


																		  // SECTION 2
																		  //
																		  // Repeat field entity two, which is just an abstract object repeated every half unit.
		p = abs(frac(p*4. / 3.)*.75 - 0.375);
		c.y = min(p.x,min(p.y,p.z)); // EQN 1
									 //c.y = min(max(p.x, p.y),min(max(p.y, p.z),max(p.x, p.z)))-0.125; //-0.175, etc. // EQN 2
									 //c.y = max(p.x,max(p.y,p.z)) - .4;

									 // SECTION 3
									 //
									 // Combining the two entities above.
									 //return length(c)-.1; // EQN 1
									 //return max(c.x, c.y)-.05; // EQN 2
		return max(abs(c.x), abs(c.y))*.75 + length(c)*.25 - .1;
		//return max(abs(c.x), abs(c.y))*.75 + abs(c.x+c.y)*.25 - .1;
		//return max(abs(c.x), abs(c.y)) - .1;
	}




	//-------------------------------------------------------------------------------------
	//-------------------------------------------------------------------------------------Color
	float3 hsv2rgb(float x, float y, float z) {
		return z + z * y*(clamp(abs(fmod(x*6. + float3(0,4,2),6.) - 3.) - 1.,0.,1.) - 1.);
	}

	//-------------------------------------------------------------------------------------Structure

	float4 renderSuperstructure(float3 ro, float3 rd, const float4 id) {
		const float max_dist = 20.;
		float ld = 0, td = 0., w, d, t, noi, lDist, a,
			rRef = 2.*id.x,
			h = .05 + .25*id.z;

		float3 pos, lightColor;
		float4 sum = float(0);

		t = .1*hash(float(hash(rd)));

		for (int i = 0; i<200; i++) {
			// Loop break conditions.
			if (td>.9 || sum.a > .99 || t>max_dist) break;

			// Color attenuation according to distance
			a = smoothstep(max_dist,0.,t);

			// Evaluate distance function
			//d = abs(mapVar(pos = ro + t*rd, id))+.07;////////////////////////////////////////////////////////////////////!!!/
			d = (map1(pos = ro + t * rd, id))*(1 - sliderDamp) + (map3(pos = ro + t * rd, id))*sliderDamp;
			//d = (map1(pos = ro + t*rd, id))*(1-sliderDamp)+(map2(pos = ro + t*rd, id))*(0.75-sliderDamp)+(map3(pos = ro + t*rd, id))*(0.5-sliderDamp)+(map4(pos = ro + t*rd, id))*(0.25-sliderDamp)+(map5(pos = ro + t*rd, id))*sliderDamp;
			//d = abs(mapVar(pos = ro + t*rd, id))+.07;////////////////////////////////////////////////////////////////////!!!
			//d = abs(mapVar(pos = ro + t*rd, id))+.07;////////////////////////////////////////////////////////////////////!!!

			// Light calculations
			lDist = max(length(fmod(pos + 2.5,5.) - 2.5), .001); // TODO add random offset
			noi = pn(0.03*pos);
			lightColor = lerp(hsv2rgb(noi + Col1.x,Col1.y,Col1.z),
				hsv2rgb(noi + Col2.x,Col2.y,Col2.z),
				smoothstep(rRef*.5,rRef*2.,lDist));
			sum.rgb += a * lightColor / exp(lDist*lDist*lDist*.08) / 30.;

			if (d<h) {
				td += (1. - td)*(h - d) + .005;  // accumulate density
				sum.rgb += sum.a * sum.rgb * .25 / lDist;  // emission
				sum += (1. - sum.a)*.05*td*a;  // uniform scale density + alpha blend in contribution
			}

			td += .015;
			t += max(d * .08 * max(min(lDist,d),2.), .01);  // trying to optimize step size
		}

		// simple scattering
		sum *= 1. / exp(ld*.2)*.9;
		sum = clamp(sum, 0., 1.);
		sum.xyz *= sum.xyz*(3. - sum.xyz - sum.xyz);
		return sum;
	}


	float4 frag(vs2ps In) : SV_Target
	{

		float4 sliderVal = float4(id.w ,id.x, id.y, id.z);
		float2 m = iMouse.xy / Resolution.xy;


		//float3 ro = float3(Resolution.x/2, Resolution.y/2, 0),

		float3 ursprung = float(15.);
		float3 ro = float3(ursprung.x*(movementVar*0.001), ursprung.y*(movementVar*0.001), ursprung.z*(movementVar*0.001)),
			rd = normalize(float3((In.TexCd.xy - 0.5*Resolution.xy) / Resolution.y, 1.));

		//R(rd.zx, m.x);
		//R(rd.yx, m.y);
		//R(rd.xz, 0);

		// Super Structure
		float4 col = renderSuperstructure(ro, rd, sliderVal);

		return col;
	}




		/*
		technique10 Constant
		{
			pass P0
			{
				SetVertexShader(CompileShader(vs_4_0, vert()));
				SetPixelShader(CompileShader(ps_4_0, frag()));
			}
		}

		*/



			ENDCG
		}
	}
}
