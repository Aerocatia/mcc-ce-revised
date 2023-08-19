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
// float3 va_normal             : NORMAL0;         // v1
// float3 va_binormal           : BINORMAL0;       // v2
// float3 va_tangent            : TANGENT0;        // v3
   float4 va_color              : COLOR0;          // v9
// float4 va_color2             : COLOR1;          // v10
   float2 va_texcoord           : TEXCOORD0;       // v4
// float3 va_incident_radiosity : NORMAL1;         // v7
// float2 va_texcoord2          : TEXCOORD1;       // v8
// int2   va_node_indices       : BLENDINDICES0;   // v5
// float2 va_node_weights       : BLENDWEIGHT0;    // v6
};

// original signature:
// VS_OUTPUT main(float4 v9 : COLOR0, float4 v0 : POSITION0, float4 v4 : TEXCOORD0)

VS_OUTPUT main(VS_INPUT i)
{
   VS_OUTPUT o = (VS_OUTPUT)0;
   half4 a0, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11;   
      
      
      
   
   // (1) output homogeneous point ----------------------------------------------------------
   o.Pos = V_POSITION;   
   
   // (8) output texcoords ------------------------------------------------------------------
   o.T0.x = dot(V_TEXCOORD, C_TEXTURE0_XFORM_X);   
   o.T0.y = dot(V_TEXCOORD, C_TEXTURE0_XFORM_Y);   
   o.T1.x = dot(V_TEXCOORD, C_TEXTURE1_XFORM_X);   
   o.T1.y = dot(V_TEXCOORD, C_TEXTURE1_XFORM_Y);   
   o.T2.x = dot(V_TEXCOORD, C_TEXTURE2_XFORM_X);   
   o.T2.y = dot(V_TEXCOORD, C_TEXTURE2_XFORM_Y);   
   o.T3.x = dot(V_TEXCOORD, C_TEXTURE3_XFORM_X);   
   o.T3.y = dot(V_TEXCOORD, C_TEXTURE3_XFORM_Y);   

   return o;
}
