# Global variables

$virtualNetworkName = "vnet-workloads"
$resourceGroupName = "rg"
$username = "guedes"
#$plainPassword = ""
$virtualMachineName = "workload-a-vm"
$location = "eastus"
$subnetName = "snet-workload-a"
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

# Create Resource Group

New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create subnet

$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix '192.168.1.0/24'

Write-Host "Subnet Name: $subnetName"

Write-Host "Creating Vnet..." -ForegroundColor "Yellow" -BackgroundColor "Black"
# Create a VNet
New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $virtualNetworkName `
   -AddressPrefix '192.168.0.0/16' `
   -Subnet $subnetConfig

# Create a new Azure Virtual Machine with specified configurations

Write-Host "Creating Virtual machine: $virtualMachineName" -ForegroundColor "Yellow" -BackgroundColor "Black" 


New-AzVm `
   -ResourceGroupName $resourceGroupName `
   -Location $location -VirtualNetworkName `
   $virtualNetworkName `
   -SubnetName $subnetName `
   -PublicIpAddressName "$virtualMachineName-pip" -Name $virtualMachineName `
   -Credential $credential -Image "Ubuntu2204" -Size "Standard_D2s_v3"

