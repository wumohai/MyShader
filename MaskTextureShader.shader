Shader "Custom/MaskTextureShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex", 2D) = "white" {}
		_BumpMap("法线贴图", 2D) = "white" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask("specular tex", 2D) = "white" {}
		_SpecularScale("specular scale",Float) = 1.0
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
	}
	SubShader {
		Pass{
			Tags { "RenderType"="Opaque" 
					"LightMode"="ForwardBase"	
			}
			LOD 200

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			sampler2D _SpecularMask;
			float _BumpScale;
			float _SpecularScale;
			float4 _Specular;
			float _Glossiness;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0; //uv坐标
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};
			
			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir( v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				// 需要L,V,N
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.xy)); //法线贴图的数据
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb; //计算反射率
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo; //环境反射
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed3 specularMask = tex2D(_SpecularMask, i.uv.xy).r * _SpecularScale; //取mask值，一般存在r通道
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Glossiness) * specularMask;
				
				return fixed4(ambient + diffuse + specular, 1.0);

			}

			ENDCG

		}
	}
	FallBack "Diffuse"
}
