Shader "Custom/SingleColor" {
  Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _MaskColor ("MaskColor", Color) = (0.3, 0.3, 0.3, 1.0)
  }
    SubShader {
	    Tags {
		    "RenderType" = "Transparent"
		    "Queue" = "Transparent" 
	    }
	
		Pass
		{  
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }

			Blend SrcAlpha OneMinusSrcAlpha // 颜色混合，destColorNew = ScrAlpha*SrcColor + (1-ScrAlpha)*destColorOld;

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _MaskColor;
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};
	
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				return fixed4(_MaskColor.xyz, tex2D(_MainTex, IN.texcoord).a);
			}
			ENDCG
		} 
	}
}