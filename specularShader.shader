// 逐顶点漫反射光照模型
Shader "Custom/specularShader" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass {
			// 指明该Pass光照模式 以获取内置光照变量_LightColor0
			Tags { "LightMode" = "ForwardBase" }

			// CG代码块
			CGPROGRAM

			// 定义着色器
			#pragma vertex vert
			#pragma fragment frag

			// 为了使用_LightColor0需要引用支持库
			#include "Lighting.cginc"

			// 内部使用变量
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			// 定义顶点着色器的输入和输出结构体
			// 输出结构体同时也是片元找色器的输入结构体
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			// 顶点着色器实现
			v2f vert(a2v v) {
				// 新建输出变量
				v2f o;

				// 将顶点从模型坐标系转换到剪裁坐标系
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldNormal = mul(v.normal, (float3x3)_World2Object);
				o.worldPos = mul(_Object2World, v.vertex).xyz;

				// 输出
				return o;
			}

			// 片元着色器实现
			fixed4 frag(v2f i) : SV_Target {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

				fixed3 specular = _LightColor0.rgb * _Specular.xyz * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

				fixed3 color = ambient + diffuse + specular;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}