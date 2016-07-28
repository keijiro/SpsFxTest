using UnityEngine;

[ExecuteInEditMode]
public class StereoTest : MonoBehaviour
{
    [SerializeField] Shader _shader;

    Material _material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null)
        {
            _material = new Material(Shader.Find("Hidden/StereoTest"));
            _material.hideFlags = HideFlags.DontSave;
        }

        var temp1 = RenderTexture.GetTemporary(source.width, source.height);
        var temp2 = RenderTexture.GetTemporary(source.width, source.height);

        Graphics.Blit(source, temp1, _material, 0);
        Graphics.Blit(temp1, temp2, _material, 1);
        Graphics.Blit(temp2, destination, _material, 2);

        RenderTexture.ReleaseTemporary(temp1);
        RenderTexture.ReleaseTemporary(temp2);
    }
}
