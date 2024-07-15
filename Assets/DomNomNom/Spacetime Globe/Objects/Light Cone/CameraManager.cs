
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class CameraManager : UdonSharpBehaviour{
    public Camera camera;
    public Shader replacementShader;

    void Start() {
        camera.SetReplacementShader(replacementShader, "");
    }


    void Update() {
    }
}

