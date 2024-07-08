
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
using UnityEngine.Animations;
using System;

public class TrajectoryScaler : UdonSharpBehaviour {

    private Vector3 prev_vel = new Vector3(Single.NaN, Single.NaN, Single.NaN);

    public Transform horizontal_scaler;
    public Transform vertical_scaler;

    void Start() {}

    void Update() {
        Vector3 vel = GetComponent<LookAtConstraint>().GetSource(0).sourceTransform.localPosition;
        vel.x = 0;
        if (vel == prev_vel) return; // optimization

        float v = vel.magnitude;
        if (v > 1) return; // FTL.
        float v_sq = v*v;

        Vector3 localScale = transform.localScale;
        localScale.z = Mathf.Sqrt((1 + v_sq) / (1 - v_sq));
        transform.localScale = localScale;

        update_scaler(-vel.z, horizontal_scaler);
        update_scaler(-vel.y, vertical_scaler);
    }

    void update_scaler(float v, Transform t) {
        // Modifies the transform to do a lorenz transfomation.
        float v_sq = v*v;
        float scale_x = (v+1.0f) / Mathf.Sqrt(1.0f-v_sq);
        t.localScale = new Vector3(
            scale_x,
            1.0f,
            1.0f / scale_x
        );
    }
}
