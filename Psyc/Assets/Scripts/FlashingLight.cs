using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlashingLight : MonoBehaviour
{
    public GameObject Light;
    bool OnOff = true;
    
    IEnumerator flashing(float time) 
    {
        yield return new WaitForSeconds(time);
        if (OnOff)
        {
            Light.SetActive(false);
            OnOff = false;
        }
        else
        {
            Light.SetActive(true);
            OnOff = true;
        }
    }

    void Update()
    {
        float T = Random.Range(1, 1000);
        T = T / 100;
        
        flashing(T);
    }
}
