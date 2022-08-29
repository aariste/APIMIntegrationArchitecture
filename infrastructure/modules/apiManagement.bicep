param eventHubNamespaceName string
param eventHubName string
param apiManagementInstanceName string
param location string
param publisherName string
param publisherEmail string
param apiName string
param endpointUrl string
param apiClau string

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

// resource apiManagementInstance 'Microsoft.ApiManagement/service@2021-08-01' existing = {
//   name: 'iberiansummitapim'
// }

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

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apiManagementInstance
  name: '${apiManagementInstanceName}-logger'
  properties: {
    loggerType: 'azureEventHub'
    resourceId: eventHub.id      
    credentials: {
      connectionString: listKeys(eventHubListenSend.id, eventHubListenSend.apiVersion).primaryConnectionString
    }
  }    
}

var loggerName = '${apiManagementInstanceName}-logger'
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
    apiClau: apiClau
  }
}

module operationSubstract 'apiOperation.bicep' = {  
  name: 'substract'
  params: {
    operationMethod: 'POST'
    operationName: 'substract'
    operationUrl: '/substract'
    parentResource: '${apiManagementInstance.name}/${api.name}'
    apiClau: apiClau
  }
}
 
module operationMultiply 'apiOperation.bicep' = {  
  name: 'multiply'
  params: {
    operationMethod: 'POST'
    operationName: 'multiply'
    operationUrl: '/multiply'
    parentResource: '${apiManagementInstance.name}/${api.name}'
    apiClau: apiClau
  }
}

module operationDivide 'apiOperation.bicep' = {  
  name: 'divide'
  params: {
    operationMethod: 'POST'
    operationName: 'divide'
    operationUrl: '/divide'
    parentResource: '${apiManagementInstance.name}/${api.name}'
    apiClau: apiClau
  }
}

output polXML string = polXML
