param resource_location string
param iss_storage_name string

resource iss_storage_account 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: iss_storage_name
  kind: 'StorageV2'
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
  }
  location: resource_location
  sku: {
    name: 'Standard_LRS'
  }
}

output iss_storage_account_name string = iss_storage_account.name
