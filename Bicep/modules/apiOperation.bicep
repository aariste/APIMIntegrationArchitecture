param operationName string
param operationUrl string
param operationMethod string
param parentResource string
param apiClau string

resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2020-12-01' = {  
  name: '${parentResource}/${operationName}'
  properties:{
    urlTemplate: '${operationUrl}?code=${apiClau}'
    method: operationMethod
    displayName: operationName    
  }  
}
