// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using Microsoft.Unity;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json;
using UnityEngine;

public class ADTDataHandler : MonoBehaviour
{
    private SignalRService rService;

    public string url = "[SignalR-URL]";
    public TwinGraphData twinGraphData;
    private TelemetryListener[] listeners;

    private void Start()
    {
        this.RunSafeVoid(CreateServiceAsync);
        listeners = Resources.FindObjectsOfTypeAll<TelemetryListener>();
        
    }

    private void OnDestroy()
    {
        if (rService != null)
        {
            rService.OnConnected -= HandleConnected;
            rService.OnDisconnected -= HandleDisconnected;
            rService.OnPropertyMessage -= HandlePropertyMessage;
        }
    }

    /// <summary>
    /// Received a Property message from SignalR. Note, this message is received on a background thread.
    /// </summary>
    /// <param name="message">
    /// The message
    /// </param>
    private void HandlePropertyMessage(PropertyMessage message)
    {
        UnityDispatcher.InvokeOnAppThread(() =>
        {
            Debug.Log(JsonConvert.SerializeObject(message));
        });
    }

    private async Task CreateServiceAsync()
    {
        rService = new SignalRService();
        rService.OnConnected += HandleConnected;
        rService.OnDisconnected += HandleDisconnected;
        rService.OnPropertyMessage += HandlePropertyMessage;

        await rService.StartAsync(url);

        foreach (var twin in twinGraphData.twinData)
        {
            if (!string.IsNullOrWhiteSpace(twin.TwinData.BarTwin))
                rService.AddListener(twin.TwinData.BarTwin, (msg)=>
                {
                    if(float.TryParse(msg.patch["/CalibratedData"], out var val))
                        twin.TwinData.BarValue = val;
                    else if(float.TryParse(msg.patch["/Value"], out val))
                        twin.TwinData.BarValue = val;
                    
                    twin.onDataUpdated?.Invoke();
                });
            
            if (!string.IsNullOrWhiteSpace(twin.TwinData.Dial1Twin))
                rService.AddListener(twin.TwinData.Dial1Twin, (msg)=>
                {
                    if(float.TryParse(msg.patch["/CalibratedData"], out var val))
                        twin.TwinData.Dial1Value = val;
                    else if(float.TryParse(msg.patch["/Value"], out val))
                        twin.TwinData.Dial1Value = val;
                    twin.onDataUpdated?.Invoke();
                });
            
            if (!string.IsNullOrWhiteSpace(twin.TwinData.Dial2Twin))
                rService.AddListener(twin.TwinData.Dial2Twin, (msg)=>
                {
                    if(float.TryParse(msg.patch["/CalibratedData"], out var val))
                        twin.TwinData.Dial2Value = Mathf.Abs(val);
                    else if(float.TryParse(msg.patch["/Value"], out val))
                        twin.TwinData.Dial2Value = Mathf.Abs(val);
                    twin.onDataUpdated?.Invoke();
                });
            
            if (!string.IsNullOrWhiteSpace(twin.TwinData.Dial3Twin))
                rService.AddListener(twin.TwinData.Dial3Twin, (msg)=>
                {
                    if(float.TryParse(msg.patch["/CalibratedData"], out var val))
                        twin.TwinData.Dial3Value = val;
                    else if(float.TryParse(msg.patch["/Value"], out val))
                        twin.TwinData.Dial3Value = val;
                    twin.onDataUpdated?.Invoke();
                });
        }
        
        foreach (var listener in listeners)
        {
            rService.AddListener(listener.twin, listener.OnTwinUpdate);
        }
    }

    private void HandleConnected(string obj)
    {
        Debug.Log("Connected");
    }

    private void HandleDisconnected()
    {
        Debug.Log("Disconnected");
    }
}