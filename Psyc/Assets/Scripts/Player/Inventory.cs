using UnityEngine;

namespace Player
{
    public class Inventory : MonoBehaviour
    {
        public Texture crosshairTexture;
        public PlayerMove playerController;
        public PickItem[] availableItems; 

        int[] itemSlots = new int[12];
        private bool _showInventory = false;
        private float _windowAnimation = 1;
        private float _animationTimer = 0;

        private int _hoveringOverIndex = -1;
        private int _itemIndexToDrag = -1;
        private Vector2 _dragOffset = Vector2.zero;

        private PickItem _detectedItem;
        private int _detectedItemIndex;

        void Start()
        {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;

            for (int i = 0; i < itemSlots.Length; i++)
            {
                itemSlots[i] = -1;
            }
        }

        void Update()
        {
            if (Input.GetKeyDown(KeyCode.Tab))
            {
                _showInventory = !_showInventory;
                _animationTimer = 0;

                if (_showInventory)
                {
                    Cursor.visible = true;
                    Cursor.lockState = CursorLockMode.None;
                }
                else
                {
                    Cursor.visible = false;
                    Cursor.lockState = CursorLockMode.Locked;
                }
            }

            if (_animationTimer < 1)
            {
                _animationTimer += Time.deltaTime;
            }

            if (_showInventory)
            {
                _windowAnimation = Mathf.Lerp(_windowAnimation, 0, _animationTimer);
                playerController.canMove = false;
            }
            else
            {
                _windowAnimation = Mathf.Lerp(_windowAnimation, 1f, _animationTimer);
                playerController.canMove = true;
            }

            if (Input.GetMouseButtonDown(0) && _hoveringOverIndex > -1 && itemSlots[_hoveringOverIndex] > -1)
            {
                _itemIndexToDrag = _hoveringOverIndex;
            }

            if (Input.GetMouseButtonUp(0) && _itemIndexToDrag > -1)
            {
                if (_hoveringOverIndex < 0)
                {
                    Instantiate(availableItems[itemSlots[_itemIndexToDrag]], playerController.playerCamera.transform.position + (playerController.playerCamera.transform.forward), Quaternion.identity);
                    itemSlots[_itemIndexToDrag] = -1;
                }
                else
                {
                    (itemSlots[_itemIndexToDrag], itemSlots[_hoveringOverIndex]) = (itemSlots[_hoveringOverIndex], itemSlots[_itemIndexToDrag]);
                }
                _itemIndexToDrag = -1;
            }

            if (_detectedItem && _detectedItemIndex > -1)
            {
                if (!Input.GetKeyDown(KeyCode.F)) return;
                int slotToAddTo = -1;
                for (int i = 0; i < itemSlots.Length; i++)
                {
                    if (itemSlots[i] != -1) continue;
                    slotToAddTo = i;
                    break;
                }

                if (slotToAddTo <= -1) return;
                itemSlots[slotToAddTo] = _detectedItemIndex;
                _detectedItem.PickUpItem();
            }
        }

        void FixedUpdate()
        {
            RaycastHit hit;
            Ray ray = playerController.playerCamera.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));

            if (Physics.Raycast(ray, out hit, 2.5f))
            {
                Transform objectHit = hit.transform;

                if (objectHit.CompareTag("Respawn"))
                {
                    if ((_detectedItem == null || _detectedItem.transform != objectHit) && objectHit.GetComponent<PickItem>() != null)
                    {
                        var itemTmp = objectHit.GetComponent<PickItem>();

                        for (var i = 0; i < availableItems.Length; i++)
                        {
                            if (availableItems[i].itemName != itemTmp.itemName) continue;
                            _detectedItem = itemTmp;
                            _detectedItemIndex = i;
                        }
                    }
                }
                else
                {
                    _detectedItem = null;
                }
            }
            else
            {
                _detectedItem = null;
            }
        }

        void OnGUI()
        {
            GUI.Label(new Rect(5, 5, 200, 25), "Press 'Tab' to open Inventory");

            if (_windowAnimation < 1)
            {
                GUILayout.BeginArea(new Rect(10 - (430 * _windowAnimation), Screen.height / 2 - 200, 302, 430), GUI.skin.GetStyle("box"));

                GUILayout.Label("Inventory", GUILayout.Height(25));

                GUILayout.BeginVertical();
                for (int i = 0; i < itemSlots.Length; i += 3)
                {
                    GUILayout.BeginHorizontal();
                
                    for (int a = 0; a < 3; a++)
                    {
                        if (i + a >= itemSlots.Length) continue;
                        if (_itemIndexToDrag == i + a || (_itemIndexToDrag > -1 && _hoveringOverIndex == i + a))
                        {
                            GUI.enabled = false;
                        }

                        if (itemSlots[i + a] > -1)
                        {
                            if (availableItems[itemSlots[i + a]].itemPreview)
                            {
                                GUILayout.Box(availableItems[itemSlots[i + a]].itemPreview, GUILayout.Width(95), GUILayout.Height(95));
                            }
                            else
                            {
                                GUILayout.Box(availableItems[itemSlots[i + a]].itemName, GUILayout.Width(95), GUILayout.Height(95));
                            }
                        }
                        else
                        {
                            GUILayout.Box("", GUILayout.Width(95), GUILayout.Height(95));
                        }

                        Rect lastRect = GUILayoutUtility.GetLastRect();
                        Vector2 eventMousePositon = Event.current.mousePosition;
                        if (Event.current.type == EventType.Repaint && lastRect.Contains(eventMousePositon))
                        {
                            _hoveringOverIndex = i + a;
                            if (_itemIndexToDrag < 0)
                            {
                                _dragOffset = new Vector2(lastRect.x - eventMousePositon.x, lastRect.y - eventMousePositon.y);
                            }
                        }

                        GUI.enabled = true;
                    }
                    GUILayout.EndHorizontal();
                }
                GUILayout.EndVertical();

                if (Event.current.type == EventType.Repaint && !GUILayoutUtility.GetLastRect().Contains(Event.current.mousePosition))
                {
                    _hoveringOverIndex = -1;
                }

                GUILayout.EndArea();
            }

            if (_itemIndexToDrag > -1)
            {
                if (availableItems[itemSlots[_itemIndexToDrag]].itemPreview)
                {
                    GUI.Box(new Rect(Input.mousePosition.x + _dragOffset.x, Screen.height - Input.mousePosition.y + _dragOffset.y, 95, 95), availableItems[itemSlots[_itemIndexToDrag]].itemPreview);
                }
                else
                {
                    GUI.Box(new Rect(Input.mousePosition.x + _dragOffset.x, Screen.height - Input.mousePosition.y + _dragOffset.y, 95, 95), availableItems[itemSlots[_itemIndexToDrag]].itemName);
                }
            }

            if (_hoveringOverIndex > -1 && itemSlots[_hoveringOverIndex] > -1 && _itemIndexToDrag < 0)
            {
                GUI.Box(new Rect(Input.mousePosition.x, Screen.height - Input.mousePosition.y - 30, 100, 25), availableItems[itemSlots[_hoveringOverIndex]].itemName);
            }

            if (!_showInventory)
            {
                GUI.color = _detectedItem ? Color.green : Color.white;
                GUI.DrawTexture(new Rect(Screen.width / 2 - 4, Screen.height / 2 - 4, 8, 8), crosshairTexture);
                GUI.color = Color.white;

                if (_detectedItem)
                {
                    GUI.color = new Color(0, 0, 0, 0.84f);
                    GUI.Label(new Rect(Screen.width / 2 - 75 + 1, Screen.height / 2 - 50 + 1, 150, 20), "Press 'F' to pick '" + _detectedItem.itemName + "'");
                    GUI.color = Color.green;
                    GUI.Label(new Rect(Screen.width / 2 - 75, Screen.height / 2 - 50, 150, 20), "Press 'F' to pick '" + _detectedItem.itemName + "'");
                }
            }
        }
    }
}
