Shader "Custom/Fresnel" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_FresnelScale("fresnel scale", Range(0,1)) = 0.5
		_Cubemap("cube map", CUBE) = "_skybox" {}
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
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed _FresnelScale;
			samplerCUBE _Cubemap;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float4 worldPos:TEXCOORD1;
				float3 worldViewDir:TEXCOORD2;
				float3 worldReflect:TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(_Object2World, v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldReflect = reflect(-o.worldViewDir, o.worldNormal);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed fresnel = _FresnelScale + (1-_FresnelScale)*pow((1-dot(worldViewDir, worldNormal)),5);
				fixed3 reflection = texCUBE(_Cubemap, i.worldReflect).rgb;
				fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel));
				return fixed4(color,1);
			}
		
			ENDCG
		}

	} 
	FallBack "Diffuse"
}
