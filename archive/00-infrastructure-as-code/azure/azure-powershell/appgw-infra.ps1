#Pref
$WarningPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

#Variables
$rg = "rg-appgw"
$region = "eastus"
$username = "azureuser" #username for the VM
#$plainPassword = ""

#Creating VM credential; use your own password and username by changing the variables if needed
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password);

# Create Resource Group
New-AzResourceGroup -Name $rg -Location $region -Force

# Create VNet and Subnets
$vnetName = "vnet-appgw"

# Create the subnets
$contacts = New-AzVirtualNetworkSubnetConfig -Name "snet-appgw-contacts" -AddressPrefix "10.0.0.0/24"
$help = New-AzVirtualNetworkSubnetConfig -Name "snet-appgw-help" -AddressPrefix "10.0.1.0/24"

# Creating the VNet with the subnets
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName -ErrorAction SilentlyContinue
if (-not $vnet) {
   New-AzVirtualNetwork -ResourceGroupName $rg -Location $region -Name $vnetName -AddressPrefix "10.0.0.0/16" -Subnet $contacts, $help
}

# Create virtual machines in each subnet

# Ubuntu VM in snet-appgw-contacts with nginx installation
$contactsScript = @"
#!/bin/bash
apt-get update
apt-get install -y nginx
echo 'This is the page contacts' | sudo tee /var/www/html/index.html
sudo systemctl restart nginx
"@

# Create public IP for contacts VM
$contactsPublicIp = New-AzPublicIpAddress -ResourceGroupName $rg -Location $region -Name "pip-contacts" -AllocationMethod Static -Sku Standard

$contactsNic = New-AzNetworkInterface -ResourceGroupName $rg -Location $region -Name "nic-contacts" -SubnetId (Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName).Subnets[0].Id -PublicIpAddressId $contactsPublicIp.Id

$contactsVmConfig = New-AzVmConfig -VMName "vm-contacts" -VMSize "Standard_B1s" | `
   Set-AzVmOperatingSystem -Linux -ComputerName "vm-contacts" -Credential $credential -DisablePasswordAuthentication:$false | `
   Set-AzVmSourceImage -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest" | `
   Add-AzVmNetworkInterface -Id $contactsNic.Id

New-AzVM -ResourceGroupName $rg -Location $region -VM $contactsVmConfig

# Run custom script on contacts VM
Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName "vm-contacts" -CommandId 'RunShellScript' -ScriptString $contactsScript

# Ubuntu VM in snet-appgw-help with nginx installation
$helpScript = @"
#!/bin/bash
apt-get update
apt-get install -y nginx
echo 'This is the page help' | sudo tee /var/www/html/index.html
sudo systemctl restart nginx
"@

# Create public IP for help VM
$helpPublicIp = New-AzPublicIpAddress -ResourceGroupName $rg -Location $region -Name "pip-help" -AllocationMethod Static -Sku Standard

$helpNic = New-AzNetworkInterface -ResourceGroupName $rg -Location $region -Name "nic-help" -SubnetId (Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vnetName).Subnets[1].Id -PublicIpAddressId $helpPublicIp.Id


$helpVmConfig = New-AzVmConfig -VMName "vm-help" -VMSize "Standard_B1s" | `
   Set-AzVmOperatingSystem -Linux -ComputerName "vm-help" -Credential $credential -DisablePasswordAuthentication:$false | `
   Set-AzVmSourceImage -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest" | `
   Add-AzVmNetworkInterface -Id $helpNic.Id

New-AzVM -ResourceGroupName $rg -Location $region -VM $helpVmConfig

# Run custom script on help VM
Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName "vm-help" -CommandId 'RunShellScript' -ScriptString $helpScript

# Output public IP addresses
Write-Host "Contacts VM Public IP: $($contactsPublicIp.IpAddress)"
Write-Host "Help VM Public IP: $($helpPublicIp.IpAddress)"
