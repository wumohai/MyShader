Shader "Custom/ImageSequence" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_HorizontalAmount("Horizontal Amount", Float) = 8
		_VerticalAmount("Vertical Amount", Float) = 8
		_Speed("Speed", Range(10,100)) = 30
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" }
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			LOD 200
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _HorizontalAmount;
				fixed _VerticalAmount;
				fixed _Speed;
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
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}
				fixed4 frag(v2f i):SV_Target{

					float time = floor(_Time.y * _Speed);
					float row = floor(time/_HorizontalAmount);
					float col = (time - row*_VerticalAmount);

					i.uv = float2(i.uv.x/_HorizontalAmount, i.uv.y / _VerticalAmount);

					i.uv.x += col / _HorizontalAmount;
					i.uv.y -= row / _VerticalAmount;
					fixed4 color = tex2D(_MainTex, i.uv);
					return color;
				}
			ENDCG
		}
	
	
	} 
	FallBack "Transparent/vertexLit"
}
