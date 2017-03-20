using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera)) ]
public class MyPostEffectsBase : MonoBehaviour {

	// Use this for initialization
	private void CheckResource()
	{
		bool isSupport = CheckSupport();
		if (isSupport == false)
		{
			NotSupport();
		}
	}
	private bool CheckSupport(){
		if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
		{
			return false;
		}
		return true;
	}
	private void NotSupport(){
		enabled = false;
	}
	void Start () {
		CheckResource();
	}

	protected Material CheckShaderAndCreateMaterial(Shader shader, Material material){
		if (shader == null)
		{
			return null;
		}

		if(shader.isSupported == false) return null;
		else
		{
			if ( material != null && shader == material.shader)
			{
				return material;
			}
			
			Material mat = new Material(shader);
			mat.hideFlags = HideFlags.DontSave;
			if (mat != null)
			{
				return mat;
			}
			else
			{
				return null;
			}
		}

	}
	
}
