Shader "Huettinger/Contrast"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)    
		_Brightness("Brightness", Range(0,1)) = 0.5
		_Contrast("Contrast", Range(0,100)) = 1
	}
	
	SubShader
	{

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
			struct vertOut
			{
				float4 vertex : SV_POSITION;
				float4 worldSpacePosition : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};

			vertOut vert(appdata vertIn)
			{
				vertOut o;
				o.vertex = UnityObjectToClipPos(vertIn.vertex);
				o.worldSpacePosition = mul(unity_ObjectToWorld, vertIn.vertex);
				o.uv = vertIn.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float4 _Color;
			float _Brightness;
			float _Contrast;

			float4 frag(vertOut fragIn) : COLOR
			{
				return (((tex2D(_MainTex, fragIn.uv)  - _Brightness)  * _Contrast) +  _Brightness ) * _Color;
				
			}

			ENDCG
		}
	}
}
