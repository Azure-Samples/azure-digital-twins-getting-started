param resource_location string
param iss_signalr_service_name string
param iss_signalr_broadcaster_name string
param iss_io_server_farm_id string
param iss_egress_consumer_group string
param iss_storage_name string
param iss_eventhub_egress_name string
param iss_eventhub_namespace_name string

@description('Generated from /subscriptions/ce4f8e7f-a80b-461c-ad14-c68c9b6b8b62/resourceGroups/ah-iss-test/providers/Microsoft.SignalRService/SignalR/ah-iss-signalr')
resource iss_signalr_service 'Microsoft.SignalRService/signalR@2021-10-01' = {
  sku: {
    name: 'Standard_S1'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    tls: {
      clientCertEnabled: false
    }
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
        properties: {}
      }
      {
        flag: 'EnableConnectivityLogs'
        value: 'True'
        properties: {}
      }
    ]
    cors: {
      allowedOrigins: [
        '*'
      ]
    }
    upstream: {
      templates: []
    }
    networkACLs: {
      defaultAction: 'Deny'
      publicNetwork: {
        allow: [
          'ServerConnection'
          'ClientConnection'
          'RESTAPI'
          'Trace'
        ]
      }
      privateEndpoints: []
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    disableAadAuth: false
  }
  kind: 'SignalR'
  location: resource_location
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
  }
  name: iss_signalr_service_name
}

resource iss_storage_account 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: iss_storage_name
}

resource iss_eventhub_namespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: iss_eventhub_namespace_name
}

resource iss_egress_eventhub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' existing = {
  parent: iss_eventhub_namespace
  name: iss_eventhub_egress_name
}

resource authorization_egress_listen 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' existing = {
  parent: iss_egress_eventhub
  name:'listen'
}

@description('Generated from /subscriptions/ce4f8e7f-a80b-461c-ad14-c68c9b6b8b62/resourceGroups/ah-iss-test/providers/Microsoft.Web/sites/ah-iss-signalr-broadcaster')
resource iss_signalr_broadcaster 'Microsoft.Web/sites@2021-03-01' = {
  name: iss_signalr_broadcaster_name
  kind: 'functionapp,linux'
  location: resource_location
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${iss_signalr_broadcaster_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${iss_signalr_broadcaster_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: iss_io_server_farm_id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNET|3.1'
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
      appSettings:[
        {
          name: 'ADT_EVENTHUB_CONNECTION_STRING'
          value: listKeys(authorization_egress_listen.id, authorization_egress_listen.apiVersion).primaryConnectionString
        }
        {
          name: 'ADT_EVENTHUB_CONSUMERGROUP'
          value: iss_egress_consumer_group
        }
        {
          name: 'ADT_EVENTHUB_NAME'
          value: iss_egress_eventhub.name
        }
        {
          name: 'ADT_SUBJECT_FILTER'
          value: '*'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${iss_storage_name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(iss_storage_account.id, iss_storage_account.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'SIGNALR_HUB_CONNECTION_STRING'
          value: '${listkeys(iss_signalr_service.name,iss_signalr_service.apiVersion).primaryConnectionString}'
        }
        {
          name: 'SIGNALR_HUB_NAME'
          value: 'dttelemetry'
        }
      ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'    
  }
  dependsOn:[    
    iss_storage_account
    authorization_egress_listen
  ]
}


output iss_signalr_broadcaster_url string = 'https://${iss_signalr_broadcaster.properties.defaultHostName}'
