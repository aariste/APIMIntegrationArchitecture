param logAnalyticsWorkspaceName string
param appInsightsName string
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'string'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}'
  }
}

// Log analytics connection string
resource logAnalyticsConn 'Microsoft.Web/connections@2016-06-01' = {
  name: '${logAnalyticsWorkspaceName}-conn'
  location: location
  properties: {
    displayName: '${logAnalyticsWorkspaceName}-conn'
    api: {
      id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/azureloganalyticsdatacollector'      
    }
    parameterValues: {
      username: reference(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).customerId
      password: listkeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}

output appInsightsId string = appInsights.id
output logAnalyticsConnId string = logAnalyticsConn.id
