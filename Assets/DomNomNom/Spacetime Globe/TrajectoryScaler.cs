
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
using UnityEngine.Animations;
using System;

// using static Unity.Mathematics.math;
using Unity.Mathematics;

static class svd{

    static void swap(ref float x, ref float y) {
        var tmp = x;
        x = y;
        y = tmp;
    }
    static void negSwapCols(Matrix4x4 a, int col0, int col1) {
        Vector4 tmp = -a.GetColumn(col0);
        a.SetColumn(col0, a.GetColumn(col1));
        a.SetColumn(col1, tmp);
    }

    public static void sortSingularValues(ref Matrix4x4 b, ref Quaternion v) {
        float l0 = b.GetColumn(0).sqrMagnitude;
        float l1 = b.GetColumn(1).sqrMagnitude;
        float l2 = b.GetColumn(2).sqrMagnitude;

        const float sqrt_half = 0.707106781186548f;

        if (l0 < l1) {
            negSwapCols(b, 0, 1);
            v = v * new Quaternion(0f, 0f, sqrt_half, sqrt_half);
            swap(ref l0, ref l1);
        }

        if (l0 < l2){
            negSwapCols(b, 0, 2);
            v = v * new Quaternion(0f, -sqrt_half, 0f, sqrt_half);
            swap(ref l0, ref l2);
        }

        if (l1 < l2) {
            negSwapCols(b, 1, 2);
            v = v * new Quaternion(sqrt_half, 0f, 0f, sqrt_half);
        }
    }

    public static Quaternion approxGivensQuat(Vector3 pq, Vector4 mask) {
        const float c8 = 0.923879532511287f; // cos(pi/8)
        const float s8 = 0.38268343236509f; // sin(pi/8)
        const float g = 5.82842712474619f; // 3 + 2 * sqrt(2)

        var ch = 2f * (pq.x - pq.y); // approx cos(a/2)
        var sh = pq.z; // approx sin(a/2)
        var r = (g * sh * sh < ch * ch?
            new Quaternion(sh * mask.x, sh*mask.y, sh*mask.z, ch*mask.w) :
            new Quaternion(s8 * mask.x, s8*mask.y, s8*mask.z, c8*mask.w) );
        return Quaternion.Normalize(r);
    }

    public static Quaternion qrGivensQuat(Vector2 pq, Vector4 mask) {
        var l = pq.magnitude;
        var sh = l > k_EpsilonNormalSqrt ? pq.y : 0f;
        var ch = Mathf.Abs(pq.x) + Mathf.Max(l, k_EpsilonNormalSqrt);
        if (pq.x < 0f) swap(ref sh, ref ch);

        return Quaternion.Normalize(new Quaternion(
            sh * mask.x,
            sh * mask.y,
            sh * mask.z,
            ch * mask.w
        ));
    }

    public static Quaternion givensQRFactorization(Matrix4x4 b, out Matrix4x4 r) {
        var u = qrGivensQuat(new Vector2(b.GetColumn(0).x, b.GetColumn(0).y), new Vector4(0f, 0f, 1f, 1f));
        var qmt = Matrix4x4.Rotate(Quaternion.Inverse(u));
        r = qmt * b;

        var q = qrGivensQuat(new Vector2(r.GetColumn(0).x, r.GetColumn(0).z), new Vector4(0f, -1f, 0f, 1f));
        u = u * q;
        qmt = Matrix4x4.Rotate(Quaternion.Inverse(q));
        r = qmt * r;

        q = qrGivensQuat(new Vector2(r.GetColumn(1).y, r.GetColumn(1).z), new Vector4(1f, 0f, 0f, 1f));
        u = u * q;
        qmt = Matrix4x4.Rotate(Quaternion.Inverse(q));
        r = qmt * r;

        return u;
    }

    public static Quaternion jacobiIteration(Matrix4x4 s, int iterations = 5) {
        Matrix4x4 qm;
        Quaternion q;
        Quaternion v = Quaternion.identity;

        for (int i = 0; i < iterations; ++i) {
            q = approxGivensQuat(new Vector3(s.GetColumn(0).x, s.GetColumn(1).y, s.GetColumn(0).y), new Vector4(0f, 0f, 1f, 1f));
            v = v * q;
            qm = Matrix4x4.Rotate(q);
            s = qm.transpose * s * qm;

            q = approxGivensQuat(new Vector3(s.GetColumn(1).y, s.GetColumn(2).z, s.GetColumn(1).z), new Vector4(1f, 0f, 0f, 1f));
            v = v * q;
            qm = Matrix4x4.Rotate(q);
            s = qm.transpose * s * qm;

            q = approxGivensQuat(new Vector3(s.GetColumn(2).z, s.GetColumn(0).x, s.GetColumn(2).x), new Vector4(0f, 1f, 0f, 1f));
            v = v * q;
            qm = Matrix4x4.Rotate(q);
            s = qm.transpose * s * qm;
        }

        return v;
    }

    public static Vector3 singularValuesDecomposition(Matrix4x4 a, out Quaternion u, out Quaternion v) {
        u = Quaternion.identity;
        v = Quaternion.identity;

        v = jacobiIteration(a.transpose * a);
        var b = a * Matrix4x4.Rotate(v);
        sortSingularValues(ref b, ref v);
        u = givensQRFactorization(b, out var e);

        return new Vector3(e.GetColumn(0).x, e.GetColumn(1).y, e.GetColumn(2).z);
    }

    public const float k_EpsilonDeterminant = 1e-6f;
    public const float k_EpsilonRCP = 1e-9f;
    public const float k_EpsilonNormalSqrt = 1e-15f;
    public const float k_EpsilonNormal = 1e-30f;

    // public static Matrix4x4 scaleMul(Vector3 s, Matrix4x4 m) => new Matrix4x4(m.GetColumn(0) * s, m.GetColumn(1) * s, m.GetColumn(2) * s);

    // public static Vector3 rcpsafe(Vector3 x, float epsilon = k_EpsilonRCP) =>
    //     math.select(math.rcp(x), Vector3.zero, Mathf.Abs(x) < epsilon);

    // internal static Matrix4x4 svdInverse(Matrix4x4 a)
    // {
    //     var e = singularValuesDecomposition(a, out var u, out var v);
    //     var um = Matrix4x4.Rotate(u);
    //     var vm = Matrix4x4.Rotate(v);

    //     return math.mul(vm, scaleMul(rcpsafe(e, k_EpsilonDeterminant), math.transpose(um)));
    // }

    // internal static quaternion svdRotation(Matrix4x4 a)
    // {
    //     singularValuesDecomposition(a, out var u, out var v);
    //     return math.mul(u, Quaternion.Inverse(v));
    // }
}

public class TrajectoryScaler : UdonSharpBehaviour {

    private Vector3 prev_vel = new Vector3(Single.NaN, Single.NaN, Single.NaN);

    public Transform horizontal_scaler;
    public Transform vertical_scaler;

    public float f;

    void Start() {}

    void Update() {
        Vector3 vel = GetComponent<LookAtConstraint>().GetSource(0).sourceTransform.localPosition;
        vel.x = 0;
        if (vel == prev_vel) return; // optimization

        float mag = vel.magnitude;
        if (mag > 1) return; // FTL.
        float v_sq = mag*mag;

        Vector3 localScale = transform.localScale;
        localScale.z = Mathf.Sqrt((1 + v_sq) / (1 - v_sq));
        transform.localScale = localScale;

        {
            Matrix4x4 a = Matrix4x4.identity;
            // svd.dothething();
            // quaternion q = quaternion.identity;
            // Matrix4x4 a = Matrix4x4.Rotate(q);
            // Matrix4x4 a = Matrix4x4.Rotate(0.0f,0.0f,0.0f, 0.0f,0.0f,0.0f, 0.0f,0.0f,0.0f);
            // Matrix4x4 a = Matrix4x4.identity;
            // float4x4 a = float4x4.identity;
            // Vector3 q = new Vector3(0.0f, 0.0f, 0.0f);
            // Matrix4x4 a = Matrix4x4.Rotate(q,q,q);
            Vector3 scale = svd.singularValuesDecomposition(a, out Quaternion u, out Quaternion v);
        }
    }

}


