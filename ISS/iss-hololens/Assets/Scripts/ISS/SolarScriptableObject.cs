// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using Microsoft.Geospatial;
using UnityEngine;

/// <summary>
/// Scriptable Object for Twin data received from ADT
/// Uses SolarData as its data source
/// </summary>
[CreateAssetMenu(fileName = "SolarData", menuName = "Scriptable Objects/Twin Data/Solar Data")]
public class SolarScriptableObject : TwinDataScriptableObject
{
    private void Awake()
    {
        if(TwinData == null)
            TwinData = new SolarData();
    }
}