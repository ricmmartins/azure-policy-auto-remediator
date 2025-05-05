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
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        { name: 'AzureWebJobsStorage', value: sa.properties.primaryEndpoints.blob },
        { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' },
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'python' }
      ]
    }
  }
}

// Event Grid subscription for policy non-compliance events
resource eventSub 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  name: 'noncompliant-event-sub'
  scope: subscription()
  properties: {
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        resourceId: app.id
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.PolicyInsights.PolicyStatesChanged'
      ]
    }
    eventDeliverySchema: 'EventGridSchema'
  }
}

// NOTE: Role assignment removed due to scope and dynamic name issues
// Assign Policy Insights Contributor or Policy Insights Data Writer role manually after deployment
