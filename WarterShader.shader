Shader "Custom/WarterShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Magnitude("Distortion Magnitude", Float) = 1
		_Frequency("Distortion Frequency", Float) = 1
		_InvWaveLength("Distortion Invers Wave Lenght", Float) = 10
		_Speed("Speed", Range(0,10)) = 1
		
	}
	SubShader {
		Tags { 
			"RenderType"= "Transparent" 
			"Queue" = "Transparent" 
			"IgnoreProjector" = "True"
			"DisalbeBathing" = "True"
		}

		Pass{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			struct a2v{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;
				fixed4 offset = fixed4(0,0,0,0);
				offset = sin(_Time.y*_Frequency + v.vertex.x*_InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z*_InvWaveLength ) * _Magnitude;
				// offset = sin(_Time.y*_Frequency ) * _Magnitude;
				// offset = sin(  v.vertex.x*_InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z*_InvWaveLength ) * _Magnitude;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex + offset);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.y += _Time.y * _Speed;
				return o;
			}

			fixed4 frag(v2f i): SV_Target{
				return tex2D(_MainTex, i.uv.xy);
			}
			ENDCG
		}		
	} 
	FallBack "Diffuse"
}
