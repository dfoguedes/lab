@allowed([
  'eastus2'
  'westeurope'
])
param Location string = 'westeurope'

var prefix = 'bicep'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '${prefix}storageacct68232'
  location: Location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}


output storageAccountName string = storageaccount.name
