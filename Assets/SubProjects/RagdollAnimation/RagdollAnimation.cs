using BzKovSoft.RagdollTemplate.Scripts.Charachter;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RagdollAnimation : MonoBehaviour
{
    private bool _isKinematic = true;

    private void Start()
    {
        //SetIsKinematic(_isKinematic);
    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(10, 70, 50, 30), "ToggleIsKinematic"))
        {
            GetComponent<IBzRagdoll>().IsRagdolled = _isKinematic = !_isKinematic;
            //SetIsKinematic(!_isKinematic);
        }

    }
    // Update is called once per frame
    void Update()
    {
        
    }

    private void SetIsKinematic(bool isKinematic)
    {
        _isKinematic = isKinematic;

        foreach (Rigidbody rb in GetComponentsInChildren<Rigidbody>())
            rb.isKinematic = isKinematic;
        GetComponent<Animator>().enabled = isKinematic;
    }
}
