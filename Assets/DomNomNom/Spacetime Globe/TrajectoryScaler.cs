
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
using UnityEngine.Animations;

public class TrajectoryScaler : UdonSharpBehaviour
{
    void Start()
    {
        
    }

    void Update() {
        Vector3 vel = GetComponent<LookAtConstraint>().GetSource(0).sourceTransform.localPosition;
        Debug.Log(vel);
        vel.x = 0;
        float v = vel.magnitude;
        float v_sq = v*v;

        Vector3 localScale = transform.localScale;
        localScale.z = Mathf.Sqrt((1 + v_sq) / (1 - v_sq));
        transform.localScale = localScale;
    }
}
