 using UnityEngine;
using System.Collections;

public class MyBloom : MyPostEffectsBase {
	public Shader bloomShader;
	private Material bloomMat;
	public Material material{
		get{ 
			bloomMat = CheckShaderAndCreateMaterial(bloomShader, bloomMat);
			return bloomMat;
		}
	}
	[RangeAttribute(1,8)]
	public int iterations = 1;
	
	[RangeAttribute(0, 3.0f)]
	public float BlurSpread = 0.5f;

	[RangeAttribute(1,8)]
	public int DownSample = 2;
	// Use this for initialization

	[RangeAttribute(0, 1)]
	public float LuminanceThreshold = 0.5f;
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
			material.SetFloat("_LuminanceThreshold", LuminanceThreshold);
			int rtW = src.width / DownSample;
			int rtH = src.height / DownSample;
			RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
			buffer.filterMode = FilterMode.Bilinear;
			Graphics.Blit(src, buffer, material, 0);
			for (int i = 0; i < iterations; i++)
			{
				material.SetFloat("_BlurSize", 1.0f + i*BlurSpread);
				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				Graphics.Blit(buffer, buffer1, material, 1);
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;
				buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				Graphics.Blit(buffer, buffer1, material, 2);
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;
			}

			material.SetTexture("_Bloom", buffer);
			Graphics.Blit(src, dest, material, 3);
			RenderTexture.ReleaseTemporary(buffer);


		}
		else{
			Graphics.Blit(src, dest);
		}
	}
}
