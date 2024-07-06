
using UdonSharp;
using UnityEngine;
using UnityEngine.Animations;
using VRC.SDKBase;
using VRC.Udon;

public class VelocityPickup : UdonSharpBehaviour
{
    public PositionConstraint constraint;

    void OnPickup() {
        constraint.enabled = true;
    }

    void OnDrop() {
        constraint.enabled = false;
        transform.position = constraint.transform.position;
    }
}
