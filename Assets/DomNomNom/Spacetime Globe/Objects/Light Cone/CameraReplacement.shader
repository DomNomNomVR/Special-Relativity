// Copyright DomNomNom 2024

Shader "DomNomNom/CameraReplacement" {
    Properties {
        _MainTexture ("Layer 0", 2D) = "white" {}
        [HDR]_MainTextureTint("Layer 0 Tint", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        // ZWrite Off
        Cull Back
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

struct appdata {
    float4 pos_model : POSITION;
    float2 uv0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
    float4 pos_clip : SV_POSITION;
    float2 uv0 : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert (appdata v) {
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.pos_clip = UnityObjectToClipPos(v.pos_model);
    o.uv0 = TRANSFORM_TEX(v.uv0, _MainTexture);
    return o;
}


float4 frag (v2f i) : SV_Target {
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    float4 col = float4(0,0,0,1);
    // col = tex2D(_MainTexture, i.uv0);
    col.r = 1;
    // col.g = _CameraDepthTexture;
    return col;
}

            ENDCG
        }
    }
}
