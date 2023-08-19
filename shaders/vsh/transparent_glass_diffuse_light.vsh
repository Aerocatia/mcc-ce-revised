#include "rasterizer_dx9_vertex_shaders_defs2.h"

float4 c[k_max_vertex_shader_constants] : register(c0);



struct VS_OUTPUT {
   float4 Pos : SV_POSITION;
   float4 D0 : COLOR0;
   float4 D1 : COLOR1;
   float4 T0 : TEXCOORD0;
   float4 T1 : TEXCOORD1;
   float4 T2 : TEXCOORD2;
// float4 T3 : TEXCOORD3;
// float4 T4 : TEXCOORD4;
};

struct VS_INPUT {
   float3 va_position           : POSITION0;       // v0
   float3 va_normal             : NORMAL0;         // v1
   float3 va_binormal           : BINORMAL0;       // v2
   float3 va_tangent            : TANGENT0;        // v3
// float4 va_color              : COLOR0;          // v9
// float4 va_color2             : COLOR1;          // v10
   float2 va_texcoord           : TEXCOORD0;       // v4
   float3 va_incident_radiosity : NORMAL1;         // v7
   float2 va_texcoord2          : TEXCOORD1;       // v8
// int2   va_node_indices       : BLENDINDICES0;   // v5
// float2 va_node_weights       : BLENDWEIGHT0;    // v6
};

// original signature:
// VS_OUTPUT main(float4 v8 : TEXCOORD1, float4 v0 : POSITION0, float3 v1 : NORMAL0, float3 v2 : BINORMAL0, float3 v3 : TANGENT0, float4 v4 : TEXCOORD0, float3 v7 : NORMAL1)

VS_OUTPUT main(VS_INPUT i)
{
   VS_OUTPUT o = (VS_OUTPUT)0;
   half4 a0, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11;      
      
      
      
      
      
      
   
   // (1) eye vector ------------------------------------------------------------------------
   R_EYE_VECTOR.xyz = -V_POSITION.xyz + C_EYE_POSITION;   
   
   // (9) compute point light 0 attenuation -------------------------------------------------
   R_LIGHT_VECTOR.xyz = C_LIGHT0_POSITION.xyz + -V_POSITION;   
   R_LIGHT_VECTOR.w = dot(R_LIGHT_VECTOR.rgb, R_LIGHT_VECTOR.rgb);   
   R_TEMP0.w = rsqrt(abs(R_LIGHT_VECTOR.w));   
   R_LIGHT_VECTOR.xyz = (R_LIGHT_VECTOR.xyz) * (R_TEMP0.w);   
   R_LIGHT0_DIST_ATTEN = (R_LIGHT_VECTOR.w) * (-C_LIGHT0_INV_RADIUS_SQ) + V_ONE;   
   R_LIGHT0_ANGL_ATTEN = dot(R_LIGHT_VECTOR.rgb, V_NORMAL.rgb);   
   R_TEMP0.w = dot(R_LIGHT_VECTOR.rgb, C_LIGHT0_DIRECTION.rgb);   
   R_TEMP0.w = (R_TEMP0.w) * (C_LIGHT0_SPOT_A);   
   R_LIGHT0_SPOT_ATTEN = R_TEMP0.w + C_LIGHT0_SPOT_B;   
   
   // (9) compute point light 1 attenuation -------------------------------------------------
   R_LIGHT_VECTOR.xyz = C_LIGHT1_POSITION.xyz + -V_POSITION;   
   R_LIGHT_VECTOR.w = dot(R_LIGHT_VECTOR.rgb, R_LIGHT_VECTOR.rgb);   
   R_TEMP0.w = rsqrt(abs(R_LIGHT_VECTOR.w));   
   R_LIGHT_VECTOR.xyz = (R_LIGHT_VECTOR.xyz) * (R_TEMP0.w);   
   R_LIGHT1_DIST_ATTEN = (R_LIGHT_VECTOR.w) * (-C_LIGHT1_INV_RADIUS_SQ) + V_ONE;   
   R_LIGHT1_ANGL_ATTEN = dot(R_LIGHT_VECTOR.rgb, V_NORMAL.rgb);   
   R_TEMP0.w = dot(R_LIGHT_VECTOR.rgb, C_LIGHT0_DIRECTION.rgb);   
   R_TEMP0.w = (R_TEMP0.w) * (C_LIGHT1_SPOT_A);   
   R_LIGHT1_SPOT_ATTEN = R_TEMP0.w + C_LIGHT1_SPOT_B;   
   
   // (1) compute distant light 2 attenuation -----------------------------------------------
   R_LIGHT2_ATTEN = dot(V_NORMAL.rgb, -C_LIGHT2_DIRECTION.rgb);   
   
   // (1) compute distant light 3 attenuation -----------------------------------------------
   R_LIGHT3_ATTEN = dot(V_NORMAL.rgb, -C_LIGHT3_DIRECTION.rgb);   
   
   // (4) clamp all light attenuations ------------------------------------------------------
   R_LIGHT_ATTENUATION0 = max(R_LIGHT_ATTENUATION0, V_ZERO);   
   R_LIGHT_ATTENUATION1 = max(R_LIGHT_ATTENUATION1, V_ZERO);   
   R_LIGHT_ATTENUATION0 = min(R_LIGHT_ATTENUATION0, V_ONE);   
   R_LIGHT_ATTENUATION1 = min(R_LIGHT_ATTENUATION1, V_ONE);   
   
   // (8) output light contributions --------------------------------------------------------
   R_LIGHT_SUM.xyz = C_LIGHT_AMBIENT;   
   R_TEMP0.xy = (R_LIGHT_ATTENUATION0.xy) * (R_LIGHT_ATTENUATION1);   
   R_TEMP0.x = (R_TEMP0.x) * (R_LIGHT0_SPOT_ATTEN);   
   R_TEMP0.y = (R_TEMP0.y) * (R_LIGHT1_SPOT_ATTEN);   
   R_LIGHT_SUM.xyz = (R_TEMP0.x) * (C_LIGHT0_COLOR.xyz) + R_LIGHT_SUM;   
   R_LIGHT_SUM.xyz = (R_TEMP0.y) * (C_LIGHT1_COLOR.xyz) + R_LIGHT_SUM;   
   R_LIGHT_SUM.xyz = (R_LIGHT2_ATTEN) * (C_LIGHT2_COLOR.xyz) + R_LIGHT_SUM;   
   o.D0.xyz = (R_LIGHT3_ATTEN) * (C_LIGHT3_COLOR.xyz) + R_LIGHT_SUM;   
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(V_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(V_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(V_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(V_POSITION, C_VIEWPROJ_W);   
   
   // (3) output texcoords ------------------------------------------------------------------
   o.T0.xy = (V_TEXCOORD.xy) * (C_PRIMARY_DETAIL_SCALE);   // diffuse map
   o.T1.xy = (V_TEXCOORD.xy) * (C_SECONDARY_DETAIL_SCALE);   // diffuse detail map
   o.T2.xy = V_LIGHTMAP_TEXCOORD;   
   
   // (17) fog ------------------------------------------------------------------------------
   R_PLANAR_FOG_VERTEX_DENSITY = dot(V_POSITION, C_PLANAR_FOG_GRADIENT1);   // x
   R_PLANAR_FOG_EYE_DISTANCE = dot(V_POSITION, C_PLANAR_FOG_GRADIENT2);   // y
   R_ATMOSPHERIC_FOG_DENSITY = dot(V_POSITION, C_ATMOSPHERIC_FOG_GRADIENT);   // z
   R_FOG_DENSITY.xy = V_ONE + -R_FOG_DENSITY;   // {1 - x, 1 - y}
   R_FOG_DENSITY.xyz = max(R_FOG_DENSITY.xyz, V_ZERO);   // clamp to zero
   R_FOG_DENSITY.xy = (R_FOG_DENSITY.xy) * (R_FOG_DENSITY);   // {(1 - x)^2, (1 - y)^2}
   R_FOG_DENSITY.xyz = min(R_FOG_DENSITY.xyz, V_ONE);   // clamp to one
   R_FOG_DENSITY.x = R_FOG_DENSITY.x + R_FOG_DENSITY.y;   // (1 - x)^2 + (1 - y)^2
   R_FOG_DENSITY.x = min(R_FOG_DENSITY.x, V_ONE);   // clamp to one
   R_FOG_DENSITY.xy = V_ONE + -R_FOG_DENSITY;   // {1 - (1 - x)^2 - (1 - y)^2, 1 - (1 - y)^2}
   R_FOG_DENSITY.xy = (R_FOG_DENSITY.xy) * (R_FOG_DENSITY);   // {(1 - (1 - x)^2 - (1 - y)^2)^2, (1 - (1 - y)^2)^2}
   R_FOG_DENSITY.y = R_FOG_DENSITY.y + -R_FOG_DENSITY.x;   
   R_PLANAR_FOG_DENSITY = (C_PLANAR_FOG_EYE_DENSITY) * (R_FOG_DENSITY.y) + R_FOG_DENSITY.x;   
   R_PLANAR_FOG_DENSITY = (R_PLANAR_FOG_DENSITY) * (C_PLANAR_FOG_MAXIMUM_DENSITY);   // Pf
   R_ATMOSPHERIC_FOG_DENSITY = (R_ATMOSPHERIC_FOG_DENSITY) * (C_ATMOSPHERIC_FOG_MAXIMUM_DENSITY);   // Af
   R_FOG_DENSITY.xyzw = -R_FOG_DENSITY.xyzw + V_ONE;   // (1 - Af),(1 - Pf)
   o.D0.w = (R_ATMOSPHERIC_FOG_DENSITY) * (R_PLANAR_FOG_DENSITY);   // (1 - Af)*(1 - Pf)

   o.D0 = saturate(o.D0);

   return o;
}
