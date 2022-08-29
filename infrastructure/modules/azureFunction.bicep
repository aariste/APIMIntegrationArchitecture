param functionName string
param appServicePlanName string
param appInsightsId string
param storageName string
param location string


// Storage resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appservice_plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  properties: {}
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource azureFunction 'Microsoft.Web/sites@2022-03-01' = {
  name: functionName
  location: location
  kind: 'functionapp'  
  properties: {
    serverFarmId: appservice_plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2021-09-01').keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(appInsightsId, '2020-02-02').InstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }                
      ]
    }
  }  
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: '${azureFunction.name}/web'
  properties: {
    repoUrl: 'https://github.com/aariste/APIMIntegrationArchitecture.git'
    branch: 'main'
    isManualIntegration: true
  }
}

var apimKey = listkeys('${azureFunction.id}/host/default', '2022-03-01').functionKeys.default

output azureFunctionUrl string = azureFunction.properties.hostNames[0]
output azureFunctionApiClau string = apimKey
