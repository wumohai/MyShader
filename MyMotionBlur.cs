using UnityEngine;

public class MyMotionBlur : PostEffectsBase {

	public Shader motionShader;
	private Material _MotionMaterial;
	public Material motionMaterial{
		get{
			_MotionMaterial = CheckShaderAndCreateMaterial(motionShader, _MotionMaterial);
			return _MotionMaterial;
		}
	}

	[RangeAttribute(0.0f, 1f)]
	public float blurAmount = 0.5f;
	private RenderTexture accumulationTexture;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	/// <summary>
	/// This function is called when the behaviour becomes disabled or inactive.
	/// </summary>
	void OnDisable()
	{
		DestroyImmediate(accumulationTexture);
	}

	/// <summary>
	/// OnRenderImage is called after all rendering is complete to render image.
	/// </summary>
	/// <param name="src">The source RenderTexture.</param>
	/// <param name="dest">The destination RenderTexture.</param>
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (motionMaterial != null)
		{
			if (accumulationTexture == null || accumulationTexture.width != src.width || accumulationTexture.height != src.height)
			{
				DestroyImmediate(accumulationTexture);
				accumulationTexture = new RenderTexture(src.width, src.height, src.depth);
				// accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
				accumulationTexture.hideFlags = HideFlags.None;
				Graphics.Blit(src, accumulationTexture);
			}
			accumulationTexture.MarkRestoreExpected();
			motionMaterial.SetFloat("_BlurAmount", blurAmount);

			Graphics.Blit(src, accumulationTexture, motionMaterial);
			Graphics.Blit(accumulationTexture, dest);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
