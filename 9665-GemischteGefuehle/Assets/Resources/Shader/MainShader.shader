Shader "Huettinger/Gemischte"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (0.5,0.5,0.5,1)
		_FractAmount("Extrusion Amount", Range(0,10)) = 0

		_HeightMap("Height Map", 2D) = "white" {}

		_Brightness("Brightness", Range(0,1)) = 0.5
		_Contrast("Contrast", Range(0,10)) = 1

		_Tess("Tessellation", Range(1,16)) = 4
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert addshadow tessellate:tessFixed 
			
		float _Tess;

		float4 tessFixed()
		{
			return _Tess;
		}

		struct Input {
			float2 uv_MainTex;
		};
			
		float _FractAmount;
		sampler2D _HeightMap;

		void vert(inout appdata_full v) {
			float d = (tex2Dlod(_HeightMap, float4(v.texcoord.xy, 0, 0)).r - 0.5)  * _FractAmount; // 
			v.vertex.xyz += v.normal * d;
		}

		sampler2D _MainTex;
		float4 _Color;
		float _Brightness;
		float _Contrast;

		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = (((tex2D(_MainTex, IN.uv_MainTex) - _Brightness)  * _Contrast) + _Brightness) * _Color;
			o.Normal = UnpackNormal(tex2D(_MainTex, IN.uv_MainTex));
		}

	ENDCG
	}
	
	FallBack "Diffuse"
		

}
