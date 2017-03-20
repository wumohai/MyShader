using UnityEngine;
using System.Collections;

public class MyBrightnessSaturationAndContrast : MyPostEffectsBase {

	public Shader briSatConShader;
	private Material briSatConMat; 
	public Material material{
		get{
			briSatConMat = CheckShaderAndCreateMaterial(briSatConShader, briSatConMat); 
			return briSatConMat;
		}
	}

	[RangeAttribute(0.0f, 3.0f)]
	public float saturation = 1.0f;
	[RangeAttribute(0.0f, 3.0f)]
	public float contrast = 1.0f;
	
	[RangeAttribute(0.0f, 3.0f)]
	public float brightness = 1.0f;
	
	// Use this for initialization
	void Start () {
	
	}
	
	/// <summary>
	/// OnRenderImage is called after all rendering is complete to render image.
	/// </summary>
	/// <param name="src">The source RenderTexture.</param>
	/// <param name="dest">The destination RenderTexture.</param>
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Brightness", brightness);
			material.SetFloat("_Saturation", saturation);
			material.SetFloat("_Contrast", contrast);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
	
}
