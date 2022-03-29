using Microsoft.MixedReality.Toolkit.Utilities;
using UnityEngine;
using UnityEngine.Events;

public class EarthFaceLatLon : TelemetryListener
{
    public Easing easing;
    private Quaternion targetAngle;
    private Quaternion fromAngle;
    private Quaternion currentAngle;
    
    public bool useLocalRotation;

    public UnityEvent<float, float> OnLatLonUpdated;
    
    public void SetAngle(float lat, float lon)
    {
        fromAngle = currentAngle;
        targetAngle = Quaternion.Euler(lat, lon, 0);
        easing.Start();
    }

    private void Update()
    {
        if(!easing.IsPlaying())
            return;
            
        easing.OnUpdate();
        
        currentAngle = Quaternion.Slerp(fromAngle, targetAngle, easing.GetCurved());
        if(useLocalRotation)
            transform.localRotation = currentAngle;
        else
            transform.rotation = currentAngle;
    }

    public override void OnTwinUpdate(PropertyMessage message)
    {
        var lat = float.Parse(message.patch["/Latitude"]);
        var lon = float.Parse(message.patch["/Longitude"]);
        SetAngle(lat, lon);
        
        OnLatLonUpdated?.Invoke(lat,lon);
    }
}
