using UnityEngine;

namespace Player
{
    public class PickItem : MonoBehaviour
    {
        public string itemName = "Some Item"; 
        public Texture itemPreview;

        private void Start()
        {
            gameObject.tag = "Respawn";
        }

        public void PickUpItem()
        {
            Destroy(gameObject);
        }
    }
}