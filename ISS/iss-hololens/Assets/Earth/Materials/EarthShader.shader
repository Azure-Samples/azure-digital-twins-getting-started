Shader "Planet/PlanetShader"
{
	Properties
	{
		[NoScaleOffset] _MainTex("Day Texture", 2D) = "white" {}
		[NoScaleOffset] _NormalMapTex("Day/Night Normal Map", 2D) = "bump" {}
		[NoScaleOffset] _CloudsTex("Clouds Texture", 2D) = "clear" {}
		[NoScaleOffset] _DetailTex("Detail Texture", 2D) = "black" {}
		[NoScaleOffset] _SpecularTex("Specular Texture", 2D) = "black" {}
		[NoScaleOffset] _NightTex("Night Texture", 2D) = "black" {}
		_DayTintColor("Day Tint Color", Color) = (1,1,1,1)
		_DetailIntensity("Detail Intensity", Range(0, 3)) = 0.0
		_DetailIntensityMin("Detail Intensity Minimum", Range(0, 1)) = 0.01
		_NormalMapIntensity("Normal Map Intensity", Range(0, 1)) = 0.5
		_SpecularPower("Specular Power", Range(0, 1024.0)) = 0.0
		_SpecularIntensity("Specular Intensity", Range(0.0, 10.0)) = 2.0
		_CloudIntensityMin("Cloud Intensity Mininmum", Range(0.0, 1.0)) = 0.01
		_NightIntensity("Night Detail Intensity", Range(0, 1)) = 0.0
		_NightTransitionVariable("Night Transition Variable", Range(1, 64)) = 4
		_Smoothness("Smoothness", Range(0,1)) = 0.5
		_RimColor("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower("Rim Power", Range(0.5, 64.0)) = 3.0
		_RimIntensity("Rim Intensity", Range(0.0, 100.0)) = 2.0
		_AtmosNear("Atmosphere Near Color", Color) = (0.1686275,0.7372549,1,1)
		_AtmosFar("Atmosphere Far Color", Color) = (0.4557808,0.5187039,0.9850746,1)
		_AtmosFalloff("Atmosphere Falloff", Range(0.1, 64)) = 12
		_SunDir("Sun Dir", Vector) = (0.2, 0.3, 0.4, 0.0)
		_SunColor("Sun Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		Tags { "Queue"="Geometry" }

		Pass
		{
			CGPROGRAM

			#pragma target 3.5
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			#define DO_ALPHA_BLEND(f, b) ((f.rgb * f.a) + (b.rgb * (1.0 - f.a)))

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 rayDir : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform sampler2D _NormalMapTex;
			uniform sampler2D _CloudsTex;
			uniform sampler2D _DetailTex;
			uniform sampler2D _SpecularTex;
			uniform sampler2D _NightTex;

			uniform fixed4 _DayTintColor;
			uniform fixed _Smoothness;
			uniform fixed _DetailIntensity;
			uniform fixed _SpecularPower;
			uniform fixed _SpecularIntensity;
			uniform fixed _NightIntensity;
			uniform fixed _NightTransitionVariable;
			uniform fixed4 _RimColor;
			uniform fixed _RimPower;
			uniform fixed _RimIntensity;
			uniform fixed4 _AtmosNear;
			uniform fixed4 _AtmosFar;
			uniform fixed _AtmosFalloff;
			uniform fixed _CloudIntensityMin;
			uniform fixed _DetailIntensityMin;
			uniform fixed _NormalMapIntensity;

			uniform fixed3 _SunDir;
			uniform fixed4 _SunColor;

			static const float3 forwardVector = mul((float3x3)unity_CameraToWorld, float3(0, 0, 1));
			static const float3 sunColor = _SunColor.rgb * _SunColor.a;
			static const float3 sunDir = normalize(_SunDir);

			inline float3 WorldSpaceVertexPos(float4 vertex)
			{
				return mul(unity_ObjectToWorld, vertex).xyz;
			}

			inline float3 WorldSpaceNormal(float3 normal)
			{
				return mul((float3x3)unity_ObjectToWorld, normal);
			}

			inline fixed3 AtmosphereColor(float3 worldSpaceDir)
			{
				fixed3 Fresnel1 = forwardVector;
				fixed3 Fresnel2 = (1.0 - dot(normalize(worldSpaceDir), normalize(Fresnel1))).xxx;
				fixed3 Pow0 = pow(Fresnel2, _AtmosFalloff);
				fixed3 Saturate0 = saturate(Pow0);
				fixed3 Lerp0 = lerp(_AtmosNear, _AtmosFar, Saturate0);
				fixed3 color = Lerp0 * Saturate0;
				return color;
			}
			
			v2f vert (appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				DEFAULT_UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;// TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = WorldSpaceNormal(v.normal);
				o.rayDir = _WorldSpaceCameraPos - WorldSpaceVertexPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				
				fixed4 result;
				UNITY_INITIALIZE_OUTPUT(fixed4, result);
				DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i,result);				
				
				float3 rayDir = normalize(i.rayDir);
				fixed4 dayColor = tex2D(_MainTex, i.uv) * _DayTintColor;
				fixed4 clouds = tex2D(_CloudsTex, i.uv);
				
				fixed3 nightColor = tex2D(_NightTex, i.uv).rgb;
				fixed maxNight = min(1, nightColor.g + 0.8);
				nightColor *= pow(maxNight, 4.0);
				fixed4 detailColor = tex2D(_DetailTex, i.uv);
				detailColor.rgb *= _DetailIntensity;
				float3 worldNormal = normalize(i.normal);
				float3 normalMapNormal = (float4(UnpackNormal(tex2D(_NormalMapTex, i.uv)), 1.0)).xyz;
				float3 worldNormalMapped = normalize(worldNormal + (normalMapNormal.xxy * _NormalMapIntensity * float3(-1.0, 1.0, -1.0)));

				fixed specular = tex2D(_SpecularTex, i.uv).a;
				float smooth = _Smoothness;
				fixed rim = 1.0 - max(0.0, dot(rayDir, worldNormal));
				fixed3 emission = (_RimColor.rgb * pow(rim, _RimPower) + AtmosphereColor(-rayDir));

				fixed3 h = normalize(_SunDir + rayDir);
				fixed d = max(0.0, dot(worldNormal, _SunDir));
				fixed e = max(0.0, dot(worldNormalMapped, _SunDir));
				fixed nh = max(0.0, dot(worldNormalMapped, h));
				fixed specTerm = pow(nh, _SpecularPower) * _Smoothness;

				fixed3 sunIntensity = sunColor * d;
				fixed3 dayColorSpec = (dayColor * sunIntensity * e) + (sunColor * specular * specTerm * _SpecularIntensity * e);
				fixed4 cloudsLit = fixed4(clouds.rgb * max(_CloudIntensityMin, sunIntensity), clouds.a);
				fixed4 detailLit = fixed4(detailColor * max(_DetailIntensityMin, sunIntensity), detailColor.a);

				result.a = 1.0;
				result.rgb = lerp(nightColor, dayColorSpec, saturate(_NightTransitionVariable * d));
				result.rgb += (detailLit.rgb * detailLit.a);
				result.rgb += (cloudsLit.rgb * cloudsLit.a);// DO_ALPHA_BLEND(cloudsLit, result);
				result.rgb += (emission.rgb * _RimIntensity * nh);
				return result;
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
