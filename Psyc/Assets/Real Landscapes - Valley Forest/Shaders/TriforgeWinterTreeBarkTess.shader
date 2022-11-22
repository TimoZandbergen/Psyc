// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TriForge/Winter Forest/Bark - Tesselation"
{
	Properties
	{
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 8
		_TessMin( "Tess Min Distance", Float ) = 3
		_TessMax( "Tess Max Distance", Float ) = 6
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 1
		_WindStrength("Wind Strength", Range( 0 , 2)) = 0.3
		_WindNoiseScale("Wind Noise Scale", Float) = 1
		_WindSpeed("Wind Speed", Range( 0 , 5)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Albedo("Albedo", 2D) = "white" {}
		_TessellationSeamOffset("Tessellation Seam Offset", Range( -2 , 2)) = 0
		_HeightMin("Height Min", Range( -2 , 2)) = 0
		_HeightMax("Height Max", Range( -2 , 2)) = 0
		_DisplacementStrength("Displacement Strength", Float) = 1
		_TessellationSeamMask("Tessellation Seam Mask", Range( 0.1 , 5)) = 3
		_Normal("Normal", 2D) = "bump" {}
		_Mask("Ambient Occlusion (G), Smoothness (A)", 2D) = "white" {}
		_SnowAmount("Snow Amount", Range( 0 , 2)) = 0
		_SnowMaskSharpness("Snow Mask Sharpness", Range( 0 , 3)) = 1
		_SnowSmoothness("Snow Smoothness", Range( 0 , 1)) = 1
		_SnowAlbedo("Albedo", 2D) = "white" {}
		_SnowNormal("Normal", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "DisableBatching" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		uniform float TFW_WindStrength;
		uniform int TFW_EnableWind;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _HeightMin;
		uniform float _HeightMax;
		uniform float _TessellationSeamOffset;
		uniform float _TessellationSeamMask;
		uniform float _DisplacementStrength;
		uniform float3 TFW_WindDirection;
		uniform float TFW_DirectionRandomness;
		uniform float _WindSpeed;
		uniform float TFW_WindSpeed;
		uniform float _WindNoiseScale;
		uniform float _WindStrength;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _SnowNormal;
		uniform float4 _SnowNormal_ST;
		uniform float _SnowAmount;
		uniform float TFW_SnowAmount;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _SnowAlbedo;
		uniform float4 _SnowAlbedo_ST;
		uniform float _SnowMaskSharpness;
		uniform float _Smoothness;
		uniform float _SnowSmoothness;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;
		uniform float _TessPhongStrength;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		inline float3 TriplanarSampling289( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		inline float4 TriplanarSampling301( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_Mask = v.texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode106 = tex2Dlod( _Mask, float4( uv_Mask, 0, 0.0) );
			float Height262 = (_HeightMin + (tex2DNode106.a - 0.0) * (_HeightMax - _HeightMin) / (1.0 - 0.0));
			float saferPower155 = max( v.color.b , 0.0001 );
			float lerpResult153 = lerp( Height262 , _TessellationSeamOffset , pow( saferPower155 , _TessellationSeamMask ));
			float3 ase_vertexNormal = v.normal.xyz;
			float3 HeightDisplacement169 = ( ( ( lerpResult153 * _DisplacementStrength ) * ase_vertexNormal ) * ( 1.0 - v.color.g ) );
			float ifLocalVar109_g1 = 0;
			if( abs( TFW_WindDirection.x ) > 0.0 )
				ifLocalVar109_g1 = 1.0;
			else if( abs( TFW_WindDirection.x ) == 0.0 )
				ifLocalVar109_g1 = 0.0;
			float ifLocalVar110_g1 = 0;
			if( abs( TFW_WindDirection.z ) > 0.0 )
				ifLocalVar110_g1 = 0.0;
			float ifLocalVar112_g1 = 0;
			if( ifLocalVar109_g1 == ifLocalVar110_g1 )
				ifLocalVar112_g1 = 1.0;
			float3 lerpResult123_g1 = lerp( TFW_WindDirection , float3(1,0,0) , ifLocalVar112_g1);
			float3 worldToObjDir38_g1 = normalize( mul( unity_WorldToObject, float4( lerpResult123_g1, 0 ) ).xyz );
			float3 lerpResult39_g1 = lerp( worldToObjDir38_g1 , TFW_WindDirection , TFW_DirectionRandomness);
			float3 WindDirection41_g1 = lerpResult39_g1;
			float WindSpeed19_g1 = ( _WindSpeed * TFW_WindSpeed );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 transform2_g1 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float2 WorldSpaceUv9_g1 = (( transform2_g1 / ( -100.0 * ( 1.0 * _WindNoiseScale ) ) )).xz;
			float2 uv2_TexCoord12_g1 = v.texcoord1.xy * float2( 0,0 ) + WorldSpaceUv9_g1;
			float2 temp_cast_1 = (uv2_TexCoord12_g1.x).xx;
			float2 panner13_g1 = ( 1.0 * _Time.y * ( float2( 0.12,0 ) * WindSpeed19_g1 ) + temp_cast_1);
			float simplePerlin3D11_g1 = snoise( float3( panner13_g1 ,  0.0 )*0.5 );
			float MainWindBending86_g1 = simplePerlin3D11_g1;
			float WindRotation32_g1 = radians( ( ( (-0.6 + (MainWindBending86_g1 - -1.0) * (1.0 - -0.6) / (1.0 - -1.0)) * TFW_WindStrength ) * 25.0 ) );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 rotatedValue42_g1 = RotateAroundAxis( float3( 0,0,0 ), ase_vertex3Pos, WindDirection41_g1, WindRotation32_g1 );
			float3 MainWind168 = ( ( saturate( pow( v.texcoord1.xy.y , 2.34 ) ) * ( ( rotatedValue42_g1 - ase_vertex3Pos ) * TFW_EnableWind ) ) * _WindStrength );
			v.vertex.xyz += ( HeightDisplacement169 + MainWind168 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 NormalMap163 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_SnowNormal = i.uv_texcoord * _SnowNormal_ST.xy + _SnowNormal_ST.zw;
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
			float3 triplanar289 = TriplanarSampling289( _SnowNormal, ase_vertex3Pos, ase_vertexNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float3 tanTriplanarNormal289 = mul( objectToTangent, triplanar289 );
			float3 lerpResult292 = lerp( UnpackNormal( tex2D( _SnowNormal, uv_SnowNormal ) ) , tanTriplanarNormal289 , i.vertexColor.r);
			float3 SnowNormal295 = lerpResult292;
			float temp_output_328_0 = ( _SnowAmount * TFW_SnowAmount );
			float3 lerpResult185 = lerp( NormalMap163 , SnowNormal295 , saturate( ( ase_worldNormal.y * temp_output_328_0 ) ));
			float3 NormalBlend186 = lerpResult185;
			o.Normal = NormalBlend186;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo162 = tex2D( _Albedo, uv_Albedo );
			float2 uv_SnowAlbedo = i.uv_texcoord * _SnowAlbedo_ST.xy + _SnowAlbedo_ST.zw;
			float4 tex2DNode300 = tex2D( _SnowAlbedo, uv_SnowAlbedo );
			float4 triplanar301 = TriplanarSampling301( _SnowAlbedo, ase_vertex3Pos, ase_vertexNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float4 lerpResult305 = lerp( tex2DNode300 , triplanar301 , i.vertexColor.r);
			float4 SnowAlbedo307 = lerpResult305;
			float saferPower189 = max( ( (WorldNormalVector( i , lerpResult185 )).y * temp_output_328_0 ) , 0.0001 );
			float SnowBlendMask192 = saturate( pow( saferPower189 , _SnowMaskSharpness ) );
			float4 lerpResult197 = lerp( Albedo162 , SnowAlbedo307 , SnowBlendMask192);
			float4 FinalAlbedo200 = lerpResult197;
			o.Albedo = FinalAlbedo200.xyz;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode106 = tex2D( _Mask, uv_Mask );
			float Smoothness167 = ( tex2DNode106.r * _Smoothness );
			float lerpResult303 = lerp( tex2DNode300.a , triplanar301.a , i.vertexColor.r);
			float SnowSmoothness306 = ( lerpResult303 * _SnowSmoothness );
			float lerpResult207 = lerp( Smoothness167 , SnowSmoothness306 , SnowBlendMask192);
			float FinalSmoothness208 = lerpResult207;
			o.Smoothness = FinalSmoothness208;
			float AmbientOcclusion165 = tex2DNode106.g;
			float lerpResult209 = lerp( AmbientOcclusion165 , 1.0 , SnowBlendMask192);
			float FinalAmbientOcclusion213 = lerpResult209;
			o.Occlusion = FinalAmbientOcclusion213;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows noinstancing vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				half4 color : COLOR0;
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
				vertexDataFunc( v );
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
				o.color = v.color;
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
				surfIN.vertexColor = IN.color;
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
Version=18912
99;268;1135;556;4903.269;-1720.683;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;288;-4599.986,-2685.003;Inherit;False;1457.155;1212.136;Comment;17;307;306;305;304;303;302;301;300;298;297;296;295;294;292;291;290;289;Snow Texture Samples;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;287;-4988.647,-2369.614;Inherit;True;Property;_SnowNormal;Normal;22;0;Create;False;0;0;0;False;0;False;4e715636e6257c94cb6fd33252d71d96;4e715636e6257c94cb6fd33252d71d96;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;256;-4598.84,-951.8959;Inherit;False;2135.386;650.1171;;16;188;190;189;191;192;181;179;180;182;184;183;185;187;186;328;329;Snow Mask;0,0.7479331,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;291;-4477.802,-2258.248;Inherit;True;Property;_TextureSample0;Texture Sample 0;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;290;-4136.962,-1663.984;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;259;-4622.242,-4170.208;Inherit;False;1028.122;932.8509;Comment;13;165;107;261;167;162;104;106;163;105;136;135;134;262;Base Texture Samples;1,1,1,1;0;0
Node;AmplifyShaderEditor.TriplanarNode;289;-4550.254,-2058.241;Inherit;True;Spherical;Object;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;329;-4572.939,-582.1065;Inherit;False;Global;TFW_SnowAmount;TFW_SnowAmount;22;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-4573.64,-671.1937;Inherit;False;Property;_SnowAmount;Snow Amount;17;0;Create;True;0;0;0;False;0;False;0;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;105;-4570.769,-3927.294;Inherit;True;Property;_Normal;Normal;15;0;Create;True;0;0;0;False;0;False;-1;None;6d9b9deea7f784244ab98ce4d54c74c6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;292;-3878.841,-2123.73;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;328;-4272.739,-635.9068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;179;-4373.327,-898.77;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-4187.764,-3926.642;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-3370.708,-2107.235;Inherit;False;SnowNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-4172.24,-836.994;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-4472.47,-3463.323;Inherit;False;Property;_HeightMin;Height Min;11;0;Create;True;0;0;0;False;0;False;0;-0.48;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;182;-4016.64,-812.7941;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-4206.841,-400.1939;Inherit;False;295;SnowNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-4201.841,-483.194;Inherit;False;163;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-4471.71,-3373.042;Inherit;False;Property;_HeightMax;Height Max;12;0;Create;True;0;0;0;False;0;False;0;0.61;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;-4572.242,-3734.381;Inherit;True;Property;_Mask;Ambient Occlusion (G), Smoothness (A);16;0;Create;False;0;0;0;False;0;False;-1;None;5fa5536d48a84fc468048f6424e1a401;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;185;-3917.842,-586.1939;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;160;-4565.101,1263.053;Inherit;False;1889.651;1137.943;;7;39;38;77;6;33;168;327;Main Wind;0.7133185,0.4198113,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;134;-4134.675,-3545.3;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;159;-4616.706,109.8076;Inherit;False;2036.89;887.5413;;13;152;151;112;130;144;145;153;158;155;141;156;169;263;Height Displacement;1,0.4621924,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-3970.262,1374.094;Inherit;False;867.5936;526.5638;;5;37;36;68;69;70;Mask Wind by UV2;1,0.5394964,0,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;299;-5003.667,-2591.816;Inherit;True;Property;_SnowAlbedo;Albedo;20;0;Create;False;0;0;0;False;0;False;435a7ca9c9529ca4e83d0ce5190db3b2;435a7ca9c9529ca4e83d0ce5190db3b2;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-3810.885,-3550.796;Inherit;False;Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;141;-4438.179,651.1544;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;-4456.938,511.4356;Inherit;False;Property;_TessellationSeamMask;Tessellation Seam Mask;14;0;Create;True;0;0;0;False;0;False;3;2;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;187;-3729.856,-818.0186;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;155;-4159.938,526.4355;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3715.033,1586.783;Inherit;False;Constant;_Float7;Float 7;3;0;Create;True;0;0;0;False;0;False;2.34;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-3390.456,-416.78;Inherit;False;Property;_SnowMaskSharpness;Snow Mask Sharpness;18;0;Create;True;0;0;0;False;0;False;1;1.4;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;300;-4483.429,-2646.338;Inherit;True;Property;_TextureSample1;Texture Sample 1;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;158;-4291.626,411.9056;Inherit;False;Property;_TessellationSeamOffset;Tessellation Seam Offset;10;0;Create;True;0;0;0;False;0;False;0;0.03;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3947.742,1424.264;Inherit;True;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-3372.842,-674.1938;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-4197.486,319.7635;Inherit;False;262;Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;301;-4561.826,-2451.42;Inherit;True;Spherical;Object;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;-3967.488,505.2867;Inherit;False;Property;_DisplacementStrength;Displacement Strength;13;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;153;-3974.058,377.9586;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;303;-3878.708,-2389.033;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;302;-3657.637,-2319.721;Inherit;False;Property;_SnowSmoothness;Snow Smoothness;19;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;189;-3088.455,-562.78;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;68;-3676.366,1442.617;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-4515.101,1962.715;Inherit;False;Property;_WindSpeed;Wind Speed;7;0;Create;True;0;0;0;False;0;False;1;2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-4140.861,-3804.905;Inherit;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-4436.221,2089.424;Inherit;False;Property;_WindNoiseScale;Wind Noise Scale;6;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;130;-3679.211,535.8795;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-4007.365,-3714.788;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-3701.007,333.2616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;327;-3800.039,1952.335;Inherit;False;TriforgeTreeWind;-1;;1;02c5e277b3e957a46ade320788361410;0;2;10;FLOAT;1;False;7;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;70;-3513.267,1445.886;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;104;-4572.241,-4120.208;Inherit;True;Property;_Albedo;Albedo;9;0;Create;True;0;0;0;False;0;False;-1;None;d5b7654fc7bfb8f46adb980175d48b8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;191;-2899.455,-561.78;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;305;-3878.022,-2609.748;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;-3594.389,-2444.523;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;260;-1494.774,-1952.608;Inherit;False;950.523;1122.911;Comment;15;204;206;203;211;207;199;194;210;193;212;209;197;208;213;200;Snow Mask Blends;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-4199.764,-4118.642;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-3418.487,406.8286;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;-3833.13,-3680.769;Inherit;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;151;-3370.774,698.5234;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;-3412.583,-2615.988;Inherit;False;SnowAlbedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-2719.455,-566.78;Inherit;False;SnowBlendMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-3817.764,-3826.641;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-3317.908,2025.086;Inherit;False;Property;_WindStrength;Wind Strength;5;0;Create;True;0;0;0;False;0;False;0.3;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-3324.725,1435.79;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;306;-3422.96,-2447.836;Inherit;False;SnowSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-3162.143,537.3275;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-1404.348,-1809.608;Inherit;False;307;SnowAlbedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-1344.5,-1032.697;Inherit;False;Constant;_Float0;Float 0;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1412.774,-1530.337;Inherit;False;167;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-1427.839,-1706.244;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-1379.348,-1902.608;Inherit;False;162;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-1438.5,-1112.697;Inherit;False;165;AmbientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-1443.774,-1432.337;Inherit;False;306;SnowSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-3047.297,1866.667;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;-1424.5,-944.6971;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-1435.251,-1334.897;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-2890.083,1862.604;Inherit;False;MainWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;207;-1086.251,-1467.896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-2974.849,531.8995;Inherit;False;HeightDisplacement;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;197;-1152.839,-1854.244;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;209;-1156.251,-1065.896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-618.6884,805.8328;Inherit;False;168;MainWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-3716.715,-438.1294;Inherit;False;NormalBlend;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-808.2516,-1469.896;Inherit;False;FinalSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-955.9055,-1857.405;Inherit;False;FinalAlbedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;-960.5005,-1072.697;Inherit;False;FinalAmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-755.4582,642.9203;Inherit;False;169;HeightDisplacement;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;249;-420.0042,701.8993;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;296;-4561.122,-1672.78;Inherit;True;Spherical;Object;False;Top Texture 2;_TopTexture2;gray;-1;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;214;-326.4685,223.4323;Inherit;False;213;FinalAmbientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;293;-4982.306,-2154.956;Inherit;True;Property;_SnowHeight;Height;21;0;Create;False;0;0;0;False;0;False;2797db87c7d02c143bc560c8cfdf5797;2797db87c7d02c143bc560c8cfdf5797;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;298;-3370.829,-1832.283;Inherit;False;SnowHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-291.5009,112.0848;Inherit;False;208;FinalSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-261.9667,9.738831;Inherit;False;186;NormalBlend;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;294;-4478.176,-1870.175;Inherit;True;Property;_TextureSample2;Texture Sample 2;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;201;-253.9667,-77.26117;Inherit;False;200;FinalAlbedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;297;-3881.342,-1845.016;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;TriForge/Winter Forest/Bark - Tesselation;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;8;3;6;True;1;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;291;0;287;0
WireConnection;289;0;287;0
WireConnection;292;0;291;0
WireConnection;292;1;289;0
WireConnection;292;2;290;1
WireConnection;328;0;181;0
WireConnection;328;1;329;0
WireConnection;163;0;105;0
WireConnection;295;0;292;0
WireConnection;180;0;179;2
WireConnection;180;1;328;0
WireConnection;182;0;180;0
WireConnection;185;0;183;0
WireConnection;185;1;184;0
WireConnection;185;2;182;0
WireConnection;134;0;106;4
WireConnection;134;3;135;0
WireConnection;134;4;136;0
WireConnection;262;0;134;0
WireConnection;187;0;185;0
WireConnection;155;0;141;3
WireConnection;155;1;156;0
WireConnection;300;0;299;0
WireConnection;188;0;187;2
WireConnection;188;1;328;0
WireConnection;301;0;299;0
WireConnection;153;0;263;0
WireConnection;153;1;158;0
WireConnection;153;2;155;0
WireConnection;303;0;300;4
WireConnection;303;1;301;4
WireConnection;303;2;290;1
WireConnection;189;0;188;0
WireConnection;189;1;190;0
WireConnection;68;0;36;2
WireConnection;68;1;69;0
WireConnection;261;0;106;1
WireConnection;261;1;107;0
WireConnection;144;0;153;0
WireConnection;144;1;145;0
WireConnection;327;10;77;0
WireConnection;327;7;6;0
WireConnection;70;0;68;0
WireConnection;191;0;189;0
WireConnection;305;0;300;0
WireConnection;305;1;301;0
WireConnection;305;2;290;1
WireConnection;304;0;303;0
WireConnection;304;1;302;0
WireConnection;162;0;104;0
WireConnection;112;0;144;0
WireConnection;112;1;130;0
WireConnection;165;0;106;2
WireConnection;151;0;141;2
WireConnection;307;0;305;0
WireConnection;192;0;191;0
WireConnection;167;0;261;0
WireConnection;37;0;70;0
WireConnection;37;1;327;0
WireConnection;306;0;304;0
WireConnection;152;0;112;0
WireConnection;152;1;151;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;168;0;39;0
WireConnection;207;0;203;0
WireConnection;207;1;204;0
WireConnection;207;2;206;0
WireConnection;169;0;152;0
WireConnection;197;0;193;0
WireConnection;197;1;194;0
WireConnection;197;2;199;0
WireConnection;209;0;210;0
WireConnection;209;1;211;0
WireConnection;209;2;212;0
WireConnection;186;0;185;0
WireConnection;208;0;207;0
WireConnection;200;0;197;0
WireConnection;213;0;209;0
WireConnection;249;0;170;0
WireConnection;249;1;171;0
WireConnection;296;0;293;0
WireConnection;298;0;297;0
WireConnection;294;0;293;0
WireConnection;297;0;294;1
WireConnection;297;1;296;1
WireConnection;297;2;290;1
WireConnection;0;0;201;0
WireConnection;0;1;202;0
WireConnection;0;4;216;0
WireConnection;0;5;214;0
WireConnection;0;11;249;0
ASEEND*/
//CHKSM=342B8BC2A40494812CB57C5C3F013DEB786B99D6