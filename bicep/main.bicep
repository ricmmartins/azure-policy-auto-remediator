param location string = resourceGroup().location
param functionAppName string = 'policy-remediator-${uniqueString(resourceGroup().id)}'

resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: toLower('func${uniqueString(resourceGroup().id)}')
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${uniqueString(resourceGroup().id)}'
  location: location
  sku: { name: 'Y1', tier: 'Dynamic' }
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: { type: 'SystemAssigned' }
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

resource eventSub 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  name: 'noncompliant-event-sub'
  scope: subscription()
  properties: {
    destination: { endpointType: 'AzureFunction', properties: { resourceId: app.id } }
    filter: { includedEventTypes: [ 'Microsoft.PolicyInsights.PolicyStatesChanged' ] }
    eventDeliverySchema: 'EventGridSchema'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(app.identity.principalId, 'PolicyInsightsContributor')
  scope: subscription()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1c0163c0-47e6-4577-8991-ea5c82e286e4')
    principalId: app.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
