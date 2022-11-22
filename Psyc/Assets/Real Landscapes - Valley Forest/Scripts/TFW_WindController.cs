using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[DisallowMultipleComponent]

public class TFW_WindController : MonoBehaviour
{
    public bool EnableWind = true;
    [Range(0.0f, 2.0f)]
    public float WindStrength = 0.5f;
    [Range(0.0f, 10.0f)]
    public float WindSpeed = 1.0f;
    [Range(0.1f, 15.0f)]
    public float WindScale = 1.0f;
    [Range(0.0f, 1.0f)]
    public float DirectionRandomness = 0.2f;
    [Range(0.0f, 5.0f)]
    public float LeafFlutterStrength = 1.0f;
    [Range(1.0f, 100.0f)]
    public float LeafFlutterScale = 10.0f;
    [Range(1.0f, 10.0f)]
    public float LeafFlutterSpeed = 1.0f;

    private Vector3 WindDirection;
    private MeshRenderer arrow;

    private void Awake()
    {
        arrow = gameObject.GetComponentInChildren<MeshRenderer>();

        if(Application.isPlaying)
        {
            arrow.enabled = false;
        }
        else
        {
            arrow.enabled = true;
        }
    }

    void Update()
    {
        Shader.SetGlobalInt("TFW_EnableWind", EnableWind ? 1 : 0);
        WindDirection = transform.forward;
        Shader.SetGlobalVector("TFW_WindDirection", WindDirection);
        Shader.SetGlobalFloat("TFW_WindStrength", WindStrength);
        Shader.SetGlobalFloat("TFW_WindSpeed", WindSpeed);
        Shader.SetGlobalFloat("TFW_WindNoiseScale", WindScale);
        Shader.SetGlobalFloat("TFW_DirectionRandomness", DirectionRandomness);
        Shader.SetGlobalFloat("TFW_LeafFlutterStrength", LeafFlutterStrength);
        Shader.SetGlobalFloat("TFW_LeafFlutterScale", LeafFlutterScale);
        Shader.SetGlobalFloat("TFW_LeafFlutterSpeed", LeafFlutterSpeed);
    }
}
