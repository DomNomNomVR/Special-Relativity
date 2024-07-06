// Copyright DomNomNom 2023

Shader "DomNomNom/VelocityBounds" {
    Properties {
        _MainTexture ("Layer 0", 2D) = "white" {}
        [HDR]_MainTextureTint("Layer 0 Tint", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Cull Off
        Blend one one
        LOD 100
        // GrabPass{ }

        Pass {

CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

sampler2D _MainTexture;
float4 _MainTexture_ST;

float4 _MainTextureTint;

struct appdata  {
    float4 pos_model : POSITION;
    float2 uv0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f  {
    float4 pos_clip : SV_POSITION;
    float2 uv0 : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert (appdata v)  {
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.pos_clip = UnityObjectToClipPos(v.pos_model);
    o.uv0 = v.pos_model;
    // o.uv0 = TRANSFORM_TEX(v.uv0, _MainTexture);
    return o;
}


float3 frag (v2f i) : SV_Target  {
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    float3 col = float3(0,0,0);

    float r = 2*length(i.uv0);
    float fw = fwidth(r);

    float rim = r*r*r* smoothstep(1, 1-fw, r);
    col += .5 * rim * float3(.1, .1, .8);
    // {
    //     float wd = .5*fwidth(i.uv0.y);
    //     float line_opacity = smoothstep(2*wd, wd, abs(i.uv0.y));
    //     col += line_opacity * float3(1,1,1);
    // }

    {
        // draw a ring where we get a time dilation factor of 2.
        // 2=1/sqrt(1-v*v)
        // .75 = v*v
        float dilation2 = 0.86602540378;
        float wd = .4*fw;
        float line_opacity = smoothstep(2*wd, wd, abs(r-dilation2));
        col += line_opacity * .3* float3(1,1,1);
    }

    return col;
}

            ENDCG
        }
    }
}
