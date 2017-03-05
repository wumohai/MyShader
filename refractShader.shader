Shader "Custom/refractShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_RefractColor("refract color", Color) = (1,1,1,1)
		_RefractRatio("refract ratio", Range(0,1)) = 0.5
		_RefractAmount("refract amount", Range(0,1)) = 1
		_CubeMap("cube Map", Cube) = "_Skybox" {}

	}
	SubShader {
		Pass{
			//Name "Refract Shader"
			Tags{ "RenderType" = "Opaque"}
			LOD 200
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Color;
			fixed4 _RefractColor;
			fixed _RefractAmount;
			fixed _RefractRatio;
			samplerCUBE _CubeMap;
			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldViewDir:TEXCOORD1;
				float4 worldPos:TEXCOORD2;
				float3 worldRefr:TEXCOORD3;

				SHADOW_COORDS(4)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				// o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = v.normal;
				o.worldPos = mul(_Object2World, v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos).xyz;
				o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				float4 worldPos = normalize(i.worldPos);
				float3 worldNormal = normalize(i.worldNormal);
				// float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 refraction = texCUBE(_CubeMap, i.worldRefr).rgb * _RefractColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount)*atten;
				// fixed3 color =  diffuse;
				return fixed4(color, 1);
			}
			ENDCG
		}
		
	}
	FallBack "Diffuse"
}