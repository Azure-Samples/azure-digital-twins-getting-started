using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class TelemetryListener : MonoBehaviour
{
    public string twin;

    public abstract void OnTwinUpdate(PropertyMessage message);
}
