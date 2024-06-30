
using UdonSharp;
using UnityEngine;
using UnityEngine.Animations;
using VRC.SDKBase;
using VRC.Udon;

public class VelocityPickup : UdonSharpBehaviour
{
    PositionConstraint constraint;
    void OnPickup() {
        constraint.constraintActive = true;
    }
    void OnDrop() {
        constraint.constraintActive = false;
        transform.position = constraint.transform.position;
    }
}
