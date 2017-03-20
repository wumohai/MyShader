Shader "Custom/MyBrightnessSaturationAndContrast" {
	Properties {
		_MainTex("main tex ", 2D) = "white" {} 
		// _Saturation("saturation ", Range(0, 3)) = 1.0
		// _Brightness("_Brightness ", Range(0, 3)) = 1.0
		// _Contrast("_Contrast", Range(0, 3)) = 1.0

	}
	SubShader {
		
		Pass{ 
			LOD 200
			ZWrite Off
			ZTest Always
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Saturation;
			fixed _Brightness;
			fixed _Contrast;
			
			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};
			v2f vert(appdata_img v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			fixed4 frag(v2f i):SV_Target{
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 finalColor = texColor.rgb * _Brightness;

				fixed luminance = 0.21*texColor.r + 0.71 * texColor.g + 0.8*texColor.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);

				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);
				return fixed4(finalColor, texColor.a);
			}
			ENDCG
		}
		
	} 
	FallBack "Diffuse"
}
