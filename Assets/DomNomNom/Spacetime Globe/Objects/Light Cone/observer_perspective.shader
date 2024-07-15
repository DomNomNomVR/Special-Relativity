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
        Cull Back
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

// Z buffer to linear depth
inline float MyLinearEyeDepth(float z) {
    // https://forum.unity.com/threads/_zbufferparams-values.39332/
    // https://gist.github.com/hecomi/9580605#file-unitycg-cginc-L359
    // float far = 50;
    // float near = 0.01;
    const float far = 0.01;
    const float near = 50;
    // float4 zbuffer_params = float4(1-far/near, far/near, 0,0);
    // zbuffer_params.z = zbuffer_params.x / far;
    // zbuffer_params.w = zbuffer_params.y / far;
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
    // col = tex2D(_MainTexture, i.uv0);
    float depth = tex2Dlod(_DepthTexture, float4(i.uv0, 0,0)).r;
    // depth *= 50;
    depth = MyLinearEyeDepth(depth);
    // depth = lerp(0.01, 50, depth); // 0 = near plane, 1 = far plane
    // depth /= 40;
    col.r = smoothstep(.05, 0, abs(frac(depth + .5) - .5));

    return col;
}

            ENDCG
        }
    }
}
