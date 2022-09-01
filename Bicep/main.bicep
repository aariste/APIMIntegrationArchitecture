@description('The location where the resources will be deployed')
param location string

@description('A suffix that will be added to the resources.')
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
@description('Event hub namespace name')
var eventHubNamespaceName = '${prefix}EventHubNamespace'
@description('Event hub name in the namespace')
var eventHubName = '${prefix}EventHub'
@description('Name of the APIM resource')
var apiManagementInstanceName = '${prefix}apim'
@description('APIM publisher email')
@secure()
param publisherEmail string
@description('APIM publisher name')
param publisherName string
@description('Name of the API that will be created in the APIM')
var apiName = 'calculator'

// Logic App
@description('Logic app name')
var logicAppName = '${prefix}LogicApp'

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
    apiKey: azureFunction.outputs.azureFunctionApi    
    appInsightsId: analytics.outputs.appInsightsId
    appInsightsKey: analytics.outputs.appInsightsKey    
  }
}

// LogicApp resources
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        When_events_are_available_in_Event_Hub: {
          recurrence: {
            frequency: 'Second'
            interval: 10
          }
          evaluatedRecurrence: {
            frequency: 'Second'
            interval: 10
          }
          splitOn: '@triggerBody()'
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'eventhubs\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(\'${apiManagement.outputs.eventHubName}\')}/events/batch/head'
            queries: {
              consumerGroupName: '$Default'
              contentType: 'application/octet-stream'
              maximumEventsCount: 50
            }
          }
        }
      }
      actions: {
        Send_Data: {
          runAfter: {
          }
          type: 'ApiConnection'
          inputs: {
            body: '@base64ToString(triggerBody()?[\'ContentData\'])'
            headers: {
              'Log-Type': '${apiManagement.name}Logs'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureloganalyticsdatacollector\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/api/logs'
          }
        }
      }
      outputs: {
      }    
    }
    parameters: {
      '$connections': {
        value: {
          azureloganalyticsdatacollector: {
            connectionId: analytics.outputs.logAnalyticsConnId
            connectionName: 'azureloganalyticsdatacollector'
            id: '${subscription().id}/providers/Microsoft.Web/locations/westeurope/managedApis/azureloganalyticsdatacollector'
          }
          eventhubs: {
            connectionId: apiManagement.outputs.eventHubApiConnId
            connectionName: 'eventhubs'
            id: '${subscription().id}/providers/Microsoft.Web/locations/westeurope/managedApis/eventhubs'
          }
        }
      }
    }
  }
}
