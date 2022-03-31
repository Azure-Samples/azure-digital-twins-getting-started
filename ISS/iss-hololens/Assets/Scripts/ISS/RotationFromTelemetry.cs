using Microsoft.MixedReality.Toolkit.Utilities;
using UnityEngine;

/// <summary>
/// A TelemetryListener that extracts a latitude and longitude from
/// the received telemetry and rotates its attached GameObject to
/// face that direction.
/// </summary>
public class RotationFromTelemetry : TelemetryListener
{
    public Vector3 axis;
    public Easing easing;
    private float targetAngle;
    private float fromAngle;
    private float currentAngle;
    
    public bool useLocalRotation;
    
    public void SetAngle(float angle)
    {
        fromAngle = currentAngle;
        targetAngle = angle;
        easing.Start();
    }

    private void Update()
    {
        if(!easing.IsPlaying())
        return;
            easing.OnUpdate();
        
        currentAngle = Mathf.LerpAngle(fromAngle, targetAngle, easing.GetCurved());
        var newRot = Quaternion.Euler(axis * currentAngle);
        if(useLocalRotation)
            transform.localRotation = newRot;
        else
            transform.rotation = newRot;
    }

    public override void OnTwinUpdate(PropertyMessage message)
    {
        SetAngle(float.Parse(message.patch["/Value"]));
    }
}
