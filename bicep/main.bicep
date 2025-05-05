param location string = resourceGroup().location
param functionAppName string = 'policy-remediator-${uniqueString(resourceGroup().id)}'

resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: toLower('func${uniqueString(resourceGroup().id)}')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: ''
      appSettings: [{ name: 'AzureWebJobsStorage', value: sa.properties.primaryEndpoints.blob }, { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }, { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'python' }]
    }
  }
}
