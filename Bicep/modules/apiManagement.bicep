param eventHubNamespaceName string
param eventHubName string
param apiManagementInstanceName string
param location string
param publisherName string
param publisherEmail string
param apiName string
param endpointUrl string
@secure()
param apiKey string
param appInsightsId string
param appInsightsKey string

// Event Hub
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location    
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubName       
}

resource eventHubListenSend 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  parent: eventHub
  name: 'ListenSend'
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }  
}

// Event Hub connection for Logic App
resource eventHubConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: '${eventHubName}-conn'
  location: location
  properties: {
    displayName: '${eventHubName}-conn'
    api: {
      id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/eventhubs'
    }    
    parameterValues: {
      connectionString: listkeys(eventHubListenSend.id, eventHubListenSend.apiVersion).primaryConnectionString
    }
  }
}

// APIM
resource apiManagementInstance 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apiManagementInstanceName
  location: location
  sku:{
    capacity: 0
    name: 'Consumption'
  }
  properties:{
    publisherEmail: publisherEmail
    publisherName: publisherName  
  }  
}

// App Insights Link
resource apiManagementInstanceAppInsights 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apiManagementInstance
  name: '${apiManagementInstance.name}-appInsights'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsKey
    }
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apiManagementInstance
  name: '${apiManagementInstanceName}-logger'
  properties: {
    loggerType: 'azureEventHub'
    resourceId: eventHub.id      
    credentials: {
      connectionString: listkeys(eventHubListenSend.id, eventHubListenSend.apiVersion).primaryConnectionString
    }
  }    
}

var loggerName = apimLogger.name
var pol = loadTextContent('apimPolicies/policy.xml')
var polXML = replace(pol, '{%logger_name%}', loggerName)

// API
resource api 'Microsoft.ApiManagement/service/apis@2020-12-01' = {
  parent: apiManagementInstance
  name: apiName    
  properties: {
    serviceUrl: 'https://${endpointUrl}/api'
    path: 'bicep'
    apiType: 'http'        
    displayName: apiName
    protocols: [
      'https'
    ]
    subscriptionRequired: true
    subscriptionKeyParameterNames: {
      header: 'x-api-key'
    }        
  }  
}

// Pol
resource apiPolitica 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {  
  parent: api
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: polXML          
  }
}

// API Operations  
module operationAdd 'apiOperation.bicep' = {  
  name: 'add'
  params: {
    operationMethod: 'POST'
    operationName: 'add'
    operationUrl: '/add'
    parentResource: '${apiManagementInstance.name}/${api.name}'
    apiClau: apiKey
  }
}

module operationSubstract 'apiOperation.bicep' = {  
  name: 'substract'
  params: {
    operationMethod: 'POST'
    operationName: 'substract'
    operationUrl: '/substract'
    parentResource: '${apiManagementInstance.name}/${api.name}'
    apiClau: apiKey
  }
}
 
module operationMultiply 'apiOperation.bicep' = {  
  name: 'multiply'
  params: {
    operationMethod: 'POST'
    operationName: 'multiply'
    operationUrl: '/multiply'
    parentResource: '${apiManagementInstance.name}/${api.name}'
    apiClau: apiKey
  }
}

module operationDivide 'apiOperation.bicep' = {  
  name: 'divide'
  params: {
    operationMethod: 'POST'
    operationName: 'divide'
    operationUrl: '/divide'
    parentResource: '${apiManagementInstance.name}/${api.name}'
    apiClau: apiKey
  }
}

output eventHubApiConnId string = eventHubConnection.id
output eventHubName string = eventHub.name
