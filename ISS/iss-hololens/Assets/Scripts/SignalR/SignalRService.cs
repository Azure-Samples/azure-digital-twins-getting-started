// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using Microsoft.AspNetCore.SignalR.Client;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Unity;
using Newtonsoft.Json;
using UnityEngine;

public class SignalRService
{
    public HubConnection connection;

    public event Action<string> OnConnected;

    public event Action<PropertyMessage> OnPropertyMessage;

    public event Action OnDisconnected;

    ~SignalRService()
    {
        if (connection != null)
        {
            connection.StopAsync();
            connection = null;
        }
    }

    public async Task StartAsync(string url)
    {
       
        connection = new HubConnectionBuilder()
           .WithUrl(url)
           .Build();
                
        await connection.StartAsync();
        
        OnConnected?.Invoke(connection.State.ToString());
        connection.Closed += async (error) =>
        {
            OnDisconnected?.Invoke();
            await connection.StartAsync();
        };
    }

    public void AddListener(string topic, Action<PropertyMessage> handler)
    {
        connection.On<PropertyMessage>(topic, (message) => UnityDispatcher.InvokeOnAppThread(
                () => { handler.Invoke(message); }
            )
        );
    }
}