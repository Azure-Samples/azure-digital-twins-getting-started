// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using UnityEngine;

/// <summary>
/// Derivative of TwinData that provides the product of Dial 2 and 3 to the bar instead of a twin data source
/// </summary>
[Serializable]
public class SolarData : TwinData
{
    public override float GetBarValue() => Dial2Value * Dial3Value;
}