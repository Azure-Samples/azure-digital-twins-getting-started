param iss_digital_twins_name string
param resource_location string

@description('Generated from /subscriptions/ce4f8e7f-a80b-461c-ad14-c68c9b6b8b62/resourceGroups/ah-iss-test/providers/Microsoft.DigitalTwins/digitalTwinsInstances/ah-iss-adt-02')
resource iss_azure_digital_twins 'Microsoft.DigitalTwins/digitalTwinsInstances@2021-06-30-preview' = {
  name: iss_digital_twins_name
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
    'hidden-title': 'ISS Digital Twin - Operational State'
  }
  properties: {
    privateEndpointConnections: []
    publicNetworkAccess: 'Enabled'
  }
  location: resource_location
  identity: {
    type: 'SystemAssigned'
  }
}


output iss_azure_digital_twins_host_name string = iss_azure_digital_twins.properties.hostName

