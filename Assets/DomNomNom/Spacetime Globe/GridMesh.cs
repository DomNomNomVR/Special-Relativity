
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;


[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class GridMesh : UdonSharpBehaviour
{
    public int GridSize = 10;
    public Material material;

    void Awake() {
        MeshFilter filter = gameObject.GetComponent<MeshFilter>();
        var mesh = new Mesh();
        var verticies = new Vector3[(GridSize+1)*4];
        var indicies = new int[(GridSize+1)*4];

        int j = 0;
        for (int i = 0; i <= GridSize; i++) {
            verticies[j] = new Vector3(i, 0, 0);
            indicies[j] = 4 * i + 0;
            j++;
            verticies[j] = new Vector3(i, 0, GridSize);
            indicies[j] = 4 * i + 1;
            j++;

            verticies[j] = new Vector3(0, 0, i);
            indicies[j] = 4 * i + 2;
            j++;
            verticies[j] = new Vector3(GridSize, 0, i);
            indicies[j] = 4 * i + 3;
            j++;
        }

        mesh.vertices = verticies;
        mesh.SetIndices(indicies, MeshTopology.Lines, 0);
        filter.mesh = mesh;

        MeshRenderer meshRenderer = gameObject.GetComponent<MeshRenderer>();
        meshRenderer.material = material;
    }
}
