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
// int2   va_node_indices       : BLENDINDICES0;   // v5
// float2 va_node_weights       : BLENDWEIGHT0;    // v6
};

// original signature:
// VS_OUTPUT main(float4 v4 : TEXCOORD0, float4 v0 : POSITION0, float3 v1 : NORMAL0, float3 v2 : BINORMAL0, float3 v3 : TANGENT0)

VS_OUTPUT main(VS_INPUT i)
{
   VS_OUTPUT o = (VS_OUTPUT)0;
   half4 a0, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11;      
      
      
      
      
   
   // (1) compute eye vector ----------------------------------------------------------------
   R_EYE_VECTOR.xyz = -V_POSITION.xyz + C_EYE_POSITION;   
   
   // (3) compute reflection vector ---------------------------------------------------------
   R_REFLECTION_VECTOR.x = dot(R_EYE_VECTOR.rgb, V_NORMAL.rgb);   
   R_REFLECTION_VECTOR.xyz = (R_REFLECTION_VECTOR.x) * (V_NORMAL);   
   R_REFLECTION_VECTOR.xyz = (R_REFLECTION_VECTOR.xyz) * (C_TWO) + -R_EYE_VECTOR;   
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(V_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(V_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(V_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(V_POSITION, C_VIEWPROJ_W);   
   
   // (12) output texcoords -----------------------------------------------------------------
   // we have to compute the z- axis by the cross product of the x- and y- axes
   R_TEMP1 = C_TEXTURE0_XFORM_Y;   
   R_TEMP0 = (C_TEXTURE0_XFORM_X.yzxw) * (R_TEMP1.zxyw);   
   R_TEMP0 = (-R_TEMP1.yzxw) * (C_TEXTURE0_XFORM_X.zxyw) + R_TEMP0;   
   o.T0.x = dot(R_REFLECTION_VECTOR.rgb, C_TEXTURE0_XFORM_X.rgb);   
   o.T0.y = dot(R_REFLECTION_VECTOR.rgb, C_TEXTURE0_XFORM_Y.rgb);   
   o.T0.z = dot(R_REFLECTION_VECTOR.rgb, R_TEMP0.rgb);   
   o.T1.x = dot(V_TEXCOORD, C_TEXTURE1_XFORM_X);   
   o.T1.y = dot(V_TEXCOORD, C_TEXTURE1_XFORM_Y);   
   o.T2.x = dot(V_TEXCOORD, C_TEXTURE2_XFORM_X);   
   o.T2.y = dot(V_TEXCOORD, C_TEXTURE2_XFORM_Y);   
   o.T3.x = dot(V_TEXCOORD, C_TEXTURE3_XFORM_X);   
   o.T3.y = dot(V_TEXCOORD, C_TEXTURE3_XFORM_Y);   
   
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
   R_PLANAR_FOG_DENSITY = (R_ATMOSPHERIC_FOG_DENSITY) * (R_PLANAR_FOG_DENSITY);   // (1 - Af)*(1 - Pf)
   
   // (6) fade ------------------------------------------------------------------------------
   // PERF: we don't always need all this crap
   R_TEMP0.x = dot(V_NORMAL.rgb, -C_EYE_FORWARD.rgb);   
   R_TEMP0.x = max(R_TEMP0.x, -R_TEMP0.x);   
   R_TEMP0.y = V_ONE + -R_TEMP0.x;   
   R_TEMP0.xy = (R_TEMP0.xy) * (R_PLANAR_FOG_DENSITY);   
   o.D0.w = (R_PLANAR_FOG_DENSITY) * (C_TRANSLUCENCY);   // no fade
   o.D1.xyzw = (R_TEMP0.xxxy) * (C_TRANSLUCENCY);   // fade-when-perpendicular(w), parallel(xyz)

   return o;
}
