param iss_io_server_farm_name string
param resource_location string
param iss_eventhub_namespace_name string
param iss_ground_position_adapter_name string
param iss_adapter_name string
param iss_adt_ingestor_name string
param iss_storage_name string
param iss_digital_twins_name string 
param iss_azure_digital_twins_host_name string

resource iss_storage_account 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: iss_storage_name
}

resource iss_io_server_farm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: iss_io_server_farm_name
  location: resource_location
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
  }
  kind:'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
  sku: {
    name: 'B3'
    tier: 'Basic'
    size: 'B3'
    family: 'B'
    capacity: 1
  }
}


@description('Generated from /subscriptions/ce4f8e7f-a80b-461c-ad14-c68c9b6b8b62/resourceGroups/ah-iss-test/providers/Microsoft.EventHub/namespaces/ah-iss-ing-01')
resource iss_eventhub_namespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 6
  }
  name: iss_eventhub_namespace_name
  location: resource_location
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
  }
  properties: {
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
  }
}

resource iss_ingest_eventhub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: iss_eventhub_namespace
  name: 'iss-ing-eh-01'
  properties: {
    messageRetentionInDays: 1
    partitionCount: 2
  }
}

resource iss_egress_eventhub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: iss_eventhub_namespace
  name: 'iss-ing-eh-02'
  properties: {
    messageRetentionInDays: 1
    partitionCount: 2
  }
}

resource authorization_ingress_send_listen 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  parent: iss_ingest_eventhub
  name: 'send_listen'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
}

resource iss_ingest_consumer_group 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = [for i in range(0, 1): {
  parent: iss_ingest_eventhub
  name: '${iss_ingest_eventhub.name}-cg-${i}'
  properties: {}
}]

resource authorization_egress_send 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  parent: iss_egress_eventhub
  name: 'send'
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource authorization_egress_listen 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  parent: iss_egress_eventhub
  name: 'listen'
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource iss_egress_consumer_groups 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-11-01' = [for i in range(0, 3): {
  parent: iss_egress_eventhub
  name: '${iss_egress_eventhub.name}-cg-${i}'
  properties: {}
}]


@description('Generated from /subscriptions/ce4f8e7f-a80b-461c-ad14-c68c9b6b8b62/resourceGroups/ah-iss-test/providers/Microsoft.Web/sites/ah-iss-ground-position')
resource iss_ground_position_adapter 'Microsoft.Web/sites@2021-03-01' = {
  name: iss_ground_position_adapter_name
  kind: 'app,linux'
  location: resource_location
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${iss_ground_position_adapter_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${iss_ground_position_adapter_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: iss_io_server_farm.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNETCORE|6.0'
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: true
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
      appSettings:[
        {
          name: 'BATCH_SEND_INTERVAL'
          value:'10' 
        }
        {
          name: 'EVENT_HUB_CONNECTION_STRING'
          value: '${listKeys(authorization_ingress_send_listen.id, authorization_ingress_send_listen.apiVersion).primaryConnectionString}'
        }
        {
          name: 'EVENT_HUB_NAME'
          value: '${iss_ingest_eventhub.name}'
        }
      ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: true
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource iss_adapter 'Microsoft.Web/sites@2021-03-01' = {
  name: iss_adapter_name
  kind: 'app,linux'
  location: resource_location
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${iss_adapter_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${iss_adapter_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: iss_io_server_farm.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNETCORE|3.1'
      acrUseManagedIdentityCreds: false
      appCommandLine:'dotnet iss_data.dll'
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
      appSettings: [
        {
          name: 'EVENT_HUB_CONNECTION_STRING'
          value: '${listKeys(authorization_ingress_send_listen.id, authorization_ingress_send_listen.apiVersion).primaryConnectionString}'
        }
        {
          name: 'EVENT_HUB_NAME'
          value: '${iss_ingest_eventhub.name}'
        }
        {
          name: 'MAX_UPDATE_FREQUENCY'
          value: '0.25'
        }
      ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: true
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

@description('Generated from /subscriptions/ce4f8e7f-a80b-461c-ad14-c68c9b6b8b62/resourceGroups/ah-iss-test/providers/Microsoft.Web/sites/ah-iss-adt-ingestor')
resource iss_adt_ingestor 'Microsoft.Web/sites@2021-03-01' = {
  name: iss_adt_ingestor_name
  kind: 'functionapp'
  location: resource_location
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${iss_adt_ingestor_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${iss_adt_ingestor_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: iss_io_server_farm.id
    reserved: false
    isXenon: false
    hyperV: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNETCORE|3.1'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 1
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${iss_storage_name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(iss_storage_account.id, iss_storage_account.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'INGESTION_EVENTHUB_CONNECTION_STRING'
          value: '${listKeys(authorization_ingress_send_listen.id, authorization_ingress_send_listen.apiVersion).primaryConnectionString}'
        }
        {
          name: 'INGESTION_EVENTHUB_CONSUMERGROUP'
          value: iss_ingest_consumer_group[0].name
        }
        {
          name: 'INGESTION_EVENTHUB_NAME'
          value: '${iss_ingest_eventhub.name}'
        }
        {
          name: 'INGESTION_GENERIC_ENABLED'
          value: 'true'
        }
        {
          name: 'INGESTION_MODEL_IDENTIFIERS'
          value: 'MessageType'
        }
        {
          name: 'INGESTION_OPC_ENABLED'
          value: 'false'
        }
        {
          name: 'INGESTION_TIMESTAMP_IDENTIFIERS'
          value: 'TimeStamp;Timestamp'
        }
        {
          name: 'INGESTION_TIQ_ENABLED'
          value: 'false'
        }
        {
          name: 'INGESTION_TWIN_IDENTIFIERS'
          value: 'Public_PUI'
        }
        {
          name: 'INGESTION_TWIN_URL'
          value: 'https://${iss_azure_digital_twins_host_name}'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
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
  identity: {
    type: 'SystemAssigned'
  }
}



resource iss_digital_twins_egress_event_hub 'Microsoft.DigitalTwins/digitalTwinsInstances/endpoints@2020-12-01' = {
  name: '${iss_digital_twins_name}/${iss_egress_eventhub.name}'
  properties: {
    endpointType: 'EventHub'
    authenticationType: 'KeyBased'
    connectionStringPrimaryKey: '${listKeys(authorization_egress_send.id, authorization_egress_send.apiVersion).primaryConnectionString}'
    connectionStringSecondaryKey: '${listKeys(authorization_egress_send.id, authorization_egress_send.apiVersion).secondaryConnectionString}'
  }
}

var azureRbacAzureDigitalTwinsOwner = 'bcd981a7-7f74-457b-83e1-cceb9e632ffe'

resource digitalTwinsOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(iss_adt_ingestor_name, resourceGroup().id, azureRbacAzureDigitalTwinsOwner)
  scope: resourceGroup()
  properties: {
    principalId: iss_adt_ingestor.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacAzureDigitalTwinsOwner)
    principalType: 'ServicePrincipal'
  }
}

output iss_event_hub_authorization_egress_listen_id string = authorization_egress_listen.id
output iss_egress_consumer_group_name string = iss_egress_consumer_groups[0].name
output iss_eventhub_namespace_name string = iss_eventhub_namespace.name
output iss_egress_eventhub_name string = iss_egress_eventhub.name
output iss_digital_twins_egress_event_hub_name string = iss_digital_twins_egress_event_hub.name
output iss_io_server_farm_id string = iss_io_server_farm.id
