Shader "Custom/NormalMapInWorldSpace" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpTex ("Nomal Tex", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Glossiness ("Smoothness", Range(8,256)) = 20
		_Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
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
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;
			float _Glossiness;
			fixed3 _Specular;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f{
				float4 pos :SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 TtoW1:TEXCOORD1;
				float4 TtoW2:TEXCOORD2;
				float4 TtoW3:TEXCOORD3;
			};

			v2f vert(a2v IN){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
				o.uv.xy = TRANSFORM_TEX(IN.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(IN.texcoord, _BumpTex); //uv坐标 这里可以在IN结构体里面定义float uv_BumpTex;同样可以取到uv坐标
				float3 worldPos = mul(_Object2World, IN.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(IN.normal);
				float3 worldTangent = UnityObjectToWorldDir(IN.tangent);
				float3 worldBinormal = cross(normalize(worldNormal), normalize(worldTangent)) * IN.tangent.w;
				// float3 binomal = cross(normalize(IN.normal), normalize(IN.tangent.xyz)) * IN.tangent.w;

				o.TtoW1 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW2 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW3 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);












				//TANGENT_SPACE_ROTATION;  这个宏，等同于下面俩行
				//IN.tangent.w 用来表示副切线的方向。
				// float3 binormal = cross(normalize(IN.normal), normalize(IN.tangent.xyz)) * IN.tangent.w;
				// float3x3 rotation = float3x3(IN.tangent.xyz, binormal, IN.normal);
				
				// o.lightDir = mul(rotation, ObjSpaceLightDir(IN.vertex)).xyz;
				// o.viewDir = mul(rotation, ObjSpaceViewDir(IN.vertex)).xyz;
				return o;
			}

			fixed4 frag(v2f o):SV_Target{
				float3 worldPos = float3(o.TtoW1.w, o.TtoW2.w, o.TtoW3.w);
				// float3 worldNormal = float3(o.TtoW1.z, o.TtoW2.z, o.TtoW3.z);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				// fixed3 tangentLightDir = normalize(o.lightDir);
				// fixed3 tangentViewDir = normalize(o.viewDir);

				fixed3 bump = UnpackNormal(tex2D(_BumpTex, o.uv.zw));

				// fixed4 packedNormal = tex2D(_BumpTex, o.uv.zw); //去法线贴图的法线数据

				// fixed3 tangentNormal;
				// // 如果没有定义texture为Normal Map 需要如下计算
				// //tangentNormal.xy = (packedNormal.xy*2-1)*_BumpScale;
				// //tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				// // 如果定义texture为Normal Map 可以使用
				// tangentNormal = UnpackNormal(packedNormal);
				// tangentNormal.xy *= _BumpScale;
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

				bump = normalize(fixed3(dot(o.TtoW1.xyz, bump), dot(o.TtoW2.xyz, bump), dot(o.TtoW3.xyz, bump)));
				float3 albedo = tex2D(_MainTex, o.uv.xy).xyz * _Color.rgb;  //求反射率
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;  // 环境反射
				float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, worldLightDir));
				float3 halfDir = normalize(worldLightDir + worldViewDir);
				float3 specular = _LightColor0.rgb * _Specular.xyz * pow(saturate(dot(bump, halfDir)), _Glossiness);

				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
