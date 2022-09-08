@description('The location where the resources will be deployed')
param location string = resourceGroup().location

@description('A suffix that will be added to the resources.')
param prefix string

@description('Dynamics 365 F&O instance full web service and service group URL')
param dynamicsUrl string

// Policy (Auth)
@description('Your tenant')
param tenant string
@description('The URL of the D365 environment, without the final /')
param environmentUrl string
@secure()
@description('AAD App registration Client Id')
param appId string
@secure()
@description('App Secret')
param secret string


// Analytics
@description('Log Analytics workspace name')
var logAnalyticsWorkspaceName = '${prefix}LogAnalytics'
@description('Name for the App Insights resource')
var appInsightsName = '${prefix}AppInsights'

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

// APIM Resources
module apiManagement 'modules/apiManagementDynamics.bicep' = {
  name: apiManagementInstanceName
  params: {
    apiManagementInstanceName: apiManagementInstanceName
    apiName: apiName
    endpointUrl: dynamicsUrl
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    appInsightsId: analytics.outputs.appInsightsId
    appInsightsKey: analytics.outputs.appInsightsKey    
    tenant: tenant
    environmentUrl: environmentUrl
    appId: appId
    secret: secret
  }
}
