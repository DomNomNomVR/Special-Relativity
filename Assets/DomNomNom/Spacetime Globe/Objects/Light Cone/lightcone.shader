// Copyright DomNomNom 2024

Shader "DomNomNom/lightcone" {
    Properties {
        _MainTexture ("Layer 0", 2D) = "white" {}
        [HDR]_Tint("Tint", Color) = (1,1,1,1)
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

float4 _Tint;

struct appdata {
    float4 pos_model : POSITION;
    float2 uv0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
    float4 pos_clip : SV_POSITION;
    float4 pos_model_scaled : TEXCOORD0;
    // float2 uv0 : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert (appdata v) {
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.pos_clip = UnityObjectToClipPos(v.pos_model);
    o.pos_model_scaled = v.pos_model * float4(
        length(unity_ObjectToWorld[0]),
        length(unity_ObjectToWorld[1]),
        length(unity_ObjectToWorld[2]),
        1
    );
    // o.uv0 = TRANSFORM_TEX(v.uv0, _MainTexture);
    return o;
}


float4 frag (v2f i) : SV_Target {
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    float4 col = float4(0,0,0,1);
    // col.r += frac(i.pos_model_scaled.z);
    // col.rg = frac(i.pos_model_scaled.xy);
    // col.r = r;
    col += smoothstep(fwidth(i.pos_model_scaled.x), 0, abs(i.pos_model_scaled.x));
    col += smoothstep(fwidth(i.pos_model_scaled.y), 0, abs(i.pos_model_scaled.y));
    float fw_z = fwidth(i.pos_model_scaled.z);
    col += smoothstep(fw_z, 0, abs(frac(i.pos_model_scaled.z +.5) - .5))  * min(1,.03/(fw_z));
    // col.g = fw;
    // col = tex2D(_MainTexture, i.uv0);
    col *= _Tint;
    return col;
}

            ENDCG
        }
    }
}
