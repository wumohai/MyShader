using UnityEngine;
using System.Collections;

public class MyMotionBlurWithDepthTexture : PostEffectsBase {

	public Shader motionShader;
	private Material _motionMaterial;
	public Material motionMaterial{
		get{
			_motionMaterial = CheckShaderAndCreateMaterial(motionShader, _motionMaterial);
			return _motionMaterial;
		}
	}
	private Camera _motionCamera;
	public Camera motionCamera{
		get{
			if (_motionCamera == null)
			{
				_motionCamera = this.GetComponent<Camera>();
			}
			return _motionCamera;
		}
	}
	private Matrix4x4 previousViewProjectionMatrix;
	[RangeAttribute(0.0f, 1.0f)]
	public float blurSize = 0.5f;
	/// <summary>
	/// This function is called when the object becomes enabled and active.
	/// </summary>
	void OnEnable()
	{
		motionCamera.depthTextureMode |= DepthTextureMode.Depth;
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
			motionMaterial.SetFloat("BlurSize", blurSize);
			motionMaterial.SetMatrix("PreviousViewProjectionMatrix", previousViewProjectionMatrix);
			Matrix4x4 currentViewprojectionMatrix = motionCamera.projectionMatrix * motionCamera.worldToCameraMatrix;
			Matrix4x4 currentViewprojectionInverseMatrix = currentViewprojectionMatrix.inverse;
			motionMaterial.SetMatrix("CurrentViewprojectionInverseMatrix", currentViewprojectionInverseMatrix);
			previousViewProjectionMatrix = currentViewprojectionMatrix;
			Graphics.Blit(src, dest, motionMaterial);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
