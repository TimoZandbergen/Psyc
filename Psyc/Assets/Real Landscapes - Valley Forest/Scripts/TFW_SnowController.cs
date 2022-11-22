using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[DisallowMultipleComponent]

public class TFW_SnowController : MonoBehaviour
{
    [Range(0.0f, 1.0f)]
    public float SnowAmount = 1.0f;

    private MeshRenderer snowflake;

    private void Awake()
    {
        snowflake = gameObject.GetComponentInChildren<MeshRenderer>();

        if (Application.isPlaying)
        {
            snowflake.enabled = false;
        }
        else
        {
            snowflake.enabled = true;
        }
    }

    void Update()
    {
        Shader.SetGlobalFloat("TFW_SnowAmount", SnowAmount);
    }
}
