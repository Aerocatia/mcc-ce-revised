#include "rasterizer_dx9_vertex_shaders_defs2.h"

float4 c[k_max_vertex_shader_constants] : register(c0);

struct VS_OUTPUT {
   float4 Pos : SV_POSITION;
   float4 D0 : COLOR0;
   float4 D1 : COLOR1;
   float4 T0 : TEXCOORD0;
   float4 T1 : TEXCOORD1;
};

struct VS_INPUT {
   float3 va_position           : POSITION0;       // v0
   float4 va_color              : COLOR0;          // v9
   float2 va_texcoord           : TEXCOORD0;       // v4
};

VS_OUTPUT main(VS_INPUT i)
{
   VS_OUTPUT o = (VS_OUTPUT)0;
   half4 a0, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11;   
   
   // (4) transform position ----------------------------------------------------------------
   R_POSITION.x = dot(V_POSITION, C_INVERSE_XFORM_X);   
   R_POSITION.y = dot(V_POSITION, C_INVERSE_XFORM_Y);   
   R_POSITION.z = dot(V_POSITION, C_INVERSE_XFORM_Z);   
   R_POSITION.w = V_ONE;   // necessary because we can't use DPH
   
   // (4) output homogeneous point ----------------------------------------------------------
   o.Pos.x = dot(R_POSITION, C_VIEWPROJ_X);   
   o.Pos.y = dot(R_POSITION, C_VIEWPROJ_Y);   
   o.Pos.z = dot(R_POSITION, C_VIEWPROJ_Z);   
   o.Pos.w = dot(R_POSITION, C_VIEWPROJ_W);   
   
   // (7) output texcoords ------------------------------------------------------------------
   o.T0.xy = V_TEXCOORD;   
   R_TEMP0.x = dot(R_POSITION, C_VIEWPROJ_X);   
   R_TEMP0.y = dot(R_POSITION, C_VIEWPROJ_Y);   
   R_TEMP0.zw = dot(R_POSITION, C_VIEWPROJ_W);   
   o.T1.x = dot(R_TEMP0, C_TEXTURE1_XFORM_X);   
   o.T1.y = dot(R_TEMP0, C_TEXTURE1_XFORM_Y);   
   o.T1.w = R_TEMP0.w;
   
   // (2) output color ----------------------------------------------------------------------
   o.D0.xyz = V_COLOR.xyz;   
   R_TEMP1.w = V_COLOR.w;   
   
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
   R_TEMP0.w = (R_ATMOSPHERIC_FOG_DENSITY) * (R_PLANAR_FOG_DENSITY);   // (1 - Af)*(1 - Pf)
   
   // (1) output fogged/diffuse alpha ----------------------------------------------------------------------
   o.D0.w = (R_TEMP0.w) * (R_TEMP1.w);   

   return o;
}
