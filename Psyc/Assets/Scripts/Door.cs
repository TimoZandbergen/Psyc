using UnityEngine;
using UnityEngine.UI;

public class Door : MonoBehaviour
{

    bool trig, open;
    public float smooth = 2.0f;
    public float DoorOpenAngle = 90.0f;
    private Vector3 defaulRot;
    private Vector3 openRot;
    public Text txt;
    void Start()
    {
        defaulRot = transform.eulerAngles;
        openRot = new Vector3(defaulRot.x, defaulRot.y + DoorOpenAngle, defaulRot.z);
    }

    // Update is called once per frame
    void Update()
    {
        if (open)
        {
            transform.eulerAngles = Vector3.Slerp(transform.eulerAngles, openRot, Time.deltaTime * smooth);
        }
        else
        {
            transform.eulerAngles = Vector3.Slerp(transform.eulerAngles, defaulRot, Time.deltaTime * smooth);
        }
        if (Input.GetKeyDown(KeyCode.E) && trig)
        {
            open = !open;
        }
        if (trig)
        {
            if (open)
            {
                txt.text = "Close E";
            }
            else
            {
                txt.text = "Open E";
            }
        }
    }
    private void OnTriggerEnter(Collider coll)
    {
        if (coll.tag == "Player")
        {
            if (!open)
            {
                txt.text = "Close E ";
            }
            else
            {
                txt.text = "Open E";
            }
            trig = true;
        }
    }
    private void OnTriggerExit(Collider coll)
    {
        if (coll.tag == "Player")
        {
            txt.text = " ";
            trig = false;
        }
    }
}
