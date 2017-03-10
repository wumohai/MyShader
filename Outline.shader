Shader "Custom/Outline" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_OutLineColor("outline color", Color) = (0,0,1,1)
		_OutLineWidth("outline width",range(0,10)) = 0.005
	}
	SubShader {
		Pass{
			ZWrite Off
			CGPROGRAM 
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCg.cginc"

			struct v2f{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
			};
		 	sampler2D _MainTex;
			fixed _OutLineWidth;
			fixed4 _OutLineColor;
			v2f vert(appdata_base v){
				v2f o;
				v.vertex.xyz += v.normal * _OutLineWidth;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			fixed4 frag(v2f i) : COLOR{
				return _OutLineColor;
			}
			ENDCG
		}
		Pass    
        {  
            CGPROGRAM  
            #include "UnityCG.cginc"  
            #pragma vertex vert_img   
            #pragma fragment frag             
  
            sampler2D _MainTex;  
   
            float4 frag (v2f_img i) : COLOR {  
                    float4 col = tex2D(_MainTex, i.uv);   
                    return col;  
            }  
            ENDCG  
        }  

	} 
	FallBack "Diffuse"
}
