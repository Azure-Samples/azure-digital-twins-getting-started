
param iss_grafana_server_farm_name string
param resource_location string
param iss_grafana_name string
param iss_storage_account_name string
param iss_domain string

var grafana_admin_password = uniqueString(resourceGroup().id)


resource iss_storage_account 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: iss_storage_account_name
}

resource iss_grafana_server_farm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: iss_grafana_server_farm_name
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
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
}

@description('Generated from /subscriptions/ce4f8e7f-a80b-461c-ad14-c68c9b6b8b62/resourceGroups/ah-iss-test/providers/Microsoft.Web/sites/iss-digitaltwins')
resource iss_grafana 'Microsoft.Web/sites@2021-03-01' = {
  name: iss_grafana_name
  kind: 'app,linux,container'
  tags: {
    'Created By': 'Azure Digital Twins - International Space Station Demo'
  }
  location: resource_location
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${iss_grafana_name}.azurewebsites.net'
        sslState: 'Disabled'    
        hostType: 'Standard'
      }
      {
        name: '${iss_grafana_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: iss_grafana_server_farm.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      appCommandLine:'docker run -d -p 3000:3000 --name grafana grafana/grafana-oss:latest'
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
      linuxFxVersion: 'DOCKER|grafana/grafana-oss:latest-ubuntu'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://index.docker.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'GF_AUTH_AZUREAD_ALLOW_SIGN_UP'
          value: 'true'
        }
        {
          name: 'GF_AUTH_AZUREAD_AUTH_URL'
          value: '${iss_domain}/[your-tenant-id]/oauth2/v2.0/authorize'
        }
        {
          name: 'GF_AUTH_AZUREAD_CLIENT_ID'
          value: '[your-client-id]'
        }
        {
          name: 'GF_AUTH_AZUREAD_CLIENT_SECRET'
          value: '[your-client-secret]'
        }
        {
          name: 'GF_AUTH_AZUREAD_ENABLED'
          value: 'true'
        }
        {
          name: 'GF_AUTH_AZUREAD_SCOPES'
          value: 'openid email profile'
        }
        {
          name: 'GF_AUTH_AZUREAD_TOKEN_URL'
          value: '${iss_domain}/[your-tenant-id]/oauth2/v2.0/token'
        }
        {
          name: 'GF_AUTH_DISABLE_LOGIN_FORM'
          value: 'false'
        }
        {
          name: 'GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH'
          value: '/pxbqnmb7z/iss-position?orgId=1'
        }
        {
          name: 'GF_DATABASE_URL'
          value: 'sqlite3:///var/lib/grafana/grafana.db?cache=private&mode=rwc&_journal_mode=WAL'
        }
        {
          name: 'GF_LOG_MODE'
          value: 'console file'
        }
        {
          name: 'GF_PANELS_DISABLE_SANITIZE_HTML'
          value: 'true'
        }
        {
          name: 'GF_PATHS_PROVISIONING'
          value: '/var/lib/grafana/provisioning'
        }
        {
          name: 'GF_SECURITY_ADMIN_PASSWORD'
          value: grafana_admin_password
        }
        {
          name: 'GF_SERVER_ROOT_URL'
          value: 'https://${iss_grafana_name}.azurewebsites.net/'
        }
        {
          name: 'GF_INSTALL_PLUGINS'
          value: 'grafana-azure-data-explorer-datasource'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
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

// Create an Azure File Service for Grafana
resource iss_grafana_file 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = {
  name: 'default'
  parent: iss_storage_account
}  

// Create a file share for the grafana data
resource iss_grafana_file_share 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-08-01' = {
  name: 'grafana'
  parent: iss_grafana_file
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5
  }
}

// Map the storage account to the grafana container
resource grafana_storage_mapping 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${iss_grafana.name}/azurestorageaccounts'
  properties: {
    'grafana': {
      type: 'AzureFiles'
      shareName: 'grafana'
      mountPath: '/var/lib/grafana'
      accountName: iss_storage_account_name      
      accessKey: listKeys(iss_storage_account.id,iss_storage_account.apiVersion).keys[0].value
    }
  }
}

output iss_adt_dashboard_url string = iss_grafana.properties.defaultHostName
