Shader "Custom/reflectShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_ReflectColor("reflect color", Color) = (1,1,1,1)
		_ReflectAmount("reflect amount", Range(0,1)) = 1
		_Cubemap("cube map", Cube) = "_Skybox" {}
		
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
			fixed4 _ReflectColor;
			fixed _ReflectAmount;
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
				float3 worldRefl:TEXCOORD3;
				SHADOW_COORDS(4)
			};
			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(_Object2World, v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
				TRANSFER_SHADOW(v);
				return o;
			}
			fixed4 frag(v2f i):SV_Target{
				fixed4 worldPos = normalize(i.worldPos);
				// fixed3 worldViewDir = normalize(i.worldViewDir);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).xyz * _ReflectColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
				// lerp(a,b,f) = (1-f) * a + f*b;
				// fixed3 color = (ambient + diffuse + reflection*_ReflectAmount ) * atten;
				return fixed4(color,1);
			}
			ENDCG
		}

	}
	FallBack "Diffuse"
}
