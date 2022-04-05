using System;
using Microsoft.MixedReality.Toolkit.Utilities;
using UnityEngine;

/// <summary>
/// A telemetry listener that approximates the sun's position relative to earth
/// and rotates the GameObject to face that direction.
/// </summary>
public class RotateSunOnTelemetry : TelemetryListener
{
    public Easing easing;
    private Quaternion targetAngle;
    private Quaternion fromAngle;
    private Quaternion currentAngle;

    public bool useLocalRotation;

    /// <summary>
    /// Solar lat/lon approximation
    /// Uses the time of day to calculate the suns longitude
    /// </summary>
    public void RotateToPos()
    {
        var dec = -4; // Average solar declination for March
        var timeOfDay = DateTime.UtcNow - DateTime.UtcNow.Date;
        var ra = (timeOfDay.TotalHours / 24 + 12) * 360;
        SetAngle(dec, (float)ra);
    }

    /// <summary>
    /// Set target lat/lon to rotate to
    /// </summary>
    /// <param name="lat">Latitude</param>
    /// <param name="lon">Longitude</param>
    private void SetAngle(float lat, float lon)
    {
        fromAngle = currentAngle;
        targetAngle = Quaternion.Euler(-lon, lat, 0);
        easing.Start();
    }

    /// <summary>
    /// Ease the rotation change
    /// </summary>
    private void Update()
    {
        if (!easing.IsPlaying())
            return;
        easing.OnUpdate();

        currentAngle = Quaternion.Slerp(fromAngle, targetAngle, easing.GetCurved());
        if (useLocalRotation)
            transform.localRotation = currentAngle;
        else
            transform.rotation = currentAngle;
    }

    public override void OnTwinUpdate(PropertyMessage message)
    { 
        RotateToPos();
    }
}
