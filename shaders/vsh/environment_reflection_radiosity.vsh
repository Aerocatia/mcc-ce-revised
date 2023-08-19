#include "rasterizer_dx9_vertex_shaders_defs2.h"

float4 c[k_max_vertex_shader_constants] : register(c0);



struct VS_OUTPUT {
   float4 Pos : SV_POSITION;
   float4 D0 : COLOR0;
   float4 D1 : COLOR1;
   float4 T0 : TEXCOORD0;
   float4 T1 : TEXCOORD1;
   float4 T2 : TEXCOORD2;
   float4 T3 : TEXCOORD3;
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
   
   //dp3 R_EYE_VECTOR.a, R_EYE_VECTOR.xyz, R_EYE_VECTOR.xyz
   //rsq R_TEMP0.a, R_EYE_VECTOR.a
   //mul R_EYE_VECTOR.rgb, R_EYE_VECTOR.rgb, R_TEMP0.a
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(V_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(V_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(V_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(V_POSITION, C_VIEWPROJ_W);   
   
   // (15) output texcoords -----------------------------------------------------------------
   R_TEMP0.x = dot(V_TEXCOORD, C_BASE_MAP_XFORM_X);   // base map
   R_TEMP0.y = dot(V_TEXCOORD, C_BASE_MAP_XFORM_Y);   
   o.T0.xy = (R_TEMP0.xy) * (C_BUMP_SCALE);   // bump map
   o.T1.x = V_TANGENT.x;   
   o.T1.y = V_BINORMAL.x;   
   o.T1.z = V_NORMAL.x;   
   o.T2.x = V_TANGENT.y;   
   o.T2.y = V_BINORMAL.y;   
   o.T2.z = V_NORMAL.y;   
   o.T3.x = V_TANGENT.z;   
   o.T3.y = V_BINORMAL.z;   
   o.T3.z = V_NORMAL.z;   
   o.T1.w = dot(R_EYE_VECTOR.rgb, V_TANGENT.rgb);   
   o.T2.w = dot(R_EYE_VECTOR.rgb, V_BINORMAL.rgb);   
   o.T3.w = dot(R_EYE_VECTOR.rgb, V_INCIDENT_RADIOSITY.rgb);   

   return o;
}
