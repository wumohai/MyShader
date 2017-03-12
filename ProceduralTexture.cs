using UnityEngine;
using System.Collections;


[ExecuteInEditMode]
public class ProceduralTexture : MonoBehaviour {
	public Material material = null;
	private Texture2D m_generatedTexture = null;
	[SerializeField, SetProperty("textureWidth")]
	private int m_textureWidth = 512;
	public int textureWidth{
		get{
			return m_textureWidth;
		}
		set{
			
			m_textureWidth = value;
			_UpdateMaterial();
		}
	}

	[SerializeField, SetProperty("backgroundColor")]
	private Color m_backgroundColor = Color.white;
	public Color backgroundColor{
		get{
			return m_backgroundColor;
		}
		set{
			m_backgroundColor = value;
			_UpdateMaterial();
		}
	}
	[SerializeField, SetProperty("circleColor")]
	private Color m_circleColor = Color.yellow;
	public Color circleColor{
		get{
			return m_circleColor;
		}
		set{
			m_circleColor = value;
			_UpdateMaterial();
		}
	}

	[SerializeField, SetProperty("blurFactor")]
	private float m_blurFactor = 2.0f;
	public float blurFactor{
		get{ return m_blurFactor;}
		set{
			m_blurFactor = value;
			_UpdateMaterial();
		}
	}
	// Use this for initialization
	void Start () {
		if (material == null)
		{
			Renderer renderer = gameObject.GetComponent<Renderer>();
			if (renderer == null)
			{
				Debug.Log(" can not find a renderer");
				return;
			}
		}
		material = GetComponent<Renderer>().sharedMaterial;
	}

	private void _UpdateMaterial(){
		if (material != null)
		{
			m_generatedTexture =  _GeneratedTexture();
			material.SetTexture("_MainTex", m_generatedTexture);
		}
	}
	private Texture2D _GeneratedTexture(){
		Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);
		
		float fixX = textureWidth / 4.0f;

		float radius = textureWidth/ 10f;
		float edgeBulr = 1.0f / blurFactor;

		for (int w = 0; w < textureWidth; w++)
		{
			for (int h = 0; h < textureWidth; h++)
			{
				Color pixel = backgroundColor;
				for (int i = 0; i < 3; i++)
				{
					for (int j = 0; j < 3; j++)
					{	
						Vector2 circleCenter = new Vector2(fixX * (i+1), fixX * (j+1));
						float dist = Vector2.Distance(new Vector2(w,h), circleCenter) - radius;
						Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 1.0f), Mathf.SmoothStep(0f, 1f, dist*edgeBulr));
						pixel = _MixColor(pixel, color, color.a);
					}
				}
				
				proceduralTexture.SetPixel(w, h, pixel);
			}
		}
		proceduralTexture.Apply();
		return proceduralTexture;
	}
	private Color _MixColor(Color color0, Color color1, float mixFactor){
		Color mixColor = Color.white;
		mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
		mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
		mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
		mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
		return mixColor;
	}
}

