// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using Microsoft.Maps.Unity;
using Microsoft.MixedReality.Toolkit.UI;
using UnityEngine;

/// <summary>
/// Drives the rotation of an object around a given axis
/// based on the value of a PinchSlider
/// </summary>
[RequireComponent(typeof(PinchSlider))]
public class PinchSliderRotateTransform : MonoBehaviour
{
    public Transform target;
    public Vector3 axis;
    private PinchSlider slider;
    private bool isInteracting;
    private Vector3 defaultRot;

    public void Awake()
    {
        slider = GetComponent<PinchSlider>();
        defaultRot = target.localRotation.eulerAngles;
        ResetZoom();
    }
    
    public void OnZoomSliderUpdated(SliderEventData eventData)
    {
        if (isInteracting)
        {
            var t = eventData.NewValue;
            target.localRotation = Quaternion.Euler(defaultRot + Mathf.Lerp(180, -180, t) * axis);
        }
    }

    public void OnSliderInteractionStart()
    {
        isInteracting = true;
        
    }

    public void OnSliderInteractionEnded()
    {
        isInteracting = false;
        
    }

    public void ResetZoom()
    {
        slider.SliderValue = 0.5f;
    }
}
