// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using UnityEngine;

/// <summary>
/// Listens to an ADT Event and defines the response to it
/// </summary>
public class ADTEventListener : MonoBehaviour
{
    /// <summary>
    /// Event to listen to
    /// </summary>
    [SerializeField]
    private ADTGameEvent gameEvent;

    /// <summary>
    /// Action to take in response to the event
    /// </summary>
    [SerializeField]
    public ADTUnityEvent response;

    private void OnEnable()
    {
        gameEvent.RegisterListener(this);
    }

    private void OnDisable()
    {
        gameEvent.UnregisterListener(this);
    }

    /// <summary>
    /// Invokes the response upon receiving the event
    /// </summary>
    /// <param name="eventData">Data about the event</param>
    public void OnEventRaised(ADTEventData eventData)
    {
        response.Invoke(eventData);
    }
}
