// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using UnityEngine;

[CreateAssetMenu(fileName = "TwinGraphData", menuName = "Scriptable Objects/Twin Data/Twin Graph Data", order = 1)]
public class TwinGraphData : ScriptableObject
{
    public TwinDataScriptableObject[] twinData;
}