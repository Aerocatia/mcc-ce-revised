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
   
   // (4) transform normal ------------------------------------------------------------------
   R_NORMAL.x = dot(V_NORMAL.rgb, R_XFORM_X.rgb);   
   R_NORMAL.y = dot(V_NORMAL.rgb, R_XFORM_Y.rgb);   
   R_NORMAL.z = dot(V_NORMAL.rgb, R_XFORM_Z.rgb);   
   // ISSUE: we're not renormalizing after skinning - is this ok?
   //dp3 R_NORMAL.w, R_NORMAL, R_NORMAL
   //rsq R_NORMAL.w, R_NORMAL.w
   //mul R_NORMAL.xyz, R_NORMAL, R_NORMAL.w
   R_NORMAL.xyz = (R_NORMAL.xyz) * (C_NORMAL_SCALE);   // this goes away if we handle double-sided materials during import
   
   // (1) eye vector ------------------------------------------------------------------------
   R_EYE_VECTOR.xyz = -R_POSITION.xyz + C_EYE_POSITION;   
   
   // (3) compute reflection vector ---------------------------------------------------------
   R_REFLECTION_VECTOR.x = dot(R_EYE_VECTOR.rgb, R_NORMAL.rgb);   
   R_REFLECTION_VECTOR.xyz = (R_REFLECTION_VECTOR.x) * (R_NORMAL);   
   R_REFLECTION_VECTOR.xyz = (R_REFLECTION_VECTOR.xyz) * (C_TWO) + -R_EYE_VECTOR;   
   
   // (0) compute point light 0 attenuation -------------------------------------------------
   // (0) compute point light 1 attenuation -------------------------------------------------
   
   // PERF: only the primary distant light (#2) is affected by translucency
   // (3) compute distant light 2 attenuation -----------------------------------------------
   R_LIGHT_ATTENUATION0.x = dot(R_NORMAL.rgb, -C_LIGHT2_DIRECTION.rgb);   // light hitting surface directly
   R_TEMP1.w = (-R_LIGHT_ATTENUATION0.x) * (C_TRANSLUCENCY);   // light shining through surface
   R_LIGHT_ATTENUATION0.x = max(R_LIGHT_ATTENUATION0.x, R_TEMP1.w);   
   
   // (1) compute distant light 3 attenuation -----------------------------------------------
   R_LIGHT_ATTENUATION0.y = dot(R_NORMAL.rgb, -C_LIGHT3_DIRECTION.rgb);   // light hitting surface directly
   //mul R_TEMP1.w, -R_LIGHT_ATTENUATION0.y, C_TRANSLUCENCY // light shining through surface
   //max R_LIGHT_ATTENUATION0.y, R_LIGHT_ATTENUATION0.y, R_TEMP1.w
   
   // (1) clamp all light attenuations ------------------------------------------------------
   R_LIGHT_ATTENUATION0.xy = max(R_LIGHT_ATTENUATION0.xy, V_ZERO);   
   //min R_LIGHT_ATTENUATION0.xy, R_LIGHT_ATTENUATION0, V_ONE
   
   // (3) output light contributions --------------------------------------------------------
   R_LIGHT_SUM.xyz = C_LIGHT_AMBIENT;   
   R_LIGHT_SUM.xyz = (R_LIGHT_ATTENUATION0.x) * (C_LIGHT2_COLOR.xyz) + R_LIGHT_SUM;   
   o.D0.xyz = (R_LIGHT_ATTENUATION0.y) * (C_LIGHT3_COLOR.xyz) + R_LIGHT_SUM;   
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(R_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(R_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(R_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(R_POSITION, C_VIEWPROJ_W);   
   
   // (1) planar fog density ----------------------------------------------------------------
   o.D0.w = V_ZERO;   
   
   // (6) output texcoords ------------------------------------------------------------------
   R_TEMP0.x = dot(V_TEXCOORD, C_BASE_MAP_XFORM_X);   // base map
   R_TEMP0.y = dot(V_TEXCOORD, C_BASE_MAP_XFORM_Y);   
   o.T0.xy = R_TEMP0;   // diffuse map
   o.T1.xy = (R_TEMP0.xy) * (C_PRIMARY_DETAIL_SCALE);   // detail map
   o.T2.xy = R_TEMP0;   // multipurpose map
   o.T3.xyz = R_REFLECTION_VECTOR;   
   
   // (6) output reflection tint color ------------------------------------------------------
   R_EYE_VECTOR.w = dot(R_EYE_VECTOR.rgb, R_EYE_VECTOR.rgb);   // E.E
   R_EYE_VECTOR.w = rsqrt(abs(R_EYE_VECTOR.w));   // 1/|E|
   R_EYE_VECTOR = (R_EYE_VECTOR) * (R_EYE_VECTOR.w);   // E'= E/|E|
   R_EYE_VECTOR = dot(R_EYE_VECTOR.rgb, R_NORMAL.rgb);   // N.E'
   R_TINT_COLOR = (R_EYE_VECTOR) * (C_PERPENDICULAR_TINT_COLOR);   // perpendicular - parallel
   o.D1.xyzw = R_TINT_COLOR.xyzw + C_PARALLEL_TINT_COLOR;   

   o.D0 = saturate(o.D0);
   o.D1 = saturate(o.D1);
   
   return o;
}
