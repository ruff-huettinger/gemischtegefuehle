Shader "GemGef/Background"
{


		Properties
		{
			_MainTex("Albedo Texture", 2D) = "white" {}
			_DetailAlbedoMap("Second Texture", 2D) = "white" {}
			_pickTexture("pick Texture", Range(0.0,1.0)) = 0.5
			_Color("Tint Color", Color) = (1,1,1,1)
			_lowContrast("low contrast", Range(0.0,1.0)) = 1.0
			_highContrast("high contrast", Range(0.0,1.0)) = 0.0
		}

			SubShader
		{
			Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
			LOD 100

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
		{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

			struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		sampler2D _DetailAlbedoMap;
		float _pickTexture;
		float4 _MainTex_ST;
		float4 _DetailAlbedoMap_ST;
		float4 _Color;
		float _lowContrast;
		float _highContrast;
		//( (tex2D(_MainTex, i.uv) + 0.5)*_lowContrast + 0.5* -  + _extraBright) * _Color;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}



		fixed4 frag(v2f i) : SV_Target
		{
			// sample the texture
			float2 scaled_uv = i.uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
			fixed4 col = tex2D(_MainTex, i.uv)*(1-_pickTexture) + tex2D(_DetailAlbedoMap, scaled_uv)*_pickTexture;
			col.g = col.r;
			col.b = col.r;
			//col = col * (_lowContrast * _Color + _highContrast * _lowContrast * _Color  - 0.5*_highContrast * _lowContrast *_Color) + _Color - _lowContrast * _Color;
			col = col*(1+_highContrast)-0.5*_highContrast;
			col = (col * _lowContrast) + 1 - _lowContrast;
			col *= _Color;
			return col;
		}
			ENDCG
		}
		}
	}
