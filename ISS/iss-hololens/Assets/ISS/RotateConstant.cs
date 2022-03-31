using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateConstant : MonoBehaviour
{
    public Vector3 rotationVector;

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(Time.deltaTime * rotationVector);
    }
}
