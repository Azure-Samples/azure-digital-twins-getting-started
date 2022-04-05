// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// A Scriptable Object used to pass Twin events between the scene and UI
/// </summary>
[CreateAssetMenu(fileName = "TwinGameEvent", menuName = "Scriptable Objects/Events/Twin Game Event")]
public class TwinGameEvent : ScriptableObject
{
    private List<TwinEventListener> listeners =
        new List<TwinEventListener>();

    public void Raise(TwinDataScriptableObject twinData)
    {
        for (int i = listeners.Count - 1; i >= 0; i--)
        {
            if (listeners[i] != null)
            {
                listeners[i].OnEventRaised(twinData);
            }
        }
    }

    public void AddListener(TwinEventListener listener)
    {
        listeners.Add(listener);
    }

    public void RemoveListener(TwinEventListener listener)
    {
        listeners.Remove(listener);
    }
}

/// <summary>
/// A UnityEvent which passes TwinDataScriptableObject and can be setup in the Inspector
/// </summary>
[Serializable]
public class TwinUnityEvent : UnityEvent<TwinDataScriptableObject> { }