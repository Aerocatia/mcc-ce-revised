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
      
      
      
      
      
      
   
   // (5) transform incident radiosity ------------------------------------------------------
   R_TEMP0.rgb = V_INCIDENT_RADIOSITY;   // we can't read two v[] regs in one instruction
   if (!any(R_TEMP0.rgb)) R_TEMP0.rgb = float3(0, 0, 1.f/65535.f);
   
   R_INCIDENT_RADIOSITY.x = dot(R_TEMP0.rgb, V_TANGENT.rgb);   
   R_INCIDENT_RADIOSITY.y = dot(R_TEMP0.rgb, V_BINORMAL.rgb);   
   R_INCIDENT_RADIOSITY.z = dot(R_TEMP0.rgb, V_NORMAL.rgb);   
   R_INCIDENT_RADIOSITY.w = dot(R_TEMP0.rgb, R_TEMP0.rgb);   
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(V_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(V_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(V_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(V_POSITION, C_VIEWPROJ_W);   
   
   // (1) output radiosity accuracy ---------------------------------------------------------
   o.D0.w = R_INCIDENT_RADIOSITY.w;   
   
   // (7) output texcoords ------------------------------------------------------------------
   R_TEMP0.x = dot(V_TEXCOORD, C_BASE_MAP_XFORM_X);   // base map
   R_TEMP0.y = dot(V_TEXCOORD, C_BASE_MAP_XFORM_Y);   
   o.T0.xy = (R_TEMP0.xy) * (C_BUMP_SCALE);   // bump map
   o.T1.xy = (R_TEMP0.xy) * (C_SELF_ILLUMINATION_SCALE);   
   o.T2.xy = V_LIGHTMAP_TEXCOORD;   
   R_INCIDENT_RADIOSITY.w = rsqrt(abs(R_INCIDENT_RADIOSITY.w));   
   o.T3.xyz = (R_INCIDENT_RADIOSITY.w) * (R_INCIDENT_RADIOSITY);   
   
   // (9) ouput fake lighting ---------------------------------------------------------------
   R_FAKE_LIGHT_SUM.xyz = C_FAKE_LIGHT_AMBIENT;   
   R_FAKE_LIGHT_SUM.w = dot(V_NORMAL.rgb, C_FAKE_LIGHT0_DIRECTION.rgb);   
   R_FAKE_LIGHT_SUM.w = (R_FAKE_LIGHT_SUM.w) * (C_FAKE_LIGHT0_INTENSITY);   
   R_FAKE_LIGHT_SUM.w = max(R_FAKE_LIGHT_SUM.w, V_ZERO);   
   R_FAKE_LIGHT_SUM.xyz = (R_FAKE_LIGHT_SUM.w) * (C_FAKE_LIGHT_COLOR.xyz) + R_FAKE_LIGHT_SUM;   
   R_FAKE_LIGHT_SUM.w = dot(V_NORMAL.rgb, C_FAKE_LIGHT1_DIRECTION.rgb);   
   R_FAKE_LIGHT_SUM.w = (R_FAKE_LIGHT_SUM.w) * (C_FAKE_LIGHT1_INTENSITY);   
   R_FAKE_LIGHT_SUM.w = max(R_FAKE_LIGHT_SUM.w, V_ZERO);   
   o.D0.xyz = (R_FAKE_LIGHT_SUM.w) * (C_FAKE_LIGHT_COLOR.xyz) + R_FAKE_LIGHT_SUM;   
   o.D0 = saturate(o.D0);

   return o;
}
