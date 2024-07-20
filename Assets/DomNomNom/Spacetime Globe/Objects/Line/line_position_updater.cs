
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class line_position_updater : UdonSharpBehaviour {
    public Transform pos0;
    public Transform pos1;

    private LineRenderer lr;

    void Start() {
        lr = GetComponent<LineRenderer>();
    }


    void Update() {
        lr.SetPosition(0, pos0.position);
        lr.SetPosition(1, pos1.position);
    }
}
