param operationName string
param operationUrl string
param operationMethod string
param parentResource string

resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2020-12-01' = {  
  name: '${parentResource}/${operationName}'
  properties:{
    urlTemplate: operationUrl
    method: operationMethod
    displayName: operationName    
  }  
}
