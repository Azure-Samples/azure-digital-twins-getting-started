// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System.Collections.Generic;
using UnityEngine;

public class TwinDataScriptableObjectHolder : MonoBehaviour
{
    public List<TwinDataScriptableObject> digitalTwins;

    private void Start()
    {
        if (digitalTwins.Capacity < 1)
        {
            digitalTwins = new List<TwinDataScriptableObject>();
        }
    }
}