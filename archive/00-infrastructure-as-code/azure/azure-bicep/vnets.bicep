

param Location string = resourceGroup().location

resource appnetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = [ for i in range(1, 3): {
  name: 'kk-loop-vnet-${i}'
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
  }
}]
