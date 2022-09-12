@description('The location where the resources will be deployed')
param location string = resourceGroup().location

@description('A prefix that will be added to the resources.')
param prefix string

// Analytics
@description('Log Analytics workspace name')
var logAnalyticsWorkspaceName = '${prefix}LogAnalytics'
@description('Name for the App Insights resource')
var appInsightsName = '${prefix}AppInsights'

// Azure Function
@description('The name of the account storage used by the Azure function')
var storageName = toLower('${prefix}Storage')
@description('Azure function name')
var functionName = '${prefix}Function'
@description('App Service plan name')
var appServicePlanName = '${prefix}AppServicePlan'

// APIM
@description('Name of the APIM resource')
var apiManagementInstanceName = '${prefix}apim'
@description('APIM publisher email')
@secure()
param publisherEmail string
@description('APIM publisher name')
param publisherName string
@description('Name of the API that will be created in the APIM')
var apiName = 'calculator'

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
    apiManagementInstanceName: apiManagementInstanceName
    apiName: apiName
    endpointUrl: azureFunction.outputs.azureFunctionUrl
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    azureFunctionApiVersion: azureFunction.outputs.azureFunctionApiVersion    
    azureFunctionId: azureFunction.outputs.azureFunctionId
    appInsightsId: analytics.outputs.appInsightsId
    appInsightsApiversion: analytics.outputs.appInsightsApiVersion
  }
}
