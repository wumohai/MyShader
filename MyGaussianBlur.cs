using UnityEngine;
using System.Collections;

public class MyGaussianBlur : MyPostEffectsBase {

	public Shader GaussianBlurShader;
	private Material GaussianMat;
	public Material material{
		get{
			GaussianMat = CheckShaderAndCreateMaterial(GaussianBlurShader, GaussianMat);
			return GaussianMat;
		}
	}

	[RangeAttribute(1,8)]
	public int iterations = 1;
	
	[RangeAttribute(0, 3.0f)]
	public float BlurSpread = 0.5f;

	[RangeAttribute(1,8)]
	public int DownSample = 2;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
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
			// int rtW = src.width ;
			// int rtH = src.height;
			// material.SetFloat("_BlurSize", 1.0f);
			// RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
			// buffer.filterMode = FilterMode.Bilinear;
			// Graphics.Blit(src, buffer, material, 0);
			// Graphics.Blit(buffer, dest, material, 1);
			// RenderTexture.ReleaseTemporary(buffer);

			int rtW = src.width / DownSample;
			int rtH = src.height / DownSample;
			RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
			buffer.filterMode = FilterMode.Bilinear;
			Graphics.Blit(src, buffer, material);
			for (int i = 0; i < iterations; i++)
			{
				material.SetFloat("_BlurSize", 1.0f + i*BlurSpread);
				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				Graphics.Blit(buffer, buffer1, material, 0);
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;
				buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				Graphics.Blit(buffer, buffer1, material, 1);
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;
			}
			Graphics.Blit(buffer, dest, material);
			RenderTexture.ReleaseTemporary(buffer);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
