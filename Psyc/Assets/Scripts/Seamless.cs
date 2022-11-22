using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Seamless : MonoBehaviour
{
    private bool _nextScene;
    
    private void OnTriggerEnter(Collider other)
    {
        _nextScene = true;
        if (_nextScene) SceneManager.LoadScene(1);
        StartCoroutine(WaitingForSceneSwitch(10));
        
        Scene currentScene = SceneManager.GetActiveScene();
        string sceneName = currentScene.name;
        if (sceneName == "Scene City") SceneManager.LoadScene(2);
    }
    private IEnumerator WaitingForSceneSwitch(float waitingtime)
    {
        yield return new WaitForSeconds(waitingtime);
    }
}
