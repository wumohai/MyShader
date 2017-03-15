Shader "Custom/ScrollingBackgound" {
	Properties {
		_FarTex("far tex", 2D) = "white"{}
		_NearTex("near Tex", 2D) = "white"{}
		_FarSpeed("far speed", Range(0,1)) = 0.3
		_NearSpeed("near speed", Range(0,1)) = 0.5

		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _FarTex;
			float4 _FarTex_ST;
			sampler2D _NearTex;
			float4 _NearTex_ST;
			fixed _FarSpeed;
			fixed _NearSpeed;
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
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _FarTex) + frac(float2(_FarSpeed, 0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _NearTex) + frac(float2(_NearSpeed, 0) * _Time.y);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed4 colorFar = tex2D(_FarTex, i.uv.xy);
				fixed4 colorNear = tex2D(_NearTex, i.uv.zw);
				fixed4 colorMix = lerp(colorFar, colorNear, colorNear.a);
				return colorMix;
			}
			ENDCG


		}
	}
	FallBack "VertexLit"
}
