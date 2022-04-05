param iss_digital_twins_adx_name string
param iss_digital_twins_db_name string
param resource_location string

// Create the Azure Data Explorer instance
resource iss_adx 'Microsoft.Kusto/clusters@2022-02-01' = {
  name: iss_digital_twins_adx_name
  location: resource_location  
  sku: {
    name: 'Dev(No SLA)_Standard_D11_v2'
    tier: 'Basic'
    capacity: 1
  }
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
    'hidden-title': 'ISS Digital Twin History'
  }
  properties: {
    trustedExternalTenants: []
    enableDiskEncryption: false
    enableStreamingIngest: true
    enablePurge: false
    enableDoubleEncryption: false
    engineType: 'V3'
    acceptedAudiences: []
    restrictOutboundNetworkAccess: 'Disabled'
    allowedFqdnList: []
    publicNetworkAccess: 'Enabled'
    allowedIpRangeList: []
    enableAutoStop: true
    publicIPType: 'IPv4'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Create the History Database
resource adt_history_database 'Microsoft.Kusto/Clusters/Databases@2021-01-01' = {
  parent: iss_adx
  name: iss_digital_twins_db_name
  location: resource_location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P31D'
    hotCachePeriod: 'P7D'
  }
}

output iss_digital_twins_history_database_name string = adt_history_database.name
output iss_digital_twins_history_database_location string = iss_adx.location
output iss_digital_twins_history_cluster string = iss_adx.name
output iss_digital_twins_history_cluster_url string = iss_adx.properties.uri
output iss_digital_twins_history_identity_id string = iss_adx.identity.principalId

