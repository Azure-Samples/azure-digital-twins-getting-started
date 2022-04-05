// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using Microsoft.Geospatial;
using UnityEngine;

/// <summary>
/// Scriptable Object for data received from ADT
/// </summary>
[CreateAssetMenu(fileName = "TwinData", menuName = "Scriptable Objects/Twin Data/Twin Data")]
public class TwinDataScriptableObject : ScriptableObject
{
    public Action onDataUpdated;

    [field:SerializeField]
    public TwinData TwinData { get; protected set; }
}