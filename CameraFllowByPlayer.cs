using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFllowByPlayer : MonoBehaviour {



    //距离范围
    public float maxDistance = 22f;
    public float minDistance = 5f;
    //距离变化速度
    public float zoomSpeed = 0.2f;

    public float rotSpeed = 0.2f;
    public float distance = 15f;
    public float Roll = 30f * Mathf.PI * 2 / 360f;
    public float Rot = 0f;
    public GameObject target;
    
    //纵向角度范围
    private float maxRoll = 70f * Mathf.PI * 2 / 360;
    private float minRoll = -10f * Mathf.PI * 2 / 360;
    //纵向旋转速度
    private float rollSpeed = 0.2f;
	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {


	}

    void LateUpdate()
    {
        if (target == null)
        {
            return;
        }
        if (Camera.main == null)
        {
            return;
        }
        Zoom();
        Rotate();
        RollRotate();
        Vector3 targetPos = target.transform.position;
        Vector3 CameraPos;
        float d = distance * Mathf.Cos(Roll);
        CameraPos.y = distance * Mathf.Sin(Roll)+targetPos.y;
        CameraPos.x = d * Mathf.Sin(Rot) + targetPos.x;
        CameraPos.z = d * Mathf.Cos(Rot) + targetPos.z;
        transform.position = CameraPos;
        transform.LookAt(target.transform);
    }


    /// <summary>
    /// 远近调节
    /// </summary>
    void Zoom()
    {
        if (Input.GetAxis("Mouse ScrollWheel")>0)
        {
            if (distance>minDistance)
            {
                distance -= zoomSpeed;
            }
        }
        if (Input.GetAxis("Mouse ScrollWheel") < 0)
        {
            if (distance < maxDistance)
            {
                distance += zoomSpeed;
            }
        }
    }
    /// <summary>
    /// 纵向角度调节
    /// </summary>
    void RollRotate()
    {
        float w = Input.GetAxis("Mouse Y") * rollSpeed * 0.5f;

        Roll -= w;
        if (Roll>maxRoll)
        {
            Roll = maxRoll;
        }
        if (Roll<minRoll)
        {
            Roll = minRoll;
        }
    }
    /// <summary>
    /// 鼠标控制旋转
    /// </summary>
    void Rotate()
    {
        float w = Input.GetAxis("Mouse X") * rotSpeed;
        Rot -= w;
    }
}
