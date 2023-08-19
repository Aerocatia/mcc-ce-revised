#include "rasterizer_dx9_vertex_shaders_defs2.h"

float4 c[k_max_vertex_shader_constants] : register(c0);



struct VS_OUTPUT {
   float4 Pos : SV_POSITION;
   float4 D0 : COLOR0;
   float4 D1 : COLOR1;
   float4 T0 : TEXCOORD0;
// float4 T1 : TEXCOORD1;
// float4 T2 : TEXCOORD2;
// float4 T3 : TEXCOORD3;
// float4 T4 : TEXCOORD4;
};

struct VS_INPUT {
   float3 va_position           : POSITION0;       // v0
// float3 va_normal             : NORMAL0;         // v1
// float3 va_binormal           : BINORMAL0;       // v2
// float3 va_tangent            : TANGENT0;        // v3
   float4 va_color              : COLOR0;          // v9
   float4 va_color2             : COLOR1;          // v10
// float2 va_texcoord           : TEXCOORD0;       // v4
// float3 va_incident_radiosity : NORMAL1;         // v7
// float2 va_texcoord2          : TEXCOORD1;       // v8
// int2   va_node_indices       : BLENDINDICES0;   // v5
// float2 va_node_weights       : BLENDWEIGHT0;    // v6
};

// original signature:
// VS_OUTPUT main(float4 v10 : COLOR1, float4 v0 : POSITION0, float4 v9 : COLOR0)

VS_OUTPUT main(VS_INPUT i)
{
   VS_OUTPUT o = (VS_OUTPUT)0;
   half4 a0, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11;   
      
      
      
   
   // (7) lookup tables --------------------------------------------------------------------
   R_TEMP0 = V_COLOR2 * (c[DETAILOBJ_OFFSET].x);   
   a0.x = R_TEMP0.x;   
   R_DETAIL_OBJECT_FRAME_DATA = c[a0.x + C_DETAIL_OBJECT_FRAME_DATA];   
   a0.x = R_TEMP0.y;   
   R_DETAIL_OBJECT_TYPE_DATA = c[a0.x + C_DETAIL_OBJECT_TYPE_DATA];   
   a0.x = R_TEMP0.z;   
   R_DETAIL_OBJECT_CORNER_DATA = c[a0.x + C_DETAIL_OBJECT_CORNER_DATA];   
   
   // (1) position within cell --------------------------------------------------------------
   R_POSITION = V_POSITION;   
   
   // (3) fade ------------------------------------------------------------------------------
   R_EYE_VECTOR.xyz = R_POSITION.xyz + -C_EYE_POSITION;   
   R_TEMP0.w = dot(R_EYE_VECTOR.rgb, C_EYE_FORWARD.rgb);   
   
   // (6) viewer-facing transform -----------------------------------------------------------
   R_BINORMAL = c[DETAILOBJ_OFFSET].yyzy;   
   R_TANGENT.xyz = (R_BINORMAL.yzxw) * (C_EYE_FORWARD.zxyw);   
   R_TANGENT.xyz = (R_BINORMAL.zxyw) * (-C_EYE_FORWARD.yzxw) + r3;   
   R_TANGENT.w = dot(R_TANGENT.rgb, R_TANGENT.rgb);   
   R_TANGENT.w = rsqrt(abs(R_TANGENT.w));   
   R_TANGENT.xyz = (R_TANGENT.xyz) * (-R_TANGENT.w);   // X= Y^eye_forward
   
   // (4) vertex position -------------------------------------------------------------------
   // corner data .zw is {-1/2,0}, {1/2,0}, {1/2,1}, {-1/2,1}
   // PERF: we could remove a multiply if we premultiplied sprite bounds by type->size
   R_TEMP0.xy = (R_DETAIL_OBJECT_TYPE_DATA.zw) * (R_DETAIL_OBJECT_CORNER_DATA.zw);   // adjust for corner, size
   R_TEMP0.xy = (R_TEMP0.xy) * (R_DETAIL_OBJECT_FRAME_DATA.zw);   // adjust for sprite bounds
   R_POSITION.xyz = (R_TANGENT.xyz) * (R_TEMP0.x) + R_POSITION;   // horizontal
   R_POSITION.xyz = (R_BINORMAL.xyz) * (R_TEMP0.y) + R_POSITION;   // vertical
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(R_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(R_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(R_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(R_POSITION, C_VIEWPROJ_W);   
   
   // (1) output texcoords ------------------------------------------------------------------
   // corner data .xy is {0,0}, {1,0}, {1,1}, {0,1}
   o.T0.xy = (R_DETAIL_OBJECT_CORNER_DATA.xy) * (R_DETAIL_OBJECT_FRAME_DATA.zw) + R_DETAIL_OBJECT_FRAME_DATA.xy;   
   
   // (1) output color ----------------------------------------------------------------------
   o.D0.xyz = V_COLOR;   
   o.D0.w = (R_TEMP0.w) * (R_DETAIL_OBJECT_TYPE_DATA.y) + R_DETAIL_OBJECT_TYPE_DATA.x;   
   
   return o;
}
