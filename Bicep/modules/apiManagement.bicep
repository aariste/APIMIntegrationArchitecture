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

// Logger bodies
resource apiSettings 'Microsoft.ApiManagement/service/apis/diagnostics@2021-08-01' = {
  parent: api
  name: 'applicationinsights'
  properties: {    
    loggerId: apiManagementInstanceAppInsights.id
    verbosity: 'information'
    alwaysLog: 'allErrors'
    operationNameFormat: 'Url'
    logClientIp: true
    sampling: {
      percentage: 100
      samplingType: 'fixed'      
    }
    httpCorrelationProtocol: 'W3C'    
    frontend: {
      request: {
        body: {
          bytes: 8192
        }        
      }
      response: {
        body: {
          bytes: 8192
        }
      }
    }
    backend: {
      request: {
        body: {
          bytes: 8192
        }
      }
      response: {        
        body: {
          bytes: 8192
        }
      }
    }
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
