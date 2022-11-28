using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Object = System.Object;

public class PickUp : MonoBehaviour
{
    private GameObject _weaponPickUp;
    void Start()
    {
        _weaponPickUp = GameObject.FindWithTag("Weapon");
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {
            Destroy(_weaponPickUp);
        }
    }
}
