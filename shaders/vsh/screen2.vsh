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
      
      
      
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(V_POSITION, C_SCREENPROJ_X);   
   o.Pos.y = dot(V_POSITION, C_SCREENPROJ_Y);   
   o.Pos.z = dot(V_POSITION, C_SCREENPROJ_Z);   
   o.Pos.w = dot(V_POSITION, C_SCREENPROJ_W);   
   
   // (1) output color ----------------------------------------------------------------------
   o.D0.xyzw = V_COLOR;   
   
   // (5) texture coordinate 0 --------------------------------------------------------------
   R_TEMP0.xy = (C_SCREEN_MASK_0_1.xx) * (V_POSITION.xy);   // generate the texture coordinate
   R_TEMP0.xy = (V_TEXCOORD.xy) * (C_SCREEN_MASK_0_1.yy) + R_TEMP0.xy;   
   R_TEMP0.xy = (R_TEMP0.xy) * (C_SCREEN_SCALES_0_1.xy);   // multiply by the scale
   R_TEMP0.xy = R_TEMP0.xy + C_SCREEN_MASK_2_OFF_0.zw;   // subtract the offset
   o.T0.xy = (R_TEMP0.xy) * (C_TEXTURE_SCALE.xy);   // multiply in the texture scale and store
   
   // (5) texture coordinate 1 --------------------------------------------------------------
   R_TEMP0.xy = (C_SCREEN_MASK_0_1.zz) * (V_POSITION.xy);   // generate the texture coordinate
   R_TEMP0.xy = (V_TEXCOORD.xy) * (C_SCREEN_MASK_0_1.ww) + R_TEMP0.xy;   
   R_TEMP0.xy = (R_TEMP0.xy) * (C_SCREEN_SCALES_0_1.zw);   // multiply by the scale
   R_TEMP0.xy = R_TEMP0.xy + C_SCREEN_OFF_1_2.xy;   // subtract the offset
   o.T1.xy = (R_TEMP0.xy) * (C_SCREEN_TEXTURE_SCALES_1_2.xy);   // multiply in the scale and store
   
   // (5) texture coordinate 2 --------------------------------------------------------------
   R_TEMP0.xy = (C_SCREEN_MASK_2_OFF_0.xx) * (V_POSITION.xy);   // generate the texture coordinate
   R_TEMP0.xy = (V_TEXCOORD.xy) * (C_SCREEN_MASK_2_OFF_0.yy) + R_TEMP0.xy;   
   R_TEMP0.xy = (R_TEMP0.xy) * (C_SCREEN_SCALES_2.xy);   // multiply by the scale
   R_TEMP0.xy = R_TEMP0.xy + C_SCREEN_OFF_1_2.zw;   // subtract the offset
   o.T2.xy = (R_TEMP0.xy) * (C_SCREEN_TEXTURE_SCALES_1_2.zw);   // multiply in the scale and store

   return o;
}
