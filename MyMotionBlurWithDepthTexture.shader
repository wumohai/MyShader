Shader "Custom/MyMotionBlurWithDepthTexture" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		
	}
	SubShader {
		CGINCLUDE
		fixed BlurSize;
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 PreviousViewProjectionMatrix;
		float4x4 CurrentViewprojectionInverseMatrix;
		#include "UnityCG.cginc"
		struct v2f{
			float4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
			half2 uv_depth:TEXCOORD1;
		};

		v2f vert(appdata_img v){
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;
			#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0){
					o.uv_depth.y = 1 - o.uv_depth.y;
				}
			#endif
			return o;
		}

		fixed4 frag(v2f i):SV_Target{
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			float4 H = float4(i.uv.x*2-1, i.uv.y*2-1, d*2-1, 1);
			float4 D = mul(CurrentViewprojectionInverseMatrix, H);
			float4 worldPos = D / D.w;

			float4 currentPos = H;
			float4 previousPos = mul(PreviousViewProjectionMatrix, worldPos);
			previousPos = previousPos/previousPos.w;

			float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

			float2 uv = i.uv;
			float4 c = tex2D(_MainTex, uv);
			uv += velocity* BlurSize;
			for(int it=1; it<3; it++, uv += velocity* BlurSize){
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}
			c /= 3;
			return fixed4(c.rgb, 1.0);
		}
		ENDCG
		Pass{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
