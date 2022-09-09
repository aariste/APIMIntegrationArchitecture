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

output appInsightsId string = appInsights.id
output appInsightsApiVersion string = appInsights.apiVersion
