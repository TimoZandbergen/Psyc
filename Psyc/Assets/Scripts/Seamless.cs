using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Seamless : MonoBehaviour
{
    private bool _nextScene;
    
    private void OnTriggerEnter(Collider other)
    {
        _nextScene = true;
    }

    private void Update()
    {
        if (_nextScene) SceneManager.LoadScene(1);
    }
}
