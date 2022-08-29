param location string = 'westeurope'

// Analytics
param logAnalyticsWorkspaceName string = 'loganalyticsaasWS'
param appInsightsName string = 'appinsightsaas'

// Storage
param storageName string = 'storageaas2323'

// Azure Function
param functionName string = 'aasfunction2323'
param appServicePlanName string = 'aasserviceplan32323'
// EventHub
param eventHubNamespaceName string = 'eventhubaas3232323'
param eventHubName string = 'hub'

param apiManagementInstanceName string = 'calculatorapimaas323432323'
param publisherEmail string = 'adria@ariste.info'
param publisherName string = 'ariste.info'
param apiName string = 'calculatorBicep'

// Analytics resources
module analytics 'modules/analytics.bicep' = {
  name: logAnalyticsWorkspaceName
  params: {
    appInsightsName: appInsightsName
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// Azure Function Resources
module azureFunction 'modules/azureFunction.bicep' = {
  name: functionName
  params: {
    appInsightsId: analytics.outputs.appInsightsId
    appServicePlanName: appServicePlanName
    functionName: functionName
    location: location
    storageName: storageName
  }
}

// APIM Resources
module apiManagement 'modules/apiManagement.bicep' = {
  name: apiManagementInstanceName
  params: {
    eventHubNamespaceName: eventHubNamespaceName
    eventHubName: eventHubName
    apiManagementInstanceName: apiManagementInstanceName
    apiName: apiName
    endpointUrl: azureFunction.outputs.azureFunctionUrl
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    apiClau: azureFunction.outputs.azureFunctionApiClau
  }
}

