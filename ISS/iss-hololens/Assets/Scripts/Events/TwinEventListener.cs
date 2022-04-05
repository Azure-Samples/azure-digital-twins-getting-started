// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using UnityEngine;

public class TwinEventListener : MonoBehaviour
{
    [SerializeField]
    private TwinGameEvent gameEvent;

    [SerializeField]
    public TwinUnityEvent response;

    private void OnEnable()
    {
        gameEvent.AddListener(this);
    }

    private void OnDisable()
    {
        gameEvent.RemoveListener(this);
    }

    public void OnEventRaised(TwinDataScriptableObject twinData)
    {
        response.Invoke(twinData);
    }
}