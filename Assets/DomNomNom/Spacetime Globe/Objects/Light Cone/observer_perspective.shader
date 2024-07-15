// Copyright DomNomNom 2024

Shader "DomNomNom/observer_perspective" {
    Properties {
        _MainTexture ("MainTexture", 2D) = "white" {}
        _DepthTexture ("DepthTexture", 2D) = "white" {}
        [HDR]_Tint("Tint", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {"IgnoreProjector"="True" "RenderType"="Opaque"}
        // ZWrite Off
        Cull Off
        // Blend one one
        LOD 100
        // GrabPass{ }

        Pass {

CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

sampler2D _MainTexture;
sampler2D _DepthTexture;
float4 _MainTexture_ST;

float4 _Tint;

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

#define TAU 6.28318530718

// Z buffer to linear depth
inline float MyLinearEyeDepth(float z) {
    // https://forum.unity.com/threads/_zbufferparams-values.39332/
    // https://gist.github.com/hecomi/9580605#file-unitycg-cginc-L359
    const float far = 0.01;  // still not sure why it works when these are inverted.
    const float near = 50;
    const float zbuffer_params_z = (1-far/near) / far;
    const float zbuffer_params_w = 1/near;
    return 1.0 / (zbuffer_params_z * z + zbuffer_params_w);
}
inline float LinearEyeDepth2( float z ){
    return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
}

float4 frag (v2f i) : SV_Target {
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    float4 col = float4(0,0,0,1);
    // float depth = MyLinearEyeDepth(tex2Dlod(_DepthTexture, float4(i.uv0, 0,0)).r);
    // col = tex2D(_MainTexture, i.uv0);

    float2 uv = (i.uv0 - .5)*2; // coordinates from center
    float theta = atan2(uv.y, uv.x);
    float over_angle_compensation = .98;  // our camera renders at > 90 degrees, try to sample at 90 degrees
    float2 uv2 = over_angle_compensation * float2(cos(theta), sin(theta));
    uv2 = (uv2 +1) / 2;

    float r = length(uv);
    r *= 7;
    float depth = MyLinearEyeDepth(tex2D(_DepthTexture, uv2).r);
    float grid_lines = 0;
    grid_lines += smoothstep(.05, 0, abs(frac(r + .5) - .5)) * .5;
    grid_lines += smoothstep(.05 / r, 0, abs(frac(8*theta / TAU + .5) - .5));
    col += grid_lines * _Tint;

    if (depth <= r && r < depth+1) {
        col += tex2D(_MainTexture, uv2);
    }
    // col.r += ;
    // if (r > depth) {
    //     col = float4(1,.5,0,1);
    // }
    // if (length(uv) > .5*over_angle_compensation) {
    //     // col.rg = uv2;
    //     // col.b = 0;
    // }
    return col;
}

            ENDCG
        }
    }
}
