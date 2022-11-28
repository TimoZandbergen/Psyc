using UnityEngine;

namespace Player
{
    [RequireComponent(typeof(CharacterController))]

    public class PlayerMove : MonoBehaviour
    {
        [SerializeField] private float speed = 7.5f;
        [SerializeField] private float jumpSpeed = 8.0f;
        [SerializeField] private float gravity = 20.0f;
        public Camera playerCamera;
        [SerializeField] private float lookSpeed = 2.0f;
        [SerializeField] private float lookXLimit = 60.0f;

        private CharacterController _characterController;
        private Vector3 _moveDirection = Vector3.zero;
        private Vector2 _rotation = Vector2.zero;

        [HideInInspector]
        public bool canMove = true;

        private void Start()
        {
            _characterController = GetComponent<CharacterController>();
            _rotation.y = transform.eulerAngles.y;
        }

        private void Update()
        {
            if (_characterController.isGrounded)
            {
                Vector3 forward = transform.TransformDirection(Vector3.forward);
                Vector3 right = transform.TransformDirection(Vector3.right);
                var curSpeedX = speed * Input.GetAxis("Vertical");
                var curSpeedY = speed * Input.GetAxis("Horizontal");
                _moveDirection = (forward * curSpeedX) + (right * curSpeedY);

                if (Input.GetButton("Jump"))
                {
                    _moveDirection.y = jumpSpeed;
                }
            }
            _moveDirection.y -= gravity * Time.deltaTime;

            _characterController.Move(_moveDirection * Time.deltaTime);

            if (!canMove) return;
            _rotation.y += Input.GetAxis("Mouse X") * lookSpeed;
            _rotation.x += -Input.GetAxis("Mouse Y") * lookSpeed;
            _rotation.x = Mathf.Clamp(_rotation.x, -lookXLimit, lookXLimit);
            playerCamera.transform.localRotation = Quaternion.Euler(_rotation.x, 0, 0);
            transform.eulerAngles = new Vector2(0, _rotation.y);
        }
    }
}