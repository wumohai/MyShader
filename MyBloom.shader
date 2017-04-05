Shader "Custom/MyBloom" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		CGINCLUDE
			#include "UnityCG.cginc"
			fixed _BlurSize;
			sampler2D _MainTex;
			fixed3 _MainTex_TexelSize;
			sampler2D _Bloom;
			fixed _LuminanceThreshold;

			struct v2f{
				float4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
			};
			v2f vertExtractBright(appdata_img v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed luminance(fixed4 color){
				return 0.2125*color.r + 0.7154*color.g + 0.0721*color.b;
			}

			fixed4 fragExtractBright(v2f i):SV_Target{
				fixed4 color = tex2D(_MainTex, i.uv);
				fixed val = clamp(luminance(color) - _LuminanceThreshold, 0.0, 1.0); //clamp(x,a,b); x<a return a. x>b return b.else return x;
				return color*val;
			}

			struct v2fBloom{
				float4 pos:SV_POSITION;
				half4 uv:TEXCOORD0;
			};
			v2fBloom vertexBloom(appdata_img v){
				v2fBloom o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = v.texcoord;
				o.uv.zw = v.texcoord;

				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y < 0.0){
						o.uv.w = 1.0f -o.uv.w;
					}
				#endif
				return o;
			}
			fixed4 fragBloom(v2fBloom i):SV_Target{
				return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
			}
		ENDCG		

		ZTest Always Cull Off ZWrite Off
		Pass{
			CGPROGRAM
			#pragma vertex vertExtractBright
			#pragma fragment fragExtractBright
			ENDCG
		}
		UsePass "Custom/MyGaussianBlur/GAUSSIAN_BLUR_VERTICAL"
		UsePass "Custom/MyGaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"
		Pass{
			CGPROGRAM
			#pragma vertex vertexBloom
			#pragma fragment fragBloom
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
