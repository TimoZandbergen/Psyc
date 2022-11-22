// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TriForge/Winter Forest/Standard Snow"
{
	Properties
	{
		[Enum(Off,0,Front,1,Back,2)]_CullMode("Cull Mode", Int) = 2
		_BaseColor("Base Color", 2D) = "white" {}
		[Normal]_Normal("Normal", 2D) = "bump" {}
		_AmbientOcclusionG("Ambient Occlusion (G)", 2D) = "white" {}
		[Toggle(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)] _SmoothnessinAlbedoAlpha("Smoothness in Albedo Alpha", Float) = 0
		_MetallicRSmoothnessA("Metallic (R), Smoothness (A)", 2D) = "black" {}
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_SnowNormal("Snow Normal", 2D) = "bump" {}
		_SnowAlbedo("Snow Albedo", 2D) = "white" {}
		_SnowAmount("SnowAmount", Range( 0 , 2)) = 1.132492
		_SnowMaskSharpness("Snow Mask Sharpness", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull [_CullMode]
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform int _CullMode;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		sampler2D _SnowNormal;
		uniform float _SnowAmount;
		uniform float TFW_SnowAmount;
		uniform sampler2D _BaseColor;
		uniform float4 _BaseColor_ST;
		sampler2D _SnowAlbedo;
		uniform float _SnowMaskSharpness;
		uniform sampler2D _MetallicRSmoothnessA;
		uniform float4 _MetallicRSmoothnessA_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform sampler2D _AmbientOcclusionG;
		uniform float4 _AmbientOcclusionG_ST;


		inline float3 TriplanarSampling102( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackNormal( xNorm ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackNormal( yNorm ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSampling101( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 Normal12 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 _Vector0 = float2(2,2);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float4 ase_vertexTangent = mul( unity_WorldToObject, float4( ase_worldTangent, 0 ) );
			float3 ase_vertexBitangent = mul( unity_WorldToObject, float4( ase_worldBitangent, 0 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3x3 objectToTangent = float3x3(ase_vertexTangent.xyz, ase_vertexBitangent, ase_vertexNormal);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 triplanar102 = TriplanarSampling102( _SnowNormal, ase_vertex3Pos, ase_vertexNormal, 1.0, _Vector0, 1.0, 0 );
			float3 tanTriplanarNormal102 = mul( objectToTangent, triplanar102 );
			float3 SnowNormal14 = tanTriplanarNormal102;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float saferPower145 = max( ase_normWorldNormal.y , 0.0001 );
			float temp_output_143_0 = ( _SnowAmount * TFW_SnowAmount );
			float3 lerpResult21 = lerp( Normal12 , SnowNormal14 , saturate( ( pow( saferPower145 , 3.0 ) * temp_output_143_0 ) ));
			float3 NormalBlend29 = lerpResult21;
			o.Normal = NormalBlend29;
			float2 uv_BaseColor = i.uv_texcoord * _BaseColor_ST.xy + _BaseColor_ST.zw;
			float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
			float4 BaseColor27 = tex2DNode1;
			float4 triplanar101 = TriplanarSampling101( _SnowAlbedo, ase_vertex3Pos, ase_vertexNormal, 1.0, _Vector0, 1.0, 0 );
			float4 SnowColor28 = triplanar101;
			float saferPower82 = max( ( (WorldNormalVector( i , lerpResult21 )).y * temp_output_143_0 ) , 0.0001 );
			float SnowBlendMask25 = saturate( pow( saferPower82 , _SnowMaskSharpness ) );
			float4 lerpResult34 = lerp( BaseColor27 , SnowColor28 , SnowBlendMask25);
			float4 ColorBlend36 = lerpResult34;
			o.Albedo = ColorBlend36.xyz;
			float2 uv_MetallicRSmoothnessA = i.uv_texcoord * _MetallicRSmoothnessA_ST.xy + _MetallicRSmoothnessA_ST.zw;
			float4 tex2DNode4 = tex2D( _MetallicRSmoothnessA, uv_MetallicRSmoothnessA );
			float BaseMetallic49 = tex2DNode4.r;
			float lerpResult63 = lerp( ( BaseMetallic49 * _Metallic ) , 0.0 , SnowBlendMask25);
			float MetallicBlend66 = lerpResult63;
			o.Metallic = MetallicBlend66;
			#ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
				float staticSwitch142 = tex2DNode1.a;
			#else
				float staticSwitch142 = tex2DNode4.a;
			#endif
			float BaseSmoothness48 = staticSwitch142;
			float SnowSmoothness52 = triplanar101.w;
			float lerpResult55 = lerp( BaseSmoothness48 , SnowSmoothness52 , SnowBlendMask25);
			float SmoothnessBlend56 = ( lerpResult55 * _Smoothness );
			o.Smoothness = SmoothnessBlend56;
			float2 uv_AmbientOcclusionG = i.uv_texcoord * _AmbientOcclusionG_ST.xy + _AmbientOcclusionG_ST.zw;
			float AmbientOcclusion39 = tex2D( _AmbientOcclusionG, uv_AmbientOcclusionG ).g;
			float lerpResult44 = lerp( AmbientOcclusion39 , 1.0 , SnowBlendMask25);
			float AmbientOcclusionBlend46 = lerpResult44;
			o.Occlusion = AmbientOcclusionBlend46;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
2117;110;1497;849;5704.384;1407.088;3.229654;True;False
Node;AmplifyShaderEditor.CommentaryNode;26;-4202.93,288.3282;Inherit;False;2475.182;591.0767;Snow Blend Mask;14;25;24;23;22;18;41;17;16;19;82;83;143;144;145;Snow Blend Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;125;-4441.272,-439.0634;Inherit;False;Constant;_Vector0;Vector 0;16;0;Create;True;0;0;0;False;0;False;2,2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;16;-4180.487,586.9673;Float;False;Property;_SnowAmount;SnowAmount;11;0;Create;True;0;0;0;False;0;False;1.132492;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-4178.666,712.454;Inherit;False;Global;TFW_SnowAmount;TFW_SnowAmount;22;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-4186.711,-735.3622;Inherit;False;703.2526;741.2087;;5;101;28;52;14;102;Snow Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;50;-4153.494,-1862.002;Inherit;False;675.7842;954.942;;8;1;4;5;2;27;39;12;49;Base Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;19;-4163.289,330.8271;Inherit;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;2;-4103.493,-1586.665;Inherit;True;Property;_Normal;Normal;3;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;5dc2895d0bd823c43b984aebe2652681;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;145;-3940.894,371.4873;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;102;-4146.867,-451.2142;Inherit;True;Spherical;Object;True;Snow Normal;_SnowNormal;bump;9;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Snow Normal;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-3868.567,633.754;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-3720.429,-417.7517;Inherit;False;SnowNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-3739.162,-1532.429;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-3760.217,371.6787;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;-3633.139,603.7239;Inherit;False;776.3894;249.6649;Comment;4;29;21;15;13;Normal Blend;0.4980392,0.4980392,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-3583.139,738.389;Inherit;False;14;SnowNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;18;-3518.021,422.1146;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-3557.454,653.724;Inherit;False;12;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;21;-3329.316,684.7312;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;22;-3350.693,333.3781;Inherit;True;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-3050.788,365.4518;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-2730.882,660.2123;Inherit;False;Property;_SnowMaskSharpness;Snow Mask Sharpness;12;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;82;-2434.581,367.7333;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-4103.061,-1812.002;Inherit;True;Property;_BaseColor;Base Color;2;0;Create;True;0;0;0;False;0;False;-1;None;dce506e5e22004944a0cbe16380bfcd9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-4101.755,-1369.287;Inherit;True;Property;_MetallicRSmoothnessA;Metallic (R), Smoothness (A);6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;142;-3425.261,-1479.476;Inherit;False;Property;_SmoothnessinAlbedoAlpha;Smoothness in Albedo Alpha;5;0;Create;True;0;0;0;False;0;False;0;0;1;True;_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A;Toggle;2;MetallicAlpha;AlbedoAlpha;Create;True;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;-2132.678,398.0089;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;101;-4154.089,-673.7489;Inherit;True;Spherical;Object;False;Snow Albedo;_SnowAlbedo;white;10;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Snow Albedo;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;67;-1652.011,-897.355;Inherit;False;1043.409;340.8411;;6;65;60;64;62;63;66;Metallic Blend;0.746717,0.4575472,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-3009.653,-1480.052;Inherit;False;BaseSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;-1672.523,-1494.717;Inherit;False;1107.523;454.8398;;7;51;54;53;55;58;57;56;Smoothness Blend;1,0.6687184,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1979.209,393.7239;Inherit;False;SnowBlendMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-4096.641,-1137.06;Inherit;True;Property;_AmbientOcclusionG;Ambient Occlusion (G);4;0;Create;True;0;0;0;False;0;False;-1;None;05662dba608e7484492efb4f03998430;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-3727.625,-551.7147;Inherit;False;SnowSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-3740.229,-1327.5;Inherit;False;BaseMetallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-1619.354,-1342.138;Inherit;False;52;SnowSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-1622.523,-1444.717;Inherit;False;48;BaseSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-3740.502,-1772.402;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1663.414,-2393.559;Inherit;False;799.6422;379.26;;5;34;31;32;35;36;Albedo Blending;1,0.2783019,0.2783019,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-1565.125,-847.355;Inherit;False;49;BaseMetallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-3744.708,-1056.963;Inherit;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-3724.138,-660.7105;Inherit;False;SnowColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;47;-1665.647,-1897.042;Inherit;False;862.6722;281.9524;;4;43;44;42;46;AO Blending;0,1,0.9374714,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1602.011,-762.515;Inherit;False;Property;_Metallic;Metallic;7;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-1619.354,-1214.876;Inherit;False;25;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1554.956,-671.514;Inherit;False;25;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;55;-1285.025,-1371.434;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-1579.309,-2343.559;Inherit;False;27;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-1613.414,-2129.3;Inherit;False;25;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-1582.304,-2239.452;Inherit;False;28;SnowColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-1608.701,-1730.09;Inherit;False;25;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1335.409,-1154.877;Inherit;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1286.11,-777.6509;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1615.647,-1847.042;Inherit;False;39;AmbientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;44;-1320.375,-1799.568;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-1099.627,-772.072;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;34;-1326.414,-2303.299;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1014.508,-1287.013;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-1105.975,-1803.551;Inherit;False;AmbientOcclusionBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-833.9996,-1292.912;Inherit;False;SmoothnessBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-877.6019,-776.55;Inherit;False;MetallicBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-3099.749,679.6394;Inherit;False;NormalBlend;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1106.771,-2307.842;Inherit;False;ColorBlend;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-486.4209,275.6694;Inherit;False;46;AmbientOcclusionBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-412.866,-64.36407;Inherit;False;36;ColorBlend;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-426.4209,101.6694;Inherit;False;66;MetallicBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-451.4209,184.6694;Inherit;False;56;SmoothnessBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;3;-1.129985,-107.429;Inherit;False;Property;_CullMode;Cull Mode;0;1;[Enum];Create;True;0;3;Off;0;Front;1;Back;2;0;True;0;False;2;2;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-426.2854,16.12247;Inherit;False;29;NormalBlend;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TriForge/Winter Forest/Standard Snow;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;12;2;8;False;0;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;True;3;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;145;0;19;2
WireConnection;102;3;125;0
WireConnection;143;0;16;0
WireConnection;143;1;144;0
WireConnection;14;0;102;0
WireConnection;12;0;2;0
WireConnection;17;0;145;0
WireConnection;17;1;143;0
WireConnection;18;0;17;0
WireConnection;21;0;13;0
WireConnection;21;1;15;0
WireConnection;21;2;18;0
WireConnection;22;0;21;0
WireConnection;23;0;22;2
WireConnection;23;1;143;0
WireConnection;82;0;23;0
WireConnection;82;1;83;0
WireConnection;142;1;4;4
WireConnection;142;0;1;4
WireConnection;24;0;82;0
WireConnection;101;3;125;0
WireConnection;48;0;142;0
WireConnection;25;0;24;0
WireConnection;52;0;101;4
WireConnection;49;0;4;1
WireConnection;27;0;1;0
WireConnection;39;0;5;2
WireConnection;28;0;101;0
WireConnection;55;0;51;0
WireConnection;55;1;54;0
WireConnection;55;2;53;0
WireConnection;65;0;60;0
WireConnection;65;1;64;0
WireConnection;44;0;43;0
WireConnection;44;2;42;0
WireConnection;63;0;65;0
WireConnection;63;2;62;0
WireConnection;34;0;31;0
WireConnection;34;1;32;0
WireConnection;34;2;35;0
WireConnection;57;0;55;0
WireConnection;57;1;58;0
WireConnection;46;0;44;0
WireConnection;56;0;57;0
WireConnection;66;0;63;0
WireConnection;29;0;21;0
WireConnection;36;0;34;0
WireConnection;0;0;37;0
WireConnection;0;1;30;0
WireConnection;0;3;70;0
WireConnection;0;4;68;0
WireConnection;0;5;69;0
ASEEND*/
//CHKSM=CD2DA93C338F1A04203E15D241F9B0C1BAC5BD60