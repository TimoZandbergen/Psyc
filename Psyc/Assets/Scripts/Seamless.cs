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
        if (_nextScene) SceneManager.LoadScene(1);
        //StartCoroutine(WaitingForNextSceneSwitch(10));
        
        Scene currentScene = SceneManager.GetActiveScene();
        string sceneName = currentScene.name;
        if (sceneName == "Timo_Map") SceneManager.LoadScene(2);
    }
    /*private IEnumerator WaitingForNextSceneSwitch(float waitingtime)
    {
        yield return new WaitForSeconds(waitingtime);
    }*/
}
