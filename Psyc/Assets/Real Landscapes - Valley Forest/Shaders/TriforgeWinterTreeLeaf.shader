// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TriForge/Winter Forest/Leaf"
{
	Properties
	{
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 2
		[Toggle(_TFW_FLIPNORMALS)] _FlipBackNormals("Flip Back Normals", Float) = 0
		_MaskMap("Mask Map", 2D) = "white" {}
		_VertexAOStrength("Vertex AO Strength", Range( 0 , 1)) = 1
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_WindStrength("Wind Strength", Range( 0 , 2)) = 0.3
		_WindSpeed("Wind Speed", Range( 0 , 5)) = 1
		_WindNoiseScale("Wind Noise Scale", Float) = 1
		_LeafFlutterScale("Leaf Flutter Scale", Range( 0.1 , 10)) = 1
		_LeafFlutterStrength("Leaf Flutter Strength", Float) = 0
		_SidewaysForce("Sideways Force", Range( -10 , 10)) = 1
		_DownwardForce("Downward Force", Range( -10 , 10)) = 10
		_SnowMaxAmount("Snow Max Amount", Range( 0 , 2)) = 2
		_SnowMaskSharpness("Snow Mask Sharpness", Float) = 1.5
		_SnowNormalsInfluence("Snow Normals Influence", Range( 0 , 1)) = 0
		_SnowVertexAOInfluence("Snow Vertex AO Influence", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _TFW_FLIPNORMALS
		#pragma instancing_options procedural:setup
		#pragma multi_compile GPU_FRUSTUM_ON __
		#include "VS_indirect.cginc"
		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred nolightmap  nodirlightmap nometa noforwardadd dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			half ASEVFace : VFACE;
			half3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Translucency;
		};

		uniform half TFW_WindStrength;
		uniform int TFW_EnableWind;
		uniform half _LeafFlutterStrength;
		uniform half TFW_LeafFlutterStrength;
		uniform half TFW_LeafFlutterScale;
		uniform half _LeafFlutterScale;
		uniform half _SidewaysForce;
		uniform half3 TFW_WindDirection;
		uniform half TFW_DirectionRandomness;
		uniform half _WindSpeed;
		uniform float TFW_WindSpeed;
		uniform half _WindNoiseScale;
		uniform half _DownwardForce;
		uniform half _WindStrength;
		uniform sampler2D _Normal;
		uniform half4 _Normal_ST;
		uniform half _NormalScale;
		uniform sampler2D _MainTex;
		uniform half4 _MainTex_ST;
		uniform half4 _Color;
		uniform half _SnowNormalsInfluence;
		uniform half _SnowMaxAmount;
		uniform half TFW_SnowAmount;
		uniform half _SnowMaskSharpness;
		uniform sampler2D _MaskMap;
		uniform half4 _MaskMap_ST;
		uniform half _VertexAOStrength;
		uniform half _SnowVertexAOInfluence;
		uniform half _Smoothness;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform half _AlphaCutoff;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			half2 temp_output_401_0 = ( half2( 1,1 ) * 0.2 );
			float2 uv3_TexCoord288 = v.texcoord2.xy * temp_output_401_0;
			half2 panner283 = ( 0.5 * _Time.y * float2( 0.2,0 ) + uv3_TexCoord288);
			half temp_output_457_0 = ( TFW_LeafFlutterScale * _LeafFlutterScale );
			half simplePerlin2D282 = snoise( panner283*temp_output_457_0 );
			half LeafXZNoise390 = ( simplePerlin2D282 * _SidewaysForce );
			half ifLocalVar109_g1 = 0;
			if( abs( TFW_WindDirection.x ) > 0.0 )
				ifLocalVar109_g1 = 1.0;
			else if( abs( TFW_WindDirection.x ) == 0.0 )
				ifLocalVar109_g1 = 0.0;
			half ifLocalVar110_g1 = 0;
			if( abs( TFW_WindDirection.z ) > 0.0 )
				ifLocalVar110_g1 = 0.0;
			half ifLocalVar112_g1 = 0;
			if( ifLocalVar109_g1 == ifLocalVar110_g1 )
				ifLocalVar112_g1 = 1.0;
			half3 lerpResult123_g1 = lerp( TFW_WindDirection , half3(1,0,0) , ifLocalVar112_g1);
			half3 worldToObjDir38_g1 = normalize( mul( unity_WorldToObject, float4( lerpResult123_g1, 0 ) ).xyz );
			half3 lerpResult39_g1 = lerp( worldToObjDir38_g1 , TFW_WindDirection , TFW_DirectionRandomness);
			half3 WindDirection41_g1 = lerpResult39_g1;
			half WindSpeed19_g1 = ( _WindSpeed * TFW_WindSpeed );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half4 transform2_g1 = mul(unity_WorldToObject,half4( ase_worldPos , 0.0 ));
			half2 WorldSpaceUv9_g1 = (( transform2_g1 / ( -100.0 * ( 1.0 * _WindNoiseScale ) ) )).xz;
			float2 uv2_TexCoord12_g1 = v.texcoord1.xy * float2( 0,0 ) + WorldSpaceUv9_g1;
			half2 temp_cast_1 = (uv2_TexCoord12_g1.x).xx;
			half2 panner13_g1 = ( 1.0 * _Time.y * ( float2( 0.12,0 ) * WindSpeed19_g1 ) + temp_cast_1);
			half simplePerlin3D11_g1 = snoise( half3( panner13_g1 ,  0.0 )*0.5 );
			half MainWindBending86_g1 = simplePerlin3D11_g1;
			half WindRotation32_g1 = radians( ( ( (-0.6 + (MainWindBending86_g1 - -1.0) * (1.0 - -0.6) / (1.0 - -1.0)) * TFW_WindStrength ) * 25.0 ) );
			float3 ase_vertex3Pos = v.vertex.xyz;
			half3 rotatedValue42_g1 = RotateAroundAxis( float3( 0,0,0 ), ase_vertex3Pos, WindDirection41_g1, WindRotation32_g1 );
			half3 WindOutput394 = ( ( rotatedValue42_g1 - ase_vertex3Pos ) * TFW_EnableWind );
			half3 break358 = ( 0.15 * WindOutput394 );
			float2 uv3_TexCoord363 = v.texcoord2.xy * temp_output_401_0;
			half2 panner364 = ( 0.6 * _Time.y * float2( 0,0.34 ) + uv3_TexCoord363);
			half simplePerlin2D365 = snoise( panner364*temp_output_457_0 );
			simplePerlin2D365 = simplePerlin2D365*0.5 + 0.5;
			half LeafYNoise389 = ( simplePerlin2D365 * _DownwardForce );
			half3 appendResult360 = (half3(( LeafXZNoise390 * break358.x ) , ( LeafYNoise389 * break358.y ) , ( LeafXZNoise390 * break358.z )));
			half3 LeafWind216 = ( ( _LeafFlutterStrength * ( TFW_LeafFlutterStrength * appendResult360 ) ) * v.color.g );
			half3 MainWind215 = ( ( saturate( pow( v.texcoord1.xy.y , 2.34 ) ) * WindOutput394 ) * _WindStrength );
			v.vertex.xyz += ( LeafWind216 + MainWind215 );
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !defined(DIRECTIONAL)
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			half3 NormalMap220 = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale );
			half3 break417 = NormalMap220;
			half switchResult416 = (((i.ASEVFace>0)?(break417.z):(-break417.z)));
			half3 appendResult415 = (half3(break417.x , break417.y , switchResult416));
			#ifdef _TFW_FLIPNORMALS
				half3 staticSwitch427 = appendResult415;
			#else
				half3 staticSwitch427 = NormalMap220;
			#endif
			half3 FinalNormal421 = staticSwitch427;
			o.Normal = FinalNormal421;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 tex2DNode179 = tex2D( _MainTex, uv_MainTex );
			half4 AlbedoMap229 = ( tex2DNode179 * _Color );
			half4 color210 = IsGammaSpace() ? half4(0.6855198,0.726607,0.745283,0) : half4(0.4276438,0.4868178,0.5152035,0);
			half lerpResult424 = lerp( 1.0 , normalize( (WorldNormalVector( i , FinalNormal421 )) ).y , _SnowNormalsInfluence);
			half saferPower193 = max( ( lerpResult424 * ( _SnowMaxAmount * TFW_SnowAmount ) ) , 0.0001 );
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			half4 tex2DNode180 = tex2D( _MaskMap, uv_MaskMap );
			half SnowMask221 = tex2DNode180.r;
			half saferPower431 = max( ( ( 1.0 - i.vertexColor.r ) * 3.0 ) , 0.0001 );
			half lerpResult434 = lerp( 1.0 , saturate( pow( saferPower431 , 1.0 ) ) , _VertexAOStrength);
			half VertexAO437 = lerpResult434;
			half lerpResult442 = lerp( 1.0 , VertexAO437 , _SnowVertexAOInfluence);
			half SnowBlendMask227 = saturate( ( ( saturate( pow( saferPower193 , _SnowMaskSharpness ) ) * pow( ( SnowMask221 * 2.0 ) , 1.5 ) ) * lerpResult442 ) );
			half4 lerpResult187 = lerp( AlbedoMap229 , color210 , SnowBlendMask227);
			o.Albedo = lerpResult187.rgb;
			half SmoothnessMap223 = tex2DNode180.a;
			o.Smoothness = ( SmoothnessMap223 * _Smoothness );
			o.Occlusion = VertexAO437;
			half TranslucencyMap222 = tex2DNode180.g;
			half3 temp_cast_1 = (( TranslucencyMap222 * ( 1.0 - SnowBlendMask227 ) )).xxx;
			o.Translucency = temp_cast_1;
			o.Alpha = 1;
			half OpacityMap235 = ( tex2DNode179.a * _Color.a );
			clip( OpacityMap235 - _AlphaCutoff );
		}

		ENDCG
	}
	Fallback "TriForge/Winter Forest/Leaf - No Translucency"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
1920;6;1920;1013;3982.423;2298.495;1.646067;True;False
Node;AmplifyShaderEditor.CommentaryNode;238;-3036.582,-1926.544;Inherit;False;920.2439;872.9055;Comment;13;404;450;179;447;235;222;223;229;221;180;220;186;487;Texture Samples;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;404;-2944.132,-1354.639;Inherit;False;Property;_NormalScale;Normal Scale;5;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;186;-2700.617,-1298.52;Inherit;True;Property;_Normal;Normal;4;0;Create;True;0;0;0;False;0;False;-1;None;a3583b591d91a5b47a500d9adfb9c1ff;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;459;-1344.006,-1924.114;Inherit;False;1275.805;345.6475;Comment;7;417;415;416;418;234;427;421;Backface Normal Flip;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;220;-2380.519,-1298.749;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;234;-1294.006,-1823.989;Inherit;False;220;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;417;-979.9553,-1872.814;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;418;-1007.24,-1688.467;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;416;-842.6608,-1711.861;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;397;-3915.793,280.4961;Inherit;False;1703.407;834.8711;Comment;18;390;389;361;355;356;362;282;365;283;457;364;458;385;363;288;401;400;402;LeafFlutter Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;400;-3868.444,403.193;Inherit;False;Constant;_Vector0;Vector 0;12;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;402;-3865.019,567.8185;Inherit;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;460;-3853.657,3578.58;Inherit;False;1573.066;506.0902;Comment;11;428;451;430;429;433;431;432;435;436;434;437;Vertex Color AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;415;-789.3583,-1874.114;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;427;-608.9734,-1775.479;Inherit;False;Property;_FlipBackNormals;Flip Back Normals;6;0;Create;True;0;0;0;False;0;False;0;0;0;True;_TFW_FLIPNORMALS;Toggle;2;Key0;Key1;Create;False;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;428;-3803.657,3793.452;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;181;-3872.213,2212.128;Inherit;False;2008.527;1106.371;;7;215;39;38;77;6;33;394;Main Wind;0.504717,0.82099,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-3660.804,527.8756;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-3544.302,3917.68;Inherit;False;Constant;_Float3;Float 3;18;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-3781.702,2931.328;Inherit;False;Property;_WindSpeed;Wind Speed;17;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;288;-3466.482,346.5601;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.2,0.2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;421;-311.2013,-1776.626;Inherit;False;FinalNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-3700.823,3046.037;Inherit;False;Property;_WindNoiseScale;Wind Noise Scale;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;458;-3463.134,610.7793;Inherit;False;Property;_LeafFlutterScale;Leaf Flutter Scale;19;0;Create;True;0;0;0;False;0;False;1;0.6;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;363;-3460.084,715.6451;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.2,0.2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;451;-3553.775,3761.784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-3465.526,520.0523;Inherit;False;Global;TFW_LeafFlutterScale;TFW_LeafFlutterScale;12;0;Create;True;0;0;0;False;0;False;10;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;237;-5480.022,-744.1595;Inherit;False;3258.046;801.0634;;25;227;209;202;424;213;191;425;214;426;204;193;225;205;194;190;189;199;439;441;442;443;444;422;469;470;Snow Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;476;-3415.923,2991.672;Inherit;False;TriforgeTreeWind;-1;;1;02c5e277b3e957a46ade320788361410;0;2;10;FLOAT;1;False;7;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;457;-3122.646,524.7783;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;433;-3305.828,3969.672;Inherit;False;Constant;_Float9;Float 9;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;-3356.302,3815.68;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;422;-5405.131,-659.2875;Inherit;False;421;FinalNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;364;-3148.554,715.2662;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.34;False;1;FLOAT;0.6;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;283;-3153.066,346.1811;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,0;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;398;-3893.867,1258.987;Inherit;False;2192.538;630.6599;Comment;18;346;345;358;375;376;379;360;388;392;393;387;386;281;299;216;396;413;414;Leaf Flutter;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-5408.533,-317.6838;Inherit;False;Property;_SnowMaxAmount;Snow Max Amount;23;0;Create;True;0;0;0;False;0;False;2;1.4;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;431;-3183.222,3816.613;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;425;-5121.708,-506.9074;Inherit;False;Constant;_Float2;Float 2;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;365;-2933.71,708.6995;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-2898.641,585.1267;Inherit;False;Property;_SidewaysForce;Sideways Force;21;0;Create;True;0;0;0;False;0;False;1;1;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;470;-5095.008,-124.351;Inherit;False;Global;TFW_SnowAmount;TFW_SnowAmount;23;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;394;-3075.465,2986.722;Inherit;False;WindOutput;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;282;-2938.222,339.6142;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-2901.029,953.3845;Inherit;False;Property;_DownwardForce;Downward Force;22;0;Create;True;0;0;0;False;0;False;10;6;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;180;-2703.828,-1520.495;Inherit;True;Property;_MaskMap;Mask Map;7;0;Create;True;0;0;0;False;0;False;-1;None;fb08e328a0c431345977d27f4ea7c9c9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;426;-5246.791,-429.9775;Inherit;False;Property;_SnowNormalsInfluence;Snow Normals Influence;25;0;Create;True;0;0;0;False;0;False;0;0.693;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;199;-5160.332,-655.5135;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;435;-2962.282,3628.58;Inherit;False;Constant;_Float10;Float 10;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;346;-3843.867,1547.477;Inherit;False;Constant;_Float5;Float 5;16;0;Create;True;0;0;0;False;0;False;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;469;-4813.781,-272.5479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;396;-3823.021,1681.393;Inherit;False;394;WindOutput;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;436;-3065.484,3959.394;Inherit;False;Property;_VertexAOStrength;Vertex AO Strength;8;0;Create;True;0;0;0;False;0;False;1;0.59;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;-2621.953,462.5898;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;424;-4932.169,-501.7464;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-2377.904,-1541.897;Inherit;False;SnowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;432;-2974.169,3816.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;361;-2639.97,837.307;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;-3605.036,1553.082;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;390;-2445.756,457.2948;Inherit;False;LeafXZNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-4371.909,-626.8166;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;434;-2765.774,3670.992;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-4440.704,-473.0053;Inherit;False;Property;_SnowMaskSharpness;Snow Mask Sharpness;24;0;Create;True;0;0;0;False;0;False;1.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;-4611.771,-240.9756;Inherit;False;221;SnowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-4547.784,-104.4181;Inherit;False;Constant;_Float4;Float 4;15;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;389;-2454.202,830.4278;Inherit;False;LeafYNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;388;-3226.934,1491.087;Inherit;False;389;LeafYNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;33;-3280.122,2341.263;Inherit;False;857.4437;315.9554;;6;395;37;70;68;36;69;Mask Wind by UV2;1,0.5394964,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;393;-3221.376,1687.225;Inherit;False;390;LeafXZNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;358;-3386.919,1551.272;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PowerNode;193;-4133.078,-625.7298;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-4232.19,-119.4016;Inherit;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;437;-2523.591,3665.965;Inherit;False;VertexAO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-4361.301,-237.1094;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;-3238.685,1308.987;Inherit;False;390;LeafXZNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;379;-2998.272,1726.234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-3414.404,-249.8037;Inherit;False;437;VertexAO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3024.892,2553.954;Inherit;False;Constant;_Float7;Float 7;3;0;Create;True;0;0;0;False;0;False;2.34;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;-2994.742,1548.77;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;-2999.054,1354.75;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;213;-4022.684,-239.3858;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-3257.601,2391.432;Inherit;True;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;191;-3869.476,-626.0708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;444;-3384.404,-130.8038;Inherit;False;Property;_SnowVertexAOInfluence;Snow Vertex AO Influence;26;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;443;-3296.404,-350.8034;Inherit;False;Constant;_Float11;Float 11;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;442;-3104.403,-314.8034;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;-3673.19,-626.4229;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-2766.747,1420.37;Inherit;False;Global;TFW_LeafFlutterStrength;TFW_LeafFlutterStrength;12;0;Create;True;0;0;0;False;0;False;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;360;-2726.713,1553.83;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;68;-2986.225,2409.786;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;386;-2494.304,1536.509;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;395;-2854.496,2524.248;Inherit;False;394;WindOutput;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;414;-2532.292,1318.868;Inherit;False;Property;_LeafFlutterStrength;Leaf Flutter Strength;20;0;Create;True;0;0;0;False;0;False;0;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;-2823.126,2413.056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;-3096.403,-510.8036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;179;-2958.852,-1852.984;Inherit;True;Property;_MainTex;Albedo;1;0;Create;False;0;0;0;False;0;False;-1;None;15e8048e4434ad44fb5d6b22a14e9535;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;450;-2957.751,-1652.783;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.7174404,0.735849,0.6421324,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-2646.86,2973.299;Inherit;False;Property;_WindStrength;Wind Strength;16;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;413;-2333.292,1462.868;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;209;-2912.117,-608.6377;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-2634.584,2402.96;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;281;-2428.871,1687.646;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;-2193.474,1571.676;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;-2756.404,-614.9927;Inherit;False;SnowBlendMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;487;-2569.806,-1796.771;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2266.886,2815.74;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-1944.329,1567.018;Inherit;False;LeafWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-2379.211,-1462.155;Inherit;False;TranslucencyMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-1117.456,559.41;Inherit;False;227;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-2376.597,-1386.334;Inherit;False;SmoothnessMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;-2567.658,-1645.88;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-2085.587,2809.709;Inherit;False;MainWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;229;-2380.76,-1742.366;Inherit;False;AlbedoMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;-1113.693,430.8527;Inherit;False;222;TranslucencyMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;230;-89.11208,-519.9927;Inherit;False;229;AlbedoMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;8.073214,948.6219;Inherit;False;215;MainWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;5.073214,861.6219;Inherit;False;216;LeafWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-158.5767,106.046;Inherit;False;223;SmoothnessMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;-2383.679,-1650.778;Inherit;False;OpacityMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-196.6466,200.7104;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0;0.116;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;208;-874.7915,564.3204;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;210;-133.4714,-435.2243;Inherit;False;Constant;_Color0;Color 0;16;0;Create;True;0;0;0;False;0;False;0.6855198,0.726607,0.745283,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;228;-115.8811,-256.7136;Inherit;False;227;SnowBlendMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;147.0057,183.9206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;187;151.9637,-443.2917;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;438;102.9304,286.7244;Inherit;False;437;VertexAO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;82.8101,-7.59094;Inherit;False;421;FinalNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;219;221.0732,890.6219;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-702.2507,506.6763;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;477;-521.9061,916.072;Inherit;False;Property;_AlphaCutoff;Alpha Cutoff;0;0;Fetch;True;0;0;0;False;0;False;0.5;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;236;93.22704,487.9744;Inherit;False;235;OpacityMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;515.4592,128.1971;Half;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TriForge/Winter Forest/Leaf;False;False;False;False;False;False;True;False;True;False;True;True;True;False;True;False;False;False;False;False;True;Off;0;False;-1;0;False;-1;False;5;False;-1;5;False;-1;False;5;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;255;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;1;False;-1;10;False;-1;0;1;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;TriForge/Winter Forest/Leaf - No Translucency;-1;9;-1;-1;0;False;0;0;False;-1;-1;0;True;477;3;Pragma;instancing_options procedural:setup;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Include;VS_indirect.cginc;False;9e72312817e6e10468532362fcec98c2;Custom;0;0;False;1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;186;5;404;0
WireConnection;220;0;186;0
WireConnection;417;0;234;0
WireConnection;418;0;417;2
WireConnection;416;0;417;2
WireConnection;416;1;418;0
WireConnection;415;0;417;0
WireConnection;415;1;417;1
WireConnection;415;2;416;0
WireConnection;427;1;234;0
WireConnection;427;0;415;0
WireConnection;401;0;400;0
WireConnection;401;1;402;0
WireConnection;288;0;401;0
WireConnection;421;0;427;0
WireConnection;363;0;401;0
WireConnection;451;0;428;1
WireConnection;476;10;77;0
WireConnection;476;7;6;0
WireConnection;457;0;385;0
WireConnection;457;1;458;0
WireConnection;429;0;451;0
WireConnection;429;1;430;0
WireConnection;364;0;363;0
WireConnection;283;0;288;0
WireConnection;431;0;429;0
WireConnection;431;1;433;0
WireConnection;365;0;364;0
WireConnection;365;1;457;0
WireConnection;394;0;476;0
WireConnection;282;0;283;0
WireConnection;282;1;457;0
WireConnection;199;0;422;0
WireConnection;469;0;189;0
WireConnection;469;1;470;0
WireConnection;355;0;282;0
WireConnection;355;1;356;0
WireConnection;424;0;425;0
WireConnection;424;1;199;2
WireConnection;424;2;426;0
WireConnection;221;0;180;1
WireConnection;432;0;431;0
WireConnection;361;0;365;0
WireConnection;361;1;362;0
WireConnection;345;0;346;0
WireConnection;345;1;396;0
WireConnection;390;0;355;0
WireConnection;190;0;424;0
WireConnection;190;1;469;0
WireConnection;434;0;435;0
WireConnection;434;1;432;0
WireConnection;434;2;436;0
WireConnection;389;0;361;0
WireConnection;358;0;345;0
WireConnection;193;0;190;0
WireConnection;193;1;194;0
WireConnection;437;0;434;0
WireConnection;204;0;225;0
WireConnection;204;1;205;0
WireConnection;379;0;393;0
WireConnection;379;1;358;2
WireConnection;376;0;388;0
WireConnection;376;1;358;1
WireConnection;375;0;392;0
WireConnection;375;1;358;0
WireConnection;213;0;204;0
WireConnection;213;1;214;0
WireConnection;191;0;193;0
WireConnection;442;0;443;0
WireConnection;442;1;439;0
WireConnection;442;2;444;0
WireConnection;202;0;191;0
WireConnection;202;1;213;0
WireConnection;360;0;375;0
WireConnection;360;1;376;0
WireConnection;360;2;379;0
WireConnection;68;0;36;2
WireConnection;68;1;69;0
WireConnection;386;0;387;0
WireConnection;386;1;360;0
WireConnection;70;0;68;0
WireConnection;441;0;202;0
WireConnection;441;1;442;0
WireConnection;413;0;414;0
WireConnection;413;1;386;0
WireConnection;209;0;441;0
WireConnection;37;0;70;0
WireConnection;37;1;395;0
WireConnection;299;0;413;0
WireConnection;299;1;281;2
WireConnection;227;0;209;0
WireConnection;487;0;179;0
WireConnection;487;1;450;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;216;0;299;0
WireConnection;222;0;180;2
WireConnection;223;0;180;4
WireConnection;447;0;179;4
WireConnection;447;1;450;4
WireConnection;215;0;39;0
WireConnection;229;0;487;0
WireConnection;235;0;447;0
WireConnection;208;0;231;0
WireConnection;211;0;232;0
WireConnection;211;1;212;0
WireConnection;187;0;230;0
WireConnection;187;1;210;0
WireConnection;187;2;228;0
WireConnection;219;0;217;0
WireConnection;219;1;218;0
WireConnection;207;0;226;0
WireConnection;207;1;208;0
WireConnection;0;0;187;0
WireConnection;0;1;461;0
WireConnection;0;4;211;0
WireConnection;0;5;438;0
WireConnection;0;7;207;0
WireConnection;0;10;236;0
WireConnection;0;11;219;0
ASEEND*/
//CHKSM=25AF28ED64AB5FA3AAE77CC6A4FFC2B406D5427F