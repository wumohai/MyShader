Shader "Custom/GlassRefraction" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpTex("Bump tex", 2D) = "white" {}
		_CubeMap("Cube Map", Cube) = "_Skeybox" {}
		_RefractAmount("Refact Amount", Range(0,1)) = 1
		_Distortion("Distortion", Range(1,100)) = 10

	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Transparent" }
		GrabPass{ "_RefractionTex"}
		Pass{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			samplerCUBE _CubeMap;
			fixed _RefractAmount;
			fixed _Distortion;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
				float4 scrPos:TEXCOORD4;
			};
			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.scrPos = ComputeGrabScreenPos(o.pos);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);
				fixed4 worldPos = mul(_Object2World, v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 binamal = cross(worldNormal, worldTangent) * v.tangent.w;
				o.TtoW0 = float4(worldTangent.x, binamal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, binamal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, binamal.z, worldNormal.z, worldPos.z);
				return o;
			}
			fixed4 frag(v2f i):SV_Target{
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				float3 bump = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refractColor = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
				//求世界空间下法线贴图的法线
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				fixed3 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflction = reflect(-viewDir, bump);
				fixed3 reflctColor = texCUBE(_CubeMap, reflction).rgb * texColor.rgb;
				fixed3 color = reflctColor*(1-_RefractAmount) + refractColor * _RefractAmount;
				return fixed4(color, 1);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
