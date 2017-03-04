Shader "Custom/Shadow" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Specular("spelcular", Color) = (1,1,1,1)
		_Gloss("_Gloss", Range(8,256)) = 20
		
	}
	SubShader {
		Pass{
			Tags { "LightMode" = "ForwardBase" }
			LOD 200
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(_Object2World, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				float3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos).xyz);
				//fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 viewDir = normalize( UnityWorldSpaceViewDir(i.worldPos).xyz);
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
				float atten = 1.0; //directional light is Always 1.0
				return fixed4(ambient + (diffuse+specular)*atten, 1.0);
				//return fixed4(specular,1);
			}


			ENDCG		
		}

		
		Pass{
			Tags { "LightMode" = "ForwardAdd" }
			LOD 200
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#include "AutoLight.cginc"
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(_Object2World, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				float3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos).xyz);
				//fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 viewDir = normalize( UnityWorldSpaceViewDir(i.worldPos).xyz);
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
				#ifdef USING_DIRECTIONAL_LIGHT
					float atten = 1.0; //directional light is Always 1.0
				#else
					#if defined(POINT)
						float3 lightCoord = mul(_LightMatrix0, float4(i.worldPos,1)).xyz;//这里不能带w分量
						float atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined(SPOT)
						float4 lightCoord = mul(_LightMatrix0, float4(i.worldPos, 1));
						float atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy/lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#else
						float atten = 1.0;
					#endif
				#endif
				return fixed4(ambient + (diffuse+specular)*atten, 1.0);
				//return fixed4(specular,1);
			}
			ENDCG
		}
		Pass{
			// 计算阴影的纹理map
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}
			LOD 200
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
//			struct a2v{}
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f{
				V2F_SHADOW_CASTER;
			};
			v2f vert(a2v v){
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
				return o;
			}
			fixed4 frag(v2f i):SV_Target{
				SHADOW_CASTER_FRAGMENT(i);
			}
			ENDCG
		}

	} 
	FallBack "Specular"
}
