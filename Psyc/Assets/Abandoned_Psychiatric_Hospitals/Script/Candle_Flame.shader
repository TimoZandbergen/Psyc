// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AE/Candle_Flame"
{
	Properties
	{
		[HDR]_Textures("Textures", 2D) = "white" {}
		[HDR]_Textures1("Textures", 2D) = "white" {}
		_BrightnessMultiplier("Brightness Multiplier", Range( 0 , 15)) = 2.679832
		_Noise("Noise", 2D) = "white" {}
		_CoreColour("Core Colour", Color) = (0.8962264,0.7863407,0.3677911,0)
		_FlameFlickerSpeed("Flame Flicker Speed", Float) = 0.13
		_OuterColour("Outer Colour", Color) = (0.7924528,0.2913196,0.1756853,0)
		_BaseColour("Base Colour", Color) = (0.1662069,0.2889977,0.7830189,0)
		_NoiseScale("Noise Scale", Float) = 0.44
		_FakeGlow("Fake Glow", Range( 0 , 1)) = 0.3946598
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _BrightnessMultiplier;
		uniform float4 _CoreColour;
		uniform sampler2D _Textures;
		uniform sampler2D _Noise;
		uniform float _FlameFlickerSpeed;
		uniform float _NoiseScale;
		uniform float4 _OuterColour;
		uniform float4 _BaseColour;
		uniform float _FakeGlow;
		uniform sampler2D _Textures1;
		uniform float4 _Textures1_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult31 = (float2(-_FlameFlickerSpeed , -_FlameFlickerSpeed));
			float3 ase_worldPos = i.worldPos;
			float2 appendResult47 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 panner29 = ( 0.37 * _Time.y * appendResult31 + ( ( appendResult47 * 0.1 ) + ( _NoiseScale * i.uv_texcoord ) ));
			float4 tex2DNode1 = tex2D( _Textures, ( i.uv_texcoord + ( i.uv_texcoord.y * ( (tex2D( _Noise, panner29 )).rg - float2( 0,0 ) ) * i.uv_texcoord.x * i.uv_texcoord.y ) ) );
			float2 uv_Textures1 = i.uv_texcoord * _Textures1_ST.xy + _Textures1_ST.zw;
			float4 tex2DNode51 = tex2D( _Textures1, uv_Textures1 );
			o.Emission = ( _BrightnessMultiplier * ( ( _CoreColour * tex2DNode1.r ) + ( _OuterColour * tex2DNode1.g ) + ( _BaseColour * tex2DNode1.b ) + ( _CoreColour * _FakeGlow * tex2DNode51.a ) ) ).rgb;
			o.Alpha = tex2DNode51.a;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
-1920;0;1920;1019;2004.351;973.6451;1.80295;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;46;-3104,-688;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;33;-3052.746,401.9189;Inherit;False;Property;_FlameFlickerSpeed;Flame Flicker Speed;5;0;Create;True;0;0;False;0;0.13;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2672,-384;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;47;-2832,-640;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-3040,-320;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-2965.166,-20.18402;Inherit;False;Property;_NoiseScale;Noise Scale;8;0;Create;True;0;0;False;0;0.44;0.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2528,-608;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2720,-176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;32;-2735.417,401.9189;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-2552.992,391.188;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-2480,-224;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;29;-2234.377,182.2405;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;0.37;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-2005.95,-71.548;Inherit;True;Property;_Noise;Noise;3;0;Create;True;0;0;False;0;-1;3948ecb3ddda0914ab24867c36c4a45c;3948ecb3ddda0914ab24867c36c4a45c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;40;-1673.578,86.61744;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-1429.785,116.2109;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-1712.206,-562.0457;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1242.075,-173.6111;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-996.5994,-323.2394;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;35;-321.2502,-528.7051;Inherit;False;Property;_CoreColour;Core Colour;4;0;Create;True;0;0;False;0;0.8962264,0.7863407,0.3677911,0;0.990566,0.7218781,0.3130561,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-705.5685,-225.1258;Inherit;True;Property;_Textures;Textures;0;1;[HDR];Create;True;0;0;True;0;-1;46a6890955de2584a89222878c285486;46a6890955de2584a89222878c285486;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-483.53,583.1166;Inherit;False;Property;_FakeGlow;Fake Glow;9;0;Create;True;0;0;False;0;0.3946598;0.493;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-705.3356,-14.58394;Inherit;True;Property;_Textures1;Textures;1;1;[HDR];Create;True;0;0;True;0;-1;46a6890955de2584a89222878c285486;46a6890955de2584a89222878c285486;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;36;-339.332,-191.3889;Inherit;False;Property;_OuterColour;Outer Colour;6;0;Create;True;0;0;False;0;0.7924528,0.2913196,0.1756853,0;0.7547169,0.3492121,0.2741187,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;37;-341.1579,287.2897;Inherit;False;Property;_BaseColour;Base Colour;7;0;Create;True;0;0;False;0;0.1662069,0.2889977,0.7830189,0;0.4016107,0.5685437,0.8962264,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-69.25977,304.2461;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-97.26123,547.6517;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-53.94927,-391.6211;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-64.34626,-54.92073;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;218.5188,-181.9688;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;300.9759,-432.9038;Inherit;False;Property;_BrightnessMultiplier;Brightness Multiplier;2;0;Create;True;0;0;False;0;2.679832;3.99;0;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;571.5378,-225.346;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;24;867.5385,-285.0725;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AE/Candle_Flame;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;3;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;47;0;46;1
WireConnection;47;1;46;2
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;34;0;38;0
WireConnection;34;1;30;0
WireConnection;32;0;33;0
WireConnection;31;0;32;0
WireConnection;31;1;32;0
WireConnection;50;0;48;0
WireConnection;50;1;34;0
WireConnection;29;0;50;0
WireConnection;29;2;31;0
WireConnection;28;1;29;0
WireConnection;40;0;28;0
WireConnection;41;0;40;0
WireConnection;43;0;39;2
WireConnection;43;1;41;0
WireConnection;43;2;39;1
WireConnection;43;3;39;2
WireConnection;42;0;39;0
WireConnection;42;1;43;0
WireConnection;1;1;42;0
WireConnection;10;0;37;0
WireConnection;10;1;1;3
WireConnection;45;0;35;0
WireConnection;45;1;44;0
WireConnection;45;2;51;4
WireConnection;6;0;35;0
WireConnection;6;1;1;1
WireConnection;9;0;36;0
WireConnection;9;1;1;2
WireConnection;25;0;6;0
WireConnection;25;1;9;0
WireConnection;25;2;10;0
WireConnection;25;3;45;0
WireConnection;26;0;27;0
WireConnection;26;1;25;0
WireConnection;24;2;26;0
WireConnection;24;9;51;4
ASEEND*/
//CHKSM=F4D56A1C11FE59D897B7A821E4DFF912FD8DE5F1