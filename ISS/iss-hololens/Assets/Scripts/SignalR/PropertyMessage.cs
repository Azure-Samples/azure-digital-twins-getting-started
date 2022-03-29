// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;

[Serializable]
public class PropertyMessage
{
    public string TwinId { get; set; }
    public Dictionary<string, string> patch { get; set; }
}