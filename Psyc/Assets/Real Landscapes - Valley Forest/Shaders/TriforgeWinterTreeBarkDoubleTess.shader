// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TriForge/Winter Forest/Bark Double - Tessellation"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Mask("Smoothness (R), Ambient Occlusion (G), Height (A)", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_HeightMin("Height Min", Range( -2 , 2)) = 0
		_HeightMax("Height Max", Range( -2 , 2)) = 0
		_BottomAlbedo("Bottom Albedo", 2D) = "white" {}
		_BottomNormal("Bottom Normal", 2D) = "bump" {}
		_BottomMask("Bottom Smoothness (R), Ambient Occlusion (G), Height (A)", 2D) = "white" {}
		_BottomSmoothness("Bottom Smoothness", Range( 0 , 1)) = 1
		_BottomHeightMin("Bottom Height Min", Range( -2 , 2)) = 0
		_BottomHeightMax("Bottom Height Max", Range( -2 , 2)) = 1
		_WindStrength("Wind Strength", Range( 0 , 2)) = 0.3
		_WindNoiseScale("Wind Noise Scale", Float) = 1
		_WindSpeed("Wind Speed", Range( 0 , 5)) = 1
		_SnowSmoothness("Snow Smoothness", Range( 0 , 1)) = 1
		_SnowAlbedo("Snow Albedo", 2D) = "white" {}
		_SnowNormal("Snow Normal", 2D) = "bump" {}
		_SnowAmount("Snow Amount", Range( 0 , 2)) = 0
		_SnowMaskSharpness("Snow Mask Sharpness", Range( 0 , 3)) = 1
		_DisplacementStrength("Displacement Strength", Float) = 1
		_TessellationSeamOffset("Tessellation Seam Offset", Range( -3 , 3)) = 0
		_TessellationSeamMask("Tessellation Seam Mask", Range( 0.1 , 5)) = 3
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 18
		_TessMin( "Tess Min Distance", Float ) = 4
		_TessMax( "Tess Max Distance", Float ) = 18
		_BlendStrength("Blend Strength", Float) = 1
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
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
			float2 uv3_texcoord3;
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float TFW_WindStrength;
		uniform int TFW_EnableWind;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _HeightMin;
		uniform float _HeightMax;
		uniform sampler2D _BottomMask;
		uniform float4 _BottomMask_ST;
		uniform float _BottomHeightMin;
		uniform float _BottomHeightMax;
		uniform float _BlendStrength;
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
		uniform sampler2D _BottomNormal;
		uniform float4 _BottomNormal_ST;
		uniform sampler2D _SnowNormal;
		uniform float4 _SnowNormal_ST;
		uniform float _SnowAmount;
		uniform float TFW_SnowAmount;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _BottomAlbedo;
		uniform float4 _BottomAlbedo_ST;
		uniform sampler2D _SnowAlbedo;
		uniform float4 _SnowAlbedo_ST;
		uniform float _SnowMaskSharpness;
		uniform float _Smoothness;
		uniform float _BottomSmoothness;
		uniform float _SnowSmoothness;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;


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


		inline float3 TriplanarSampling381( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		inline float4 TriplanarSampling379( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
			float temp_output_134_0 = (_HeightMin + (tex2DNode106.a - 0.0) * (_HeightMax - _HeightMin) / (1.0 - 0.0));
			float HeightMap265 = temp_output_134_0;
			float2 uv3_BottomMask = v.texcoord2 * _BottomMask_ST.xy + _BottomMask_ST.zw;
			float4 tex2DNode263 = tex2Dlod( _BottomMask, float4( uv3_BottomMask, 0, 0.0) );
			float temp_output_273_0 = (_BottomHeightMin + (tex2DNode263.a - 0.0) * (_BottomHeightMax - _BottomHeightMin) / (1.0 - 0.0));
			float BottomHeight272 = temp_output_273_0;
			float HeightMask282 = saturate(pow(((( HeightMap265 * 20.0 )*v.color.r)*4)+(v.color.r*2),_BlendStrength));
			float TopBottomMask283 = HeightMask282;
			float lerpResult303 = lerp( HeightMap265 , BottomHeight272 , TopBottomMask283);
			float HeightBottomBlend304 = lerpResult303;
			float saferPower155 = max( v.color.b , 0.0001 );
			float lerpResult153 = lerp( HeightBottomBlend304 , _TessellationSeamOffset , pow( saferPower155 , _TessellationSeamMask ));
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
			float2 uv3_BottomNormal = i.uv3_texcoord3 * _BottomNormal_ST.xy + _BottomNormal_ST.zw;
			float3 BottomNormal269 = UnpackNormal( tex2D( _BottomNormal, uv3_BottomNormal ) );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode106 = tex2D( _Mask, uv_Mask );
			float temp_output_134_0 = (_HeightMin + (tex2DNode106.a - 0.0) * (_HeightMax - _HeightMin) / (1.0 - 0.0));
			float HeightMap265 = temp_output_134_0;
			float HeightMask282 = saturate(pow(((( HeightMap265 * 20.0 )*i.vertexColor.r)*4)+(i.vertexColor.r*2),_BlendStrength));
			float TopBottomMask283 = HeightMask282;
			float3 lerpResult297 = lerp( NormalMap163 , BottomNormal269 , TopBottomMask283);
			float3 NormalBottomBlend299 = lerpResult297;
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
			float3 triplanar381 = TriplanarSampling381( _SnowNormal, ase_vertex3Pos, ase_vertexNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float3 tanTriplanarNormal381 = mul( objectToTangent, triplanar381 );
			float3 lerpResult390 = lerp( UnpackNormal( tex2D( _SnowNormal, uv_SnowNormal ) ) , tanTriplanarNormal381 , i.vertexColor.r);
			float3 SnowNormal178 = lerpResult390;
			float saferPower454 = max( ase_worldNormal.y , 0.0001 );
			float temp_output_450_0 = ( _SnowAmount * TFW_SnowAmount );
			float3 lerpResult185 = lerp( NormalBottomBlend299 , SnowNormal178 , saturate( ( pow( saferPower454 , 10.0 ) * temp_output_450_0 ) ));
			float3 NormalBlend186 = lerpResult185;
			o.Normal = NormalBlend186;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo162 = tex2D( _Albedo, uv_Albedo );
			float2 uv3_BottomAlbedo = i.uv3_texcoord3 * _BottomAlbedo_ST.xy + _BottomAlbedo_ST.zw;
			float4 BottomAlbedo268 = tex2D( _BottomAlbedo, uv3_BottomAlbedo );
			float4 lerpResult286 = lerp( Albedo162 , BottomAlbedo268 , TopBottomMask283);
			float4 AlbedoBottomBlend288 = lerpResult286;
			float2 uv_SnowAlbedo = i.uv_texcoord * _SnowAlbedo_ST.xy + _SnowAlbedo_ST.zw;
			float4 tex2DNode385 = tex2D( _SnowAlbedo, uv_SnowAlbedo );
			float4 triplanar379 = TriplanarSampling379( _SnowAlbedo, ase_vertex3Pos, ase_vertexNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float4 lerpResult392 = lerp( tex2DNode385 , triplanar379 , i.vertexColor.r);
			float4 SnowAlbedo195 = lerpResult392;
			float saferPower189 = max( ( (WorldNormalVector( i , lerpResult185 )).y * temp_output_450_0 ) , 0.0001 );
			float SnowBlendMask192 = saturate( pow( saferPower189 , _SnowMaskSharpness ) );
			float4 lerpResult197 = lerp( AlbedoBottomBlend288 , SnowAlbedo195 , SnowBlendMask192);
			float4 FinalAlbedo200 = lerpResult197;
			o.Albedo = FinalAlbedo200.xyz;
			float Smoothness167 = ( tex2DNode106.r * _Smoothness );
			float2 uv3_BottomMask = i.uv3_texcoord3 * _BottomMask_ST.xy + _BottomMask_ST.zw;
			float4 tex2DNode263 = tex2D( _BottomMask, uv3_BottomMask );
			float BottomSmoothness310 = ( tex2DNode263.r * _BottomSmoothness );
			float lerpResult317 = lerp( Smoothness167 , BottomSmoothness310 , TopBottomMask283);
			float SmoothnessBottomBlend318 = lerpResult317;
			float lerpResult391 = lerp( tex2DNode385.a , triplanar379.a , i.vertexColor.r);
			float SnowSmoothness205 = ( lerpResult391 * _SnowSmoothness );
			float lerpResult207 = lerp( SmoothnessBottomBlend318 , SnowSmoothness205 , SnowBlendMask192);
			float FinalSmoothness208 = lerpResult207;
			o.Smoothness = FinalSmoothness208;
			float AmbientOcclusion165 = tex2DNode106.g;
			float BottomAO311 = tex2DNode263.g;
			float lerpResult325 = lerp( AmbientOcclusion165 , BottomAO311 , TopBottomMask283);
			float AOBlend326 = lerpResult325;
			float lerpResult209 = lerp( AOBlend326 , 1.0 , SnowBlendMask192);
			float FinalAmbientOcclusion213 = lerpResult209;
			o.Occlusion = FinalAmbientOcclusion213;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows noinstancing dithercrossfade vertex:vertexDataFunc tessellate:tessFunction 

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
				float4 customPack1 : TEXCOORD1;
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
				o.customPack1.zw = customInputData.uv3_texcoord3;
				o.customPack1.zw = v.texcoord2;
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
				surfIN.uv3_texcoord3 = IN.customPack1.zw;
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
1920;6;1920;1013;6943.645;-61.51807;5.396432;True;False
Node;AmplifyShaderEditor.CommentaryNode;259;-4699.391,-5664.448;Inherit;False;983.113;999.4737;Comment;14;265;136;135;134;167;165;162;104;106;163;105;306;307;451;Base Texture Samples;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-4618.172,-4749.256;Inherit;False;Property;_HeightMax;Height Max;5;0;Create;True;0;0;0;True;0;False;0;0.12;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-4619.931,-4822.548;Inherit;False;Property;_HeightMin;Height Min;4;0;Create;True;0;0;0;True;0;False;0;-0.02;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;-4643.965,-5217.769;Inherit;True;Property;_Mask;Smoothness (R), Ambient Occlusion (G), Height (A);2;0;Create;False;0;0;0;False;0;False;-1;None;29bcd0a346a3a0344ac6aa5d1f4bdd46;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;134;-4300.4,-4937.455;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;319;-2647.067,-4844.135;Inherit;False;1044.454;498.1787;Comment;6;277;280;292;282;283;453;Bottom Texture Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;265;-3933.009,-4941.63;Inherit;False;HeightMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;-2597.067,-4794.135;Inherit;False;265;HeightMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;453;-2555.823,-4503.616;Inherit;False;Property;_BlendStrength;Blend Strength;28;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;321;-4691.974,-4452.524;Inherit;False;1150.525;890.459;Comment;14;262;275;263;269;274;273;272;313;312;261;310;268;311;452;Bottom Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;280;-2335.894,-4547.957;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;292;-2374.13,-4789.736;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;262;-4641.974,-4185.02;Inherit;True;Property;_BottomNormal;Bottom Normal;7;0;Create;True;0;0;0;False;0;False;-1;None;28b8bed06a9a18444b9bc77dbb9dbdf5;True;2;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.HeightMapBlendNode;282;-2142.021,-4710.468;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;105;-4647.917,-5421.534;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;4d42af96c852f474fa8263fd309f1532;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;-1858.614,-4715.041;Inherit;False;TopBottomMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;258;-4674.844,-3338.381;Inherit;False;1457.155;1212.136;Comment;13;195;309;308;205;178;392;391;390;389;379;381;385;386;Snow Texture Samples;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;376;-5059.267,-2833.028;Inherit;True;Property;_SnowNormal;Snow Normal;17;0;Create;False;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-4264.913,-5420.882;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;269;-4276.634,-4184.219;Inherit;False;BottomNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;320;-2601.406,-7285.537;Inherit;False;1066.546;2042.527;Comment;25;287;318;288;317;286;284;316;315;314;285;304;303;299;300;302;301;297;298;295;296;322;323;324;325;326;Top/Bottom Blends;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;256;-4533.839,-1741.936;Inherit;False;2135.386;650.1171;;17;188;190;189;191;192;181;179;180;182;184;183;185;187;186;449;450;454;Snow Mask;0,0.7479331,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-2534.173,-6779.028;Inherit;False;269;BottomNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-4587.603,-3752.958;Inherit;False;Property;_BottomHeightMin;Bottom Height Min;10;0;Create;True;0;0;0;True;0;False;0;-0.2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;381;-4625.113,-2711.619;Inherit;True;Spherical;Object;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;275;-4585.843,-3677.065;Inherit;False;Property;_BottomHeightMax;Bottom Height Max;11;0;Create;True;0;0;0;True;0;False;1;0.23;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;263;-4638.942,-3972.167;Inherit;True;Property;_BottomMask;Bottom Smoothness (R), Ambient Occlusion (G), Height (A);8;0;Create;False;0;0;0;True;0;False;-1;None;b0e1c15906bb905438c40cff7fceaf6c;True;2;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;181;-4517.117,-1499.589;Inherit;False;Property;_SnowAmount;Snow Amount;18;0;Create;True;0;0;0;False;0;False;0;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;449;-4517.219,-1410.976;Inherit;False;Global;TFW_SnowAmount;TFW_SnowAmount;22;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;298;-2538.594,-6658.205;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;386;-4552.661,-2911.626;Inherit;True;Property;_TextureSample1;Texture Sample 1;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;295;-2517.118,-6875.843;Inherit;False;163;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;389;-4422.103,-2468.036;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;179;-4518.126,-1678.81;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;454;-4308.724,-1640.081;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;297;-2207.065,-6861.543;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;390;-3953.7,-2777.108;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;450;-4212.516,-1460.894;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;273;-4263.514,-3875.849;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-3445.567,-2760.613;Inherit;False;SnowNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-4102.611,-1641.793;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;-3816.309,-3886.8;Inherit;False;BottomHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;299;-1960.996,-6867.437;Inherit;False;NormalBottomBlend;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;182;-3918.61,-1641.793;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-4152.841,-1227.234;Inherit;False;178;SnowNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;302;-2499.051,-6136.036;Inherit;False;265;HeightMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-2516.106,-6039.221;Inherit;False;272;BottomHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-4200.84,-1321.234;Inherit;False;299;NormalBottomBlend;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;300;-2520.527,-5918.398;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-4177.971,-5158.039;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;159;-4401.968,291.3344;Inherit;False;2036.89;887.5413;;13;152;151;112;130;144;145;153;158;155;141;156;169;305;Height Displacement;1,0.4621924,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;160;-4249.747,1363.948;Inherit;False;1889.651;1137.943;;6;39;38;77;6;33;168;Main Wind;0.7133185,0.4198113,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;303;-2188.998,-6121.735;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;185;-3895.841,-1301.234;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;313;-4311.223,-4008.284;Inherit;False;Property;_BottomSmoothness;Bottom Smoothness;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;-1942.929,-6127.629;Inherit;True;HeightBottomBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;141;-4107.697,974.8782;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;187;-3671.722,-1559.174;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-4177.971,-5268.039;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;-4025.94,-4047.633;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;375;-5068.822,-3206.38;Inherit;True;Property;_SnowAlbedo;Snow Albedo;16;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;104;-4649.39,-5614.448;Inherit;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;0;False;0;False;-1;None;a2732e0630ee9f84c9c21c70be674f2c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;261;-4641.338,-4401.122;Inherit;True;Property;_BottomAlbedo;Bottom Albedo;6;0;Create;True;0;0;0;False;0;False;-1;None;56b6155ed83dbb34a961e310e7711cd3;True;2;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;33;-3654.908,1474.989;Inherit;False;867.5936;526.5638;;5;37;36;68;69;70;Mask Wind by UV2;1,0.5394964,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-4126.456,835.1597;Inherit;False;Property;_TessellationSeamMask;Tessellation Seam Mask;22;0;Create;True;0;0;0;True;0;False;3;1.85;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-3962.573,-5271.552;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3399.679,1687.678;Inherit;False;Constant;_Float7;Float 7;3;0;Create;True;0;0;0;False;0;False;2.34;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-3325.455,-1206.82;Inherit;False;Property;_SnowMaskSharpness;Snow Mask Sharpness;19;0;Create;True;0;0;0;False;0;False;1;1.72;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;-3817.169,-3968.934;Inherit;False;BottomAO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;-4273.109,-4402.524;Inherit;False;BottomAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3632.388,1525.158;Inherit;True;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;158;-4120.455,713.1596;Inherit;False;Property;_TessellationSeamOffset;Tessellation Seam Offset;21;0;Create;True;0;0;0;False;0;False;0;0.02;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-4276.913,-5612.882;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TriplanarNode;379;-4636.685,-3104.798;Inherit;True;Spherical;Object;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;305;-4121.277,580.5101;Inherit;False;304;HeightBottomBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;-3958.411,-5050.993;Inherit;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;155;-3829.455,850.1597;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;385;-4558.288,-3299.716;Inherit;True;Property;_TextureSample0;Texture Sample 0;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-3820.449,-4052.005;Inherit;False;BottomSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-3307.841,-1464.234;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-4205.747,2061.609;Float;False;Property;_WindSpeed;Wind Speed;14;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;323;-2504.015,-5723.263;Inherit;False;165;AmbientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-3631.008,872.0103;Inherit;False;Property;_DisplacementStrength;Displacement Strength;20;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-2529.635,-6304.346;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-4121.868,2156.319;Inherit;False;Property;_WindNoiseScale;Wind Noise Scale;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-2521.07,-5627.448;Inherit;False;311;BottomAO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-2473.937,-7235.537;Inherit;False;162;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;391;-3953.567,-3042.411;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-2520.243,-7043.664;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;68;-3361.012,1543.512;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;-2509.349,-6496.983;Inherit;False;167;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;-2525.491,-5506.625;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;189;-3023.454,-1352.82;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-2551.406,-6402.549;Inherit;False;310;BottomSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;153;-3643.578,701.6829;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;309;-3732.496,-2973.099;Inherit;False;Property;_SnowSmoothness;Snow Smoothness;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;285;-2508.733,-7146.763;Inherit;False;268;BottomAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;286;-2226.462,-7231.241;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-3370.527,656.9854;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;-3197.913,1546.781;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;130;-3348.731,859.6037;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;456;-3484.685,2053.23;Inherit;False;TriforgeTreeWind;-1;;1;02c5e277b3e957a46ade320788361410;0;2;10;FLOAT;1;False;7;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;392;-3952.881,-3263.126;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-3669.248,-3097.901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;325;-2193.961,-5709.962;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;191;-2834.454,-1351.82;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;317;-2199.297,-6482.684;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;151;-3040.294,1022.247;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;-2010.262,-7235.536;Inherit;False;AlbedoBottomBlend;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;260;-1494.774,-1952.608;Inherit;False;878.523;1119.711;Comment;15;208;212;209;213;210;211;200;207;197;206;199;204;203;194;193;Snow Mask Blends;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-3088.007,730.5522;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-2654.454,-1356.82;Inherit;False;SnowBlendMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;-1953.227,-6488.578;Inherit;False;SmoothnessBottomBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;-1947.892,-5715.856;Inherit;False;AOBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-3497.819,-3101.214;Inherit;False;SnowSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-3057.554,2095.98;Inherit;False;Property;_WindStrength;Wind Strength;12;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-3009.371,1536.685;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-3487.442,-3269.366;Inherit;False;SnowAlbedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-1344.5,-1032.697;Inherit;False;Constant;_Float0;Float 0;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-1412.027,-1805.637;Inherit;False;195;SnowAlbedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-1436.839,-1712.244;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-1418.351,-1341.397;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-1451.348,-1901.608;Inherit;False;288;AlbedoBottomBlend;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-2831.663,861.0515;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-1423.826,-1120.849;Inherit;False;326;AOBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-1426.573,-1434.937;Inherit;False;205;SnowSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2731.943,1967.561;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1466.074,-1530.337;Inherit;False;318;SmoothnessBottomBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;-1424.5,-944.6971;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;207;-1146.851,-1477.796;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;197;-1152.839,-1854.244;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;209;-1156.251,-1065.896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-2574.729,1963.499;Inherit;False;MainWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-2644.369,855.6236;Inherit;False;HeightDisplacement;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-794.1883,697.933;Inherit;False;168;MainWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;-960.5005,-1072.697;Inherit;False;FinalAmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-843.021,550.6708;Inherit;False;169;HeightDisplacement;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-955.9055,-1857.405;Inherit;False;FinalAlbedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-3680.841,-1230.41;Inherit;False;NormalBlend;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-952.2515,-1481.096;Inherit;False;FinalSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-325.4685,224.4323;Inherit;False;213;FinalAmbientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;249;-534.4039,609.5999;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-253.9667,-77.26117;Inherit;False;200;FinalAlbedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-261.9667,9.738831;Inherit;False;186;NormalBlend;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-291.5009,112.0848;Inherit;False;208;FinalSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;452;-3979.142,-3808.134;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;451;-4000.682,-4802.93;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;293;-213.7643,-197.975;Inherit;False;Constant;_Float5;Float 5;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;445.6431,59.78136;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;TriForge/Winter Forest/Bark Double - Tessellation;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;True;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;18;4;18;False;1;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;23;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;270;-1445.201,-2926.171;Inherit;False;100;100;Comment;0;Vertex Color Blue - Tessellation Seam Mask;0,0.1061859,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;403;-1442.115,-3883.834;Inherit;False;100;100;Comment;0;Legend:;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;276;-1440.946,-3330.367;Inherit;False;100;100;Comment;0;Vertex Color Red - Blend mask for Bottom Textures;0.9339623,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;267;-1436.273,-3608.345;Inherit;False;106.2295;100;Comment;0;UV2 - Wind Mask, UV3 - Tree Bottom Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;271;-1444.276,-3138.58;Inherit;False;100;100;Comment;0;Vertex Color Green - Tessellation Mask;0.2058077,1,0.1462264,1;0;0
WireConnection;134;0;106;4
WireConnection;134;3;135;0
WireConnection;134;4;136;0
WireConnection;265;0;134;0
WireConnection;292;0;277;0
WireConnection;282;0;292;0
WireConnection;282;1;280;1
WireConnection;282;2;453;0
WireConnection;283;0;282;0
WireConnection;163;0;105;0
WireConnection;269;0;262;0
WireConnection;381;0;376;0
WireConnection;386;0;376;0
WireConnection;454;0;179;2
WireConnection;297;0;295;0
WireConnection;297;1;296;0
WireConnection;297;2;298;0
WireConnection;390;0;386;0
WireConnection;390;1;381;0
WireConnection;390;2;389;1
WireConnection;450;0;181;0
WireConnection;450;1;449;0
WireConnection;273;0;263;4
WireConnection;273;3;274;0
WireConnection;273;4;275;0
WireConnection;178;0;390;0
WireConnection;180;0;454;0
WireConnection;180;1;450;0
WireConnection;272;0;273;0
WireConnection;299;0;297;0
WireConnection;182;0;180;0
WireConnection;303;0;302;0
WireConnection;303;1;301;0
WireConnection;303;2;300;0
WireConnection;185;0;183;0
WireConnection;185;1;184;0
WireConnection;185;2;182;0
WireConnection;304;0;303;0
WireConnection;187;0;185;0
WireConnection;306;0;106;1
WireConnection;306;1;307;0
WireConnection;312;0;263;1
WireConnection;312;1;313;0
WireConnection;167;0;306;0
WireConnection;311;0;263;2
WireConnection;268;0;261;0
WireConnection;162;0;104;0
WireConnection;379;0;375;0
WireConnection;165;0;106;2
WireConnection;155;0;141;3
WireConnection;155;1;156;0
WireConnection;385;0;375;0
WireConnection;310;0;312;0
WireConnection;188;0;187;2
WireConnection;188;1;450;0
WireConnection;391;0;385;4
WireConnection;391;1;379;4
WireConnection;391;2;389;1
WireConnection;68;0;36;2
WireConnection;68;1;69;0
WireConnection;189;0;188;0
WireConnection;189;1;190;0
WireConnection;153;0;305;0
WireConnection;153;1;158;0
WireConnection;153;2;155;0
WireConnection;286;0;284;0
WireConnection;286;1;285;0
WireConnection;286;2;287;0
WireConnection;144;0;153;0
WireConnection;144;1;145;0
WireConnection;70;0;68;0
WireConnection;456;10;77;0
WireConnection;456;7;6;0
WireConnection;392;0;385;0
WireConnection;392;1;379;0
WireConnection;392;2;389;1
WireConnection;308;0;391;0
WireConnection;308;1;309;0
WireConnection;325;0;323;0
WireConnection;325;1;322;0
WireConnection;325;2;324;0
WireConnection;191;0;189;0
WireConnection;317;0;315;0
WireConnection;317;1;314;0
WireConnection;317;2;316;0
WireConnection;151;0;141;2
WireConnection;288;0;286;0
WireConnection;112;0;144;0
WireConnection;112;1;130;0
WireConnection;192;0;191;0
WireConnection;318;0;317;0
WireConnection;326;0;325;0
WireConnection;205;0;308;0
WireConnection;37;0;70;0
WireConnection;37;1;456;0
WireConnection;195;0;392;0
WireConnection;152;0;112;0
WireConnection;152;1;151;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;207;0;203;0
WireConnection;207;1;204;0
WireConnection;207;2;206;0
WireConnection;197;0;193;0
WireConnection;197;1;194;0
WireConnection;197;2;199;0
WireConnection;209;0;210;0
WireConnection;209;1;211;0
WireConnection;209;2;212;0
WireConnection;168;0;39;0
WireConnection;169;0;152;0
WireConnection;213;0;209;0
WireConnection;200;0;197;0
WireConnection;186;0;185;0
WireConnection;208;0;207;0
WireConnection;249;0;170;0
WireConnection;249;1;171;0
WireConnection;452;0;273;0
WireConnection;451;0;134;0
WireConnection;0;0;201;0
WireConnection;0;1;202;0
WireConnection;0;4;216;0
WireConnection;0;5;214;0
WireConnection;0;11;249;0
ASEEND*/
//CHKSM=DEAD48216DAEA3D255EF1D0FDB36C7D21AB75B53