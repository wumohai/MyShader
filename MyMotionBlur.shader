Shader "Custom/MyMotionBlur" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		CGINCLUDE
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			fixed _BlurAmount;
			struct v2f{
				float4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
			};
			v2f vert(appdata_img v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			fixed4 fragRGB(v2f i):SV_Target{
				return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
			}
			fixed4 fragA(v2f i):SV_Target{
				return tex2D(_MainTex, i.uv);
			}
		ENDCG
		ZWrite Off ZTest Always Cull Off
		Pass{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment fragRGB
			ENDCG
		}
		Pass{
			ColorMask A
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment fragA
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
