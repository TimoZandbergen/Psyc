using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMove : MonoBehaviour
{
    public CharacterController controller;
    [SerializeField] private float speed = 12f;
    [SerializeField] private float sprintspeed = 16f;
    [SerializeField] private float gravity = -9.81f;

    public Transform groundCheck;
    public float groundDistance = 0.4f;
    public LayerMask groundMask;

    private Vector3 _velocity;
    private bool _isGrounded;

    // Update is called once per frame
    void Update()
    {
        _isGrounded = Physics.CheckSphere(groundCheck.position, groundDistance, groundMask);

        if(_isGrounded && _velocity.y < 0) _velocity.y = -2f;
        
        var x = Input.GetAxis("Horizontal");
        var z = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * z;

        controller.Move(move * speed * Time.deltaTime);  
            
        _velocity.y += gravity * Time.deltaTime;

        controller.Move(_velocity * Time.deltaTime);

        if (Input.GetKeyDown(KeyCode.LeftShift)) speed = sprintspeed;
        else if (Input.GetKeyUp(KeyCode.LeftShift)) speed = 4f;


    }
}