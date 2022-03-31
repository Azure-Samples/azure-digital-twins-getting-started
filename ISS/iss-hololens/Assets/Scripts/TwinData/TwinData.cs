// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using UnityEngine;

/// <summary>
/// Twin Data information
/// </summary>
[Serializable]
public class TwinData
{
    [field: SerializeField]
    public string Name { get; set; }
    
    [field: SerializeField]
    public float BarValue { 
        get => GetBarValue();
        set { _barValue = value; }
    }

    private float _barValue;
    public virtual float GetBarValue() => Dial2Value * Dial3Value;
    
    [field: SerializeField]
    public virtual float Dial1Value { get; set; }
    
    [field: SerializeField]
    public virtual float Dial2Value { get; set; }
 
    [field: SerializeField]
    public virtual float Dial3Value { get; set; }
    
    [field: SerializeField]
    public string BarName { get; set; }
    
    [field: SerializeField]
    public string BarTwin { get; set; }
    
    [field: SerializeField]
    public TelemetryRangeData BarRangeData { get; set; }
    
    [field: SerializeField]
    public string Dial1Name { get; set; }
    
    [field: SerializeField]
    public string Dial1Twin { get; set; }
    
    [field: SerializeField]
    public TelemetryRangeData Dial1RangeData { get; set; }
    
    [field: SerializeField]
    public string Dial2Name { get; set; }
    
    [field: SerializeField]
    public string Dial2Twin { get; set; }
    
    [field: SerializeField]
    public TelemetryRangeData Dial2RangeData { get; set; }
    
    [field: SerializeField]
    public string Dial3Name { get; set; }
    
    [field: SerializeField]
    public TelemetryRangeData Dial3RangeData { get; set; }
    
    [field: SerializeField]
    public string Dial3Twin { get; set; }
}