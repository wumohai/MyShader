Shader "Custom/MirrorShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Pass{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		#include "Lighting.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		struct a2v{
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD0;
		};
		struct v2f{
			float4 pos:SV_POSITION;
			float4 uv:TEXCOORD0;
		};
		v2f vert(a2v v){
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord; 
			o.uv.x = 1 - o.uv.x;
			return o;
		}

		fixed4 frag(v2f i):SV_Target{

			return tex2D(_MainTex, i.uv);
		}
		ENDCG
		}
	} 
	FallBack "Diffuse"
}
