#!/bin/bash

RESOURCE_GROUP_NAME="$1"
PASSWORD="$2"
NUM_VMS="$3"

# Set the resource group name (Ensure this variable is set correctly in your environment or script)
if [ -z "$RESOURCE_GROUP_NAME" ]; then
    echo "Usage: $0 <resource-group-name> <password> <num-vms>"
    exit 1
fi

if [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <resource-group-name> <password> <num-vms>"
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

# Create two virtual machines

for i in $(seq 1 $NUM_VMS); do
      az vm create \
         --resource-group "$RESOURCE_GROUP_NAME" \
         --name "my-test-vm-$i" \
         --image "Ubuntu2404" \
         --admin-username "azureuser" \
         --admin-password "$PASSWORD" \
         --size "Standard_D2s_v3" \
         --generate-ssh-keys
   
      # Check if the VM creation was unsuccessful
      if [ $? -ne 0 ]; then
         echo "Error: Failed to create VM my-test-vm-$i"
         exit 1
      fi
   done