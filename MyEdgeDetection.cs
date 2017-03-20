using UnityEngine;
using System.Collections;

public class MyEdgeDetection : MyPostEffectsBase {

	public Shader edgeShader;
	private Material edgeMat = null;
	public Material material{
		get{
			edgeMat = CheckShaderAndCreateMaterial(edgeShader, edgeMat);
			return edgeMat;
		}
	}
	[RangeAttribute(0.0f, 1.0f)]
	public float edgeOnly = 0.0f;
	public Color edgeColor = Color.black;
	public Color backgroundColor = Color.white;
	
	/// <summary>
	/// OnRenderImage is called after all rendering is complete to render image.
	/// </summary>
	/// <param name="src">The source RenderTexture.</param>
	/// <param name="dest">The destination RenderTexture.</param>
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_EdgeOnly", edgeOnly);
			material.SetColor("_EdgeColor", edgeColor);
			material.SetColor("_BackgroundColor", backgroundColor);
			Graphics.Blit(src, dest, material);
		}
		else{
			Graphics.Blit(src, dest);
		}
	}
	
	
}
