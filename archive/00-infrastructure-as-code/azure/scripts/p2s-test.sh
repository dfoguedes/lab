#!/bin/bash

RESOURCE_GROUP_NAME="$1"
PASSWORD="$2"


# Set the resource group name (Ensure this variable is set correctly in your environment or script)
if [ -z "$RESOURCE_GROUP_NAME" ]; then
    echo "Usage: $0 <resource-group-name> <password>"
    exit 1
fi

if [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <resource-group-name> <password>"
    exit 1
fi

az group create \
   --name "$RESOURCE_GROUP_NAME" \
   --location "eastus"

# Check if the resource group creation was unsuccessful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create resource group"
    exit 1
fi


az network vnet create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "hub-vnet" \
  --address-prefix "10.0.0.0/16"

az network vnet create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "spoke-vnet" \
  --address-prefix "10.1.0.0/16" \
  --subnet-name "spoke-subnet" \
  --subnet-prefix "10.1.0.0/24"


# Create virtual machine
az vm create \
   --resource-group "$RESOURCE_GROUP_NAME" \
   --name "spoke-vm" \
   --image "Ubuntu2404" \
   --admin-username "azureuser" \
   --admin-password "$PASSWORD" \
   --size "Standard_D2s_v3" \
   --generate-ssh-keys \
   --vnet-name "spoke-vnet" \
   --subnet "spoke-subnet"

# Check if the VM creation was unsuccessful
if [ $? -ne 0 ]; then
   echo "Error: Failed to create VM"
   exit 1
fi
   done