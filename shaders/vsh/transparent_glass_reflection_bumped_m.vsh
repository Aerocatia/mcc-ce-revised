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
// float3 va_incident_radiosity : NORMAL1;         // v7
// float2 va_texcoord2          : TEXCOORD1;       // v8
   int2   va_node_indices       : BLENDINDICES0;   // v5
   float2 va_node_weights       : BLENDWEIGHT0;    // v6
};

// original signature:
// VS_OUTPUT main(int2   v6 : BLENDWEIGHT0, float4 v0 : POSITION0, float3 v1 : NORMAL0, float3 v2 : BINORMAL0, float3 v3 : TANGENT0, float4 v4 : TEXCOORD0, int2   v5 : BLENDINDICES0)

VS_OUTPUT main(VS_INPUT i)
{
   VS_OUTPUT o = (VS_OUTPUT)0;
   half4 a0, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11;      
      
      
      
      
      
      
   
   // (10) build blended transform (2 nodes) ------------------------------------------------
   R_NODE_INDICES.xy = (V_NODE_INDICES.xy) * (C_NODE_INDEX_MULTIPLIER);   
   R_NODE_INDICES.xy = R_NODE_INDICES.xy + C_ONE_HALF;   
   a0.x = R_NODE0_INDEX;   
   R_XFORM_X = (V_NODE0_WEIGHT) * (c[a0.x + C_NODE_XFORM_X]);   
   R_XFORM_Y = (V_NODE0_WEIGHT) * (c[a0.x + C_NODE_XFORM_Y]);   
   R_XFORM_Z = (V_NODE0_WEIGHT) * (c[a0.x + C_NODE_XFORM_Z]);   
   a0.x = R_NODE1_INDEX;   
   R_XFORM_X = (V_NODE1_WEIGHT) * (c[a0.x + C_NODE_XFORM_X]) + R_XFORM_X;   
   R_XFORM_Y = (V_NODE1_WEIGHT) * (c[a0.x + C_NODE_XFORM_Y]) + R_XFORM_Y;   
   R_XFORM_Z = (V_NODE1_WEIGHT) * (c[a0.x + C_NODE_XFORM_Z]) + R_XFORM_Z;   
   
   // (4) transform position ----------------------------------------------------------------
   R_POSITION.x = dot(V_POSITION, R_XFORM_X);   
   R_POSITION.y = dot(V_POSITION, R_XFORM_Y);   
   R_POSITION.z = dot(V_POSITION, R_XFORM_Z);   
   R_POSITION.w = V_ONE;   // necessary because we can't use DPH
   
   // (6) transform normal ------------------------------------------------------------------
   R_NORMAL.x = dot(V_NORMAL.rgb, R_XFORM_X.rgb);   
   R_NORMAL.y = dot(V_NORMAL.rgb, R_XFORM_Y.rgb);   
   R_NORMAL.z = dot(V_NORMAL.rgb, R_XFORM_Z.rgb);   
   R_NORMAL.w = dot(R_NORMAL.rgb, R_NORMAL.rgb);   
   R_NORMAL.w = rsqrt(abs(R_NORMAL.w));   
   R_NORMAL.xyz = (R_NORMAL.xyz) * (R_NORMAL.w);   
   
   // (6) transform binormal ----------------------------------------------------------------
   R_BINORMAL.x = dot(V_BINORMAL.rgb, R_XFORM_X.rgb);   
   R_BINORMAL.y = dot(V_BINORMAL.rgb, R_XFORM_Y.rgb);   
   R_BINORMAL.z = dot(V_BINORMAL.rgb, R_XFORM_Z.rgb);   
   R_BINORMAL.w = dot(R_BINORMAL.rgb, R_BINORMAL.rgb);   
   R_BINORMAL.w = rsqrt(abs(R_BINORMAL.w));   
   R_BINORMAL.xyz = (R_BINORMAL.xyz) * (R_BINORMAL.w);   
   
   // (6) transform tangent -----------------------------------------------------------------
   R_TANGENT.x = dot(V_TANGENT.rgb, R_XFORM_X.rgb);   
   R_TANGENT.y = dot(V_TANGENT.rgb, R_XFORM_Y.rgb);   
   R_TANGENT.z = dot(V_TANGENT.rgb, R_XFORM_Z.rgb);   
   R_TANGENT.w = dot(R_TANGENT.rgb, R_TANGENT.rgb);   
   R_TANGENT.w = rsqrt(abs(R_TANGENT.w));   
   R_TANGENT.xyz = (R_TANGENT.xyz) * (R_TANGENT.w);   
   
   // (1) eye vector ------------------------------------------------------------------------
   R_EYE_VECTOR.xyz = -R_POSITION.xyz + C_EYE_POSITION;   
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(R_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(R_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(R_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(R_POSITION, C_VIEWPROJ_W);   
   
   // (13) output texcoords -----------------------------------------------------------------
   o.T0.xy = (V_TEXCOORD.xy) * (C_PRIMARY_DETAIL_SCALE);   // bump map
   o.T1.x = R_TANGENT.x;   
   o.T1.y = R_BINORMAL.x;   
   o.T1.z = R_NORMAL.x;   
   o.T2.x = R_TANGENT.y;   
   o.T2.y = R_BINORMAL.y;   
   o.T2.z = R_NORMAL.y;   
   o.T3.x = R_TANGENT.z;   
   o.T3.y = R_BINORMAL.z;   
   o.T3.z = R_NORMAL.z;   
   o.T1.w = R_EYE_VECTOR.x;   
   o.T2.w = R_EYE_VECTOR.y;   
   o.T3.w = R_EYE_VECTOR.z;   
   
   // (17) fog ------------------------------------------------------------------------------
   R_PLANAR_FOG_VERTEX_DENSITY = dot(R_POSITION, C_PLANAR_FOG_GRADIENT1);   // x
   R_PLANAR_FOG_EYE_DISTANCE = dot(R_POSITION, C_PLANAR_FOG_GRADIENT2);   // y
   R_ATMOSPHERIC_FOG_DENSITY = dot(R_POSITION, C_ATMOSPHERIC_FOG_GRADIENT);   // z
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
   o.D0.xyz = C_GLASS_ONE;   

   return o;
}
