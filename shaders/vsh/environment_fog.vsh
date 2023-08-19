#include "rasterizer_dx9_vertex_shaders_defs2.h"

float4 c[k_max_vertex_shader_constants] : register(c0);



struct VS_OUTPUT {
   float4 Pos : SV_POSITION;
   float4 D0 : COLOR0;
   float4 D1 : COLOR1;
   float4 T0 : TEXCOORD0;
   float4 T1 : TEXCOORD1;
// float4 T2 : TEXCOORD2;
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
// float3 va_incident_radiosity : NORMAL1;         // v7
// float2 va_texcoord2          : TEXCOORD1;       // v8
// int2   va_node_indices       : BLENDINDICES0;   // v5
// float2 va_node_weights       : BLENDWEIGHT0;    // v6
};

// original signature:
// VS_OUTPUT main(float4 v4 : TEXCOORD0, float4 v0 : POSITION0, float3 v1 : NORMAL0, float3 v2 : BINORMAL0, float3 v3 : TANGENT0)

VS_OUTPUT main(VS_INPUT i)
{
   VS_OUTPUT o = (VS_OUTPUT)0;
   half4 a0, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11;      
      
      
      
      
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(V_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(V_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(V_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(V_POSITION, C_VIEWPROJ_W);   
   
   // (3) output texcoords ------------------------------------------------------------------
   o.T0.x = dot(V_POSITION, C_ATMOSPHERIC_FOG_GRADIENT);   
   o.T0.y = V_ZERO;   
   o.T1.y = dot(V_POSITION, C_PLANAR_FOG_GRADIENT1);   // vertex density
   o.T1.x = dot(V_POSITION, C_PLANAR_FOG_GRADIENT2);   // eye distance

   return o;
}
