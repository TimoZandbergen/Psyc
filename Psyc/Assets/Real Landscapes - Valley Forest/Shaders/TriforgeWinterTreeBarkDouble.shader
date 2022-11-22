// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TriForge/Winter Forest/Bark Double"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
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
		_SnowAmount("Snow Amount", Range( 0 , 2)) = 2
		_SnowMaskSharpness("Snow Mask Sharpness", Range( 0 , 15)) = 1
		_BlendStrength("Blend Strength", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma instancing_options procedural:setup
		#pragma multi_compile GPU_FRUSTUM_ON __
		#include "VS_indirect.cginc"
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap nometa noforwardadd dithercrossfade vertex:vertexDataFunc 
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
		uniform float _BottomHeightMin;
		uniform float _BottomHeightMax;
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
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _HeightMin;
		uniform float _HeightMax;
		uniform float _BlendStrength;
		uniform sampler2D _SnowNormal;
		uniform float4 _SnowNormal_ST;
		uniform float _SnowAmount;
		uniform float TFW_SnowAmount;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _BottomAlbedo;
		uniform float4 _BottomAlbedo_ST;
		uniform sampler2D _SnowAlbedo;
		uniform float4 _SnowAlbedo_ST;
		uniform float _SnowMaskSharpness;
		uniform float _Smoothness;
		uniform sampler2D _BottomMask;
		uniform float4 _BottomMask_ST;
		uniform float _BottomSmoothness;
		uniform float _SnowSmoothness;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float ifLocalVar109_g3 = 0;
			if( abs( TFW_WindDirection.x ) > 0.0 )
				ifLocalVar109_g3 = 1.0;
			else if( abs( TFW_WindDirection.x ) == 0.0 )
				ifLocalVar109_g3 = 0.0;
			float ifLocalVar110_g3 = 0;
			if( abs( TFW_WindDirection.z ) > 0.0 )
				ifLocalVar110_g3 = 0.0;
			float ifLocalVar112_g3 = 0;
			if( ifLocalVar109_g3 == ifLocalVar110_g3 )
				ifLocalVar112_g3 = 1.0;
			float3 lerpResult123_g3 = lerp( TFW_WindDirection , float3(1,0,0) , ifLocalVar112_g3);
			float3 worldToObjDir38_g3 = normalize( mul( unity_WorldToObject, float4( lerpResult123_g3, 0 ) ).xyz );
			float3 lerpResult39_g3 = lerp( worldToObjDir38_g3 , TFW_WindDirection , TFW_DirectionRandomness);
			float3 WindDirection41_g3 = lerpResult39_g3;
			float WindSpeed19_g3 = ( _WindSpeed * TFW_WindSpeed );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 transform2_g3 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float2 WorldSpaceUv9_g3 = (( transform2_g3 / ( -100.0 * ( 1.0 * _WindNoiseScale ) ) )).xz;
			float2 uv2_TexCoord12_g3 = v.texcoord1.xy * float2( 0,0 ) + WorldSpaceUv9_g3;
			float2 temp_cast_1 = (uv2_TexCoord12_g3.x).xx;
			float2 panner13_g3 = ( 1.0 * _Time.y * ( float2( 0.12,0 ) * WindSpeed19_g3 ) + temp_cast_1);
			float simplePerlin3D11_g3 = snoise( float3( panner13_g3 ,  0.0 )*0.5 );
			float MainWindBending86_g3 = simplePerlin3D11_g3;
			float WindRotation32_g3 = radians( ( ( (-0.6 + (MainWindBending86_g3 - -1.0) * (1.0 - -0.6) / (1.0 - -1.0)) * TFW_WindStrength ) * 25.0 ) );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 rotatedValue42_g3 = RotateAroundAxis( float3( 0,0,0 ), ase_vertex3Pos, WindDirection41_g3, WindRotation32_g3 );
			float3 MainWind168 = ( ( saturate( pow( v.texcoord1.xy.y , 2.34 ) ) * ( ( rotatedValue42_g3 - ase_vertex3Pos ) * TFW_EnableWind ) ) * _WindStrength );
			v.vertex.xyz += MainWind168;
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
			float HeightMap265 = saturate( (_HeightMin + (tex2DNode106.a - 0.0) * (_HeightMax - _HeightMin) / (1.0 - 0.0)) );
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
			float saferPower439 = max( ase_worldNormal.y , 0.0001 );
			float temp_output_429_0 = ( _SnowAmount * TFW_SnowAmount );
			float3 lerpResult185 = lerp( NormalBottomBlend299 , SnowNormal178 , saturate( ( pow( saferPower439 , 5.0 ) * temp_output_429_0 ) ));
			float3 NormalBlend186 = lerpResult185;
			o.Normal = NormalBlend186;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 Albedo162 = tex2D( _MainTex, uv_MainTex );
			float2 uv3_BottomAlbedo = i.uv3_texcoord3 * _BottomAlbedo_ST.xy + _BottomAlbedo_ST.zw;
			float4 BottomAlbedo268 = tex2D( _BottomAlbedo, uv3_BottomAlbedo );
			float4 lerpResult286 = lerp( Albedo162 , BottomAlbedo268 , TopBottomMask283);
			float4 AlbedoBottomBlend288 = lerpResult286;
			float2 uv_SnowAlbedo = i.uv_texcoord * _SnowAlbedo_ST.xy + _SnowAlbedo_ST.zw;
			float4 tex2DNode385 = tex2D( _SnowAlbedo, uv_SnowAlbedo );
			float4 triplanar379 = TriplanarSampling379( _SnowAlbedo, ase_vertex3Pos, ase_vertexNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float4 lerpResult392 = lerp( tex2DNode385 , triplanar379 , i.vertexColor.r);
			float4 SnowAlbedo195 = lerpResult392;
			float saferPower189 = max( ( (WorldNormalVector( i , lerpResult185 )).y * temp_output_429_0 ) , 0.0001 );
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
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
1920;6;1920;1013;6168.572;6794.469;2.442267;True;False
Node;AmplifyShaderEditor.CommentaryNode;259;-4699.391,-5664.448;Inherit;False;983.113;999.4737;Comment;14;265;136;135;134;167;165;162;104;106;163;105;306;307;441;Base Texture Samples;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-4618.172,-4749.256;Inherit;False;Property;_HeightMax;Height Max;5;0;Create;True;0;0;0;True;0;False;0;1.06;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-4619.931,-4822.548;Inherit;False;Property;_HeightMin;Height Min;4;0;Create;True;0;0;0;True;0;False;0;-1.17;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;-4643.965,-5217.769;Inherit;True;Property;_Mask;Smoothness (R), Ambient Occlusion (G), Height (A);2;0;Create;False;0;0;0;False;0;False;-1;None;f706e390068fe1c46a95c3bc8187c94a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;134;-4311.4,-4944.455;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;441;-4020.146,-4812.836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;319;-2647.067,-4844.135;Inherit;False;1044.454;498.1787;Comment;6;277;280;292;282;283;440;Bottom Texture Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;265;-3917.009,-4948.63;Inherit;False;HeightMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;-2597.067,-4794.135;Inherit;False;265;HeightMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;280;-2541.894,-4581.957;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;292;-2374.13,-4789.736;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-2370.429,-4470.909;Inherit;False;Property;_BlendStrength;Blend Strength;20;0;Create;True;0;0;0;False;0;False;0;1.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;321;-4691.974,-4452.524;Inherit;False;1150.525;890.459;Comment;14;262;275;263;269;274;273;272;313;312;261;310;268;311;442;Bottom Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;105;-4647.917,-5421.534;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;e5333cabc49e42c4f8933f6063cac69e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;262;-4641.974,-4185.02;Inherit;True;Property;_BottomNormal;Bottom Normal;7;0;Create;True;0;0;0;False;0;False;-1;None;c5cb2e4e9ad84f14680126c7a81fd6a1;True;2;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.HeightMapBlendNode;282;-2142.021,-4710.468;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;269;-4276.634,-4184.219;Inherit;False;BottomNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;320;-2601.406,-7285.537;Inherit;False;1066.546;2042.527;Comment;25;287;318;288;317;286;284;316;315;314;285;304;303;299;300;302;301;297;298;295;296;322;323;324;325;326;Top/Bottom Blends;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;376;-4985.083,-2818.07;Inherit;True;Property;_SnowNormal;Snow Normal;17;0;Create;False;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;256;-4533.839,-1741.936;Inherit;False;2135.386;650.1171;;17;188;190;189;191;192;181;179;180;182;184;183;185;187;186;428;429;439;Snow Mask;0,0.7479331,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-4674.844,-3338.381;Inherit;False;1457.155;1212.136;Comment;13;195;309;308;205;178;392;391;390;389;379;381;385;386;Snow Texture Samples;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-4264.913,-5420.882;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;-1858.614,-4715.041;Inherit;False;TopBottomMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-2527.601,-6730.835;Inherit;False;269;BottomNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;179;-4509.126,-1694.81;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TriplanarNode;381;-4625.113,-2711.619;Inherit;True;Spherical;Object;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;295;-2510.546,-6827.65;Inherit;False;163;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-4510.839,-1481.234;Inherit;False;Property;_SnowAmount;Snow Amount;18;0;Create;True;0;0;0;False;0;False;2;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;389;-4415.331,-2499.01;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;298;-2532.022,-6610.012;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;386;-4552.661,-2911.626;Inherit;True;Property;_TextureSample1;Texture Sample 1;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;428;-4510.098,-1351.035;Inherit;False;Global;TFW_SnowAmount;TFW_SnowAmount;22;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;439;-4245.872,-1642.992;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;-4186.098,-1431.035;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;297;-2200.493,-6813.35;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;390;-3953.7,-2777.108;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-4007.84,-1631.234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-3445.567,-2760.613;Inherit;False;SnowNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;299;-1954.424,-6819.244;Inherit;False;NormalBottomBlend;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;182;-3849.84,-1588.234;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-4123.841,-1180.234;Inherit;False;178;SnowNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-4171.84,-1279.234;Inherit;False;299;NormalBottomBlend;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;263;-4638.942,-3972.167;Inherit;True;Property;_BottomMask;Bottom Smoothness (R), Ambient Occlusion (G), Height (A);8;0;Create;False;0;0;0;True;0;False;-1;None;b3ac54e5c8cb504498cd24cb4884ad4d;True;2;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;307;-4177.971,-5158.039;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;185;-3872.841,-1241.234;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;313;-4311.223,-4008.284;Inherit;False;Property;_BottomSmoothness;Bottom Smoothness;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;375;-4982.391,-3219.895;Inherit;True;Property;_SnowAlbedo;Snow Albedo;16;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;261;-4641.338,-4401.122;Inherit;True;Property;_BottomAlbedo;Bottom Albedo;6;0;Create;True;0;0;0;False;0;False;-1;None;a83a2c942b4fcbf45ad159301672d114;True;2;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;160;-4392.574,-371.9589;Inherit;False;1889.651;1137.943;;7;39;38;77;6;33;168;437;Main Wind;0.7133185,0.4198113,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;104;-4649.39,-5614.448;Inherit;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;0;False;0;False;-1;None;e6efc0517d0435a419c549585c027305;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-4177.971,-5268.039;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;-4025.94,-4047.633;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;187;-3671.722,-1559.174;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;-3958.411,-5050.993;Inherit;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-4276.913,-5612.882;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;-3817.169,-3968.934;Inherit;False;BottomAO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-4506.292,-1219.479;Inherit;False;Property;_SnowMaskSharpness;Snow Mask Sharpness;19;0;Create;True;0;0;0;False;0;False;1;1;0;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-3962.573,-5271.552;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;33;-3797.736,-260.9178;Inherit;False;867.5936;526.5638;;5;37;36;68;69;70;Mask Wind by UV2;1,0.5394964,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-3820.449,-4052.005;Inherit;False;BottomSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;385;-4558.288,-3299.716;Inherit;True;Property;_TextureSample0;Texture Sample 0;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-3307.841,-1464.234;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;379;-4636.685,-3104.798;Inherit;True;Spherical;Object;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;-4273.109,-4402.524;Inherit;False;BottomAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3775.216,-210.7489;Inherit;True;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;285;-2508.733,-7146.763;Inherit;False;268;BottomAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;189;-3023.454,-1352.82;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-2467.866,-5618.059;Inherit;False;311;BottomAO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;309;-3732.496,-2973.099;Inherit;False;Property;_SnowSmoothness;Snow Smoothness;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-2529.635,-6304.346;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-2473.937,-7235.537;Inherit;False;162;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;-2509.349,-6496.983;Inherit;False;167;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;-2512.972,-5503.495;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-2520.243,-7043.664;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3542.507,-48.22888;Inherit;False;Constant;_Float7;Float 7;3;0;Create;True;0;0;0;False;0;False;2.34;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-2551.406,-6402.549;Inherit;False;310;BottomSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;391;-3953.567,-3042.411;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;323;-2504.015,-5723.263;Inherit;False;165;AmbientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-4259.695,421.4122;Inherit;False;Property;_WindNoiseScale;Wind Noise Scale;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;286;-2226.462,-7231.241;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;317;-2199.297,-6482.684;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-3669.248,-3097.901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;325;-2193.961,-5709.962;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;68;-3503.84,-192.3949;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;191;-2834.454,-1351.82;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-4342.574,327.702;Inherit;False;Property;_WindSpeed;Wind Speed;14;0;Create;True;0;0;0;True;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;392;-3952.881,-3263.126;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;-2010.262,-7235.536;Inherit;False;AlbedoBottomBlend;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-2654.454,-1356.82;Inherit;False;SnowBlendMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-3487.442,-3269.366;Inherit;False;SnowAlbedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;260;-1494.774,-1952.608;Inherit;False;878.523;1119.711;Comment;15;208;212;209;213;210;211;200;207;197;206;199;204;203;194;193;Snow Mask Blends;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;-1947.892,-5715.856;Inherit;False;AOBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;437;-3627.513,317.3231;Inherit;False;TriforgeTreeWind;-1;;3;02c5e277b3e957a46ade320788361410;0;2;10;FLOAT;1;False;7;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;-1953.227,-6488.578;Inherit;False;SmoothnessBottomBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-3497.819,-3101.214;Inherit;False;SnowSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;-3340.741,-189.1258;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-1423.826,-1120.849;Inherit;False;326;AOBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-1451.348,-1901.608;Inherit;False;288;AlbedoBottomBlend;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-1344.5,-1032.697;Inherit;False;Constant;_Float0;Float 0;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-1412.027,-1805.637;Inherit;False;195;SnowAlbedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-3145.382,390.0731;Inherit;False;Property;_WindStrength;Wind Strength;12;0;Create;True;0;0;0;False;0;False;0.3;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;-1424.5,-944.6971;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-3152.199,-199.2218;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-1436.839,-1712.244;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-1426.573,-1434.937;Inherit;False;205;SnowSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-1418.351,-1341.397;Inherit;False;192;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-1466.074,-1530.337;Inherit;False;318;SmoothnessBottomBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;209;-1156.251,-1065.896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;207;-1146.851,-1477.796;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;197;-1152.839,-1854.244;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2874.771,231.6541;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-952.2515,-1481.096;Inherit;False;FinalSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-955.9055,-1857.405;Inherit;False;FinalAlbedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-2717.557,227.5921;Inherit;False;MainWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;-960.5005,-1072.697;Inherit;False;FinalAmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-3642.841,-1207.41;Inherit;False;NormalBlend;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-291.5009,112.0848;Inherit;False;208;FinalSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;275;-4585.843,-3677.065;Inherit;False;Property;_BottomHeightMax;Bottom Height Max;11;0;Create;True;0;0;0;True;0;False;1;1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;-3816.309,-3886.8;Inherit;False;BottomHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;-1954.415,-6096.999;Inherit;False;HeightBottomBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;442;-3973.293,-3787.415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;293;-213.7643,-197.975;Inherit;False;Constant;_Float5;Float 5;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;300;-2532.013,-5887.768;Inherit;False;283;TopBottomMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-325.4685,224.4323;Inherit;False;213;FinalAmbientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-261.9667,9.738831;Inherit;False;186;NormalBlend;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-2527.592,-6008.591;Inherit;False;272;BottomHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;302;-2510.537,-6105.406;Inherit;False;265;HeightMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-253.9667,-77.26117;Inherit;False;200;FinalAlbedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-4587.603,-3752.958;Inherit;False;Property;_BottomHeightMin;Bottom Height Min;10;0;Create;True;0;0;0;True;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-236.366,333.5673;Inherit;False;168;MainWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;273;-4263.514,-3875.849;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;303;-2200.484,-6091.105;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;445.6431,59.78136;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TriForge/Winter Forest/Bark Double;False;False;False;False;False;False;True;False;True;False;True;True;True;False;True;False;True;False;False;False;True;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;8;3;6;True;1;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;3;Pragma;instancing_options procedural:setup;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Include;VS_indirect.cginc;False;9e72312817e6e10468532362fcec98c2;Custom;0;0;False;1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;267;-1436.273,-3608.345;Inherit;False;106.2295;100;Comment;0;UV2 - Wind Mask, UV3 - Tree Bottom Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;403;-1442.115,-3883.834;Inherit;False;100;100;Comment;0;Legend:;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;276;-1440.946,-3330.367;Inherit;False;100;100;Comment;0;Vertex Color Red - Blend mask for Bottom Textures;0.9339623,0,0,1;0;0
WireConnection;134;0;106;4
WireConnection;134;3;135;0
WireConnection;134;4;136;0
WireConnection;441;0;134;0
WireConnection;265;0;441;0
WireConnection;292;0;277;0
WireConnection;282;0;292;0
WireConnection;282;1;280;1
WireConnection;282;2;440;0
WireConnection;269;0;262;0
WireConnection;163;0;105;0
WireConnection;283;0;282;0
WireConnection;381;0;376;0
WireConnection;386;0;376;0
WireConnection;439;0;179;2
WireConnection;429;0;181;0
WireConnection;429;1;428;0
WireConnection;297;0;295;0
WireConnection;297;1;296;0
WireConnection;297;2;298;0
WireConnection;390;0;386;0
WireConnection;390;1;381;0
WireConnection;390;2;389;1
WireConnection;180;0;439;0
WireConnection;180;1;429;0
WireConnection;178;0;390;0
WireConnection;299;0;297;0
WireConnection;182;0;180;0
WireConnection;185;0;183;0
WireConnection;185;1;184;0
WireConnection;185;2;182;0
WireConnection;306;0;106;1
WireConnection;306;1;307;0
WireConnection;312;0;263;1
WireConnection;312;1;313;0
WireConnection;187;0;185;0
WireConnection;165;0;106;2
WireConnection;162;0;104;0
WireConnection;311;0;263;2
WireConnection;167;0;306;0
WireConnection;310;0;312;0
WireConnection;385;0;375;0
WireConnection;188;0;187;2
WireConnection;188;1;429;0
WireConnection;379;0;375;0
WireConnection;268;0;261;0
WireConnection;189;0;188;0
WireConnection;189;1;190;0
WireConnection;391;0;385;4
WireConnection;391;1;379;4
WireConnection;391;2;389;1
WireConnection;286;0;284;0
WireConnection;286;1;285;0
WireConnection;286;2;287;0
WireConnection;317;0;315;0
WireConnection;317;1;314;0
WireConnection;317;2;316;0
WireConnection;308;0;391;0
WireConnection;308;1;309;0
WireConnection;325;0;323;0
WireConnection;325;1;322;0
WireConnection;325;2;324;0
WireConnection;68;0;36;2
WireConnection;68;1;69;0
WireConnection;191;0;189;0
WireConnection;392;0;385;0
WireConnection;392;1;379;0
WireConnection;392;2;389;1
WireConnection;288;0;286;0
WireConnection;192;0;191;0
WireConnection;195;0;392;0
WireConnection;326;0;325;0
WireConnection;437;10;77;0
WireConnection;437;7;6;0
WireConnection;318;0;317;0
WireConnection;205;0;308;0
WireConnection;70;0;68;0
WireConnection;37;0;70;0
WireConnection;37;1;437;0
WireConnection;209;0;210;0
WireConnection;209;1;211;0
WireConnection;209;2;212;0
WireConnection;207;0;203;0
WireConnection;207;1;204;0
WireConnection;207;2;206;0
WireConnection;197;0;193;0
WireConnection;197;1;194;0
WireConnection;197;2;199;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;208;0;207;0
WireConnection;200;0;197;0
WireConnection;168;0;39;0
WireConnection;213;0;209;0
WireConnection;186;0;185;0
WireConnection;272;0;442;0
WireConnection;304;0;303;0
WireConnection;442;0;273;0
WireConnection;273;0;263;4
WireConnection;273;3;274;0
WireConnection;273;4;275;0
WireConnection;303;0;302;0
WireConnection;303;1;301;0
WireConnection;303;2;300;0
WireConnection;0;0;201;0
WireConnection;0;1;202;0
WireConnection;0;4;216;0
WireConnection;0;5;214;0
WireConnection;0;11;171;0
ASEEND*/
//CHKSM=0C8AC71767113DAA8AA92A63C5D302383002D963