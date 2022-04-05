// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[CreateAssetMenu(fileName = "ADTGameEvent", menuName = "Scriptable Objects/Events/ADT Event")]
public class ADTGameEvent : ScriptableObject
{
    private List<ADTEventListener> listeners =
    new List<ADTEventListener>();

    public void Raise(ADTEventData eventData)
    {
        for (int i = listeners.Count - 1; i >= 0; i--)
        {
            listeners[i].OnEventRaised(eventData);
        }
    }

    public void RegisterListener(ADTEventListener listener)
    {
        listeners.Add(listener);
    }

    public void UnregisterListener(ADTEventListener listener)
    {
        listeners.Remove(listener);
    }
}

/// <summary>
/// Wrapper for data sent through Events
/// </summary>
[Serializable]
public class ADTEventData
{
    public ADTEventData(TwinData twinData)
    {
        this.twinData = twinData;
    }

    public TwinData twinData;
}

/// <summary>
/// A UnityEvent which passes ADTEventData and can be setup in the Inspector
/// </summary>
[Serializable]
public class ADTUnityEvent : UnityEvent<ADTEventData> { }