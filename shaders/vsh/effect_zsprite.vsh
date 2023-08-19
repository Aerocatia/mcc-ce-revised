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
};

struct VS_INPUT {
   float3 va_position           : POSITION0;       // v0
   float4 va_color              : COLOR0;          // v9
   float2 va_texcoord           : TEXCOORD0;       // v4
   float2 va_texcoord2          : TEXCOORD1;       // v8
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
   
   // (2) output easy texcoords -------------------------------------------------------------
   o.T0.xy = V_TEXCOORD;   
   o.T1.xy = V_TEXCOORD2;   
   
   PART_CAM_DIST = dot(R_POSITION, C_ZSPRITE_CAMERA_PLANE);   //
   
   //----------------------------NOTE: C_ZSPRITE_PARAMS= {q, -q*zn, r, znear}--------------------
   
   // (6) clamp r if necessary to not go through znear --------------------------------------
   
   // PART_ZNEAR_DIST= (z-znear)
   PART_ZNEAR_DIST = PART_CAM_DIST;   
   PART_ZNEAR_DIST = PART_ZNEAR_DIST - ZNEAR;   
   
   // ONE_IF_CLAMPING= (r >= (z-znear))?1.0:0.0
   ONE_IF_CLAMPING = step(PART_ZNEAR_DIST, PART_RAD);   
   
   // ZERO_IF_CLAMPING= (R_TEMP1.z)?0:1
   ZERO_IF_CLAMPING = V_ONE - ONE_IF_CLAMPING;   
   
   // NEW_RAD= new radius
   NEW_RAD = (ONE_IF_CLAMPING) * (PART_ZNEAR_DIST);   
   NEW_RAD = (ZERO_IF_CLAMPING) * (PART_RAD) + NEW_RAD;   
   
   // DEBUG
   //mov NEW_RAD, PART_RAD
	
	
	//normal z (og xbox and pc):
	//d(z) = zf(z-zn)/((zf-zn)z)
	//q = zf / (zf - zn)
	
	//reversed z (mcc):
	//d(z) = zn(z-zf)/((zn-zf)z) = q*(z-zf)/z
	//q = zn / (zn - zf)
	//d(z-r*s) = (-q*r*s + q*z - q*zf)/(-r*s + z)
	//ZSPR_Q= zn/(zn-zf)
	//ZSPR_NEG_Q_ZN -zf * ZSPR_Q
	
	// normal z:
   // q = zFar / (zNear - zFar)
   //
   // homogenized (z) = (q*z + -q*zNear) / (-z)
   // homogenized (z+radius*scale) = (radius*scale*q + q*z + -q*zNear) / (-radius*scale + -z)
   // 
   // zsprite's depth value for pixel:
   //
   // float2 texValues = (zSpriteTexValue, 1);  // Some textures have 0 in blue channel
   // float z = dot(T2.yz, texValues);
   // float w = dot(T3.yz, texValues);
   // float zspriteDepth = z / w;
   //

   // (3) T2= {0, -r*q, q*z-q*zn} ---------------------------------------------------------------
   o.T2.xw = V_ZERO;   
   o.T2.y = ZSPR_Q * (-NEW_RAD);   
   o.T2.z = ZSPR_Q * (PART_CAM_DIST) + ZSPR_NEG_Q_ZN;   
   
   // (3) T3= {0, -r, z} --------------------------------------------------------------------
   o.T3.xw = V_ZERO;   
   o.T3.y = -NEW_RAD;   
   o.T3.z = PART_CAM_DIST;   
   
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
