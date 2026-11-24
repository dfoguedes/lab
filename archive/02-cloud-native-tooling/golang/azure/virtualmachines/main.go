package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore/to"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/compute/armcompute"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v2"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/resources/armresources"
)

const (
	location          = "westus"
	resourceGroupName = "my-rg"
	envSubID          = "AZURE_SUBSCRIPTION_ID"
	vnetName = "my-vnet"
	subnetName = "subnet-a"
	vmName = "my-ubuntu"
	nicName = "my-nic"
	diskName = "my-disk"
	publicIPName = "my-public-ip"
	nsgName = "my-nsg"
	adminUser         = "azureuser"
)

func getToken()  (*azidentity.DefaultAzureCredential, string) {
    cred, err := azidentity.NewDefaultAzureCredential(nil)
    if err != nil {
        log.Fatalf("credential error: %v", err)
    }
    // retrieve subscription id from the system
    subID := os.Getenv(envSubID)
    if subID == "" {
        log.Fatalf("env var %s not set", envSubID)
    }
    return cred, subID

}

func createResourceGroup(ctx context.Context,subID string , cred *azidentity.DefaultAzureCredential , resourceName string, location string )  {
	resourceGroupClient , err := armresources.NewClientFactory(subID, cred, nil)
	if err != nil {
        log.Fatalf("client factory error: %v", err)
    	}
	rgClient := resourceGroupClient.NewResourceGroupsClient()
	rgResp, err := rgClient.CreateOrUpdate(
		ctx,
		resourceGroupName,
		armresources.ResourceGroup{Location: to.Ptr(location)},
		nil,
	)
	if err != nil {
		log.Fatalf("create/update RG error: %v", err)
	}

	fmt.Printf("Resource group created: %s (location: %s)\n", *rgResp.ID, *rgResp.Location)

}
func createNetworkInterface(ctx context.Context, subnetID string, publicIPID string, networkSecurityGroupID string, subID string, cred *azidentity.DefaultAzureCredential) (*armnetwork.Interface) {
	interfacesClient,err := armnetwork.NewInterfacesClient(subID, cred, nil)
	if err != nil {
		log.Fatal(err)
	}
	parameters := armnetwork.Interface{
		Location: to.Ptr(location),
		Properties: &armnetwork.InterfacePropertiesFormat{
			//NetworkSecurityGroup:
			IPConfigurations: []*armnetwork.InterfaceIPConfiguration{
				{
					Name: to.Ptr("ipConfig"),
					Properties: &armnetwork.InterfaceIPConfigurationPropertiesFormat{
						PrivateIPAllocationMethod: to.Ptr(armnetwork.IPAllocationMethodDynamic),
						Subnet: &armnetwork.Subnet{
							ID: to.Ptr(subnetID),
						},
						PublicIPAddress: &armnetwork.PublicIPAddress{
							ID: to.Ptr(publicIPID),
						},
					},
				},
			},
			NetworkSecurityGroup: &armnetwork.SecurityGroup{
				ID: to.Ptr(networkSecurityGroupID),
			},
		},
	}

	pollerResponse, err := interfacesClient.BeginCreateOrUpdate(ctx, resourceGroupName, nicName, parameters, nil)
	if err != nil {
		log.Fatal(err)
	}

	resp, err := pollerResponse.PollUntilDone(ctx, nil)
	if err != nil {
		log.Fatal(err)
	}

	return &resp.Interface
}

func createVirtualMachine(ctx context.Context, subID string, cred *azidentity.DefaultAzureCredential, networkInterfaceID string) (*armcompute.VirtualMachine, error) {
    vmClient, err := armcompute.NewVirtualMachinesClient(subID, cred, nil)
    if err != nil {
        return nil, fmt.Errorf("virtual machines client: %w", err)
    }

    sshPublicKeyPath := "/home/diogo/.ssh/id_rsa.pub"
    sshBytes, err := os.ReadFile(sshPublicKeyPath)
    if err != nil {
        return nil, fmt.Errorf("read ssh key: %w", err)
    }

    parameters := armcompute.VirtualMachine{
        Location: to.Ptr(location),
        Properties: &armcompute.VirtualMachineProperties{
            StorageProfile: &armcompute.StorageProfile{
                ImageReference: &armcompute.ImageReference{
                    Publisher: to.Ptr("Canonical"),
                    Offer:     to.Ptr("0001-com-ubuntu-server-focal"),
                    SKU:       to.Ptr("20_04-lts"),
                    Version:   to.Ptr("latest"),
                },
                OSDisk: &armcompute.OSDisk{
                    Name:         to.Ptr(diskName),
                    CreateOption: to.Ptr(armcompute.DiskCreateOptionTypesFromImage),
                    Caching:      to.Ptr(armcompute.CachingTypesReadWrite),
                    ManagedDisk: &armcompute.ManagedDiskParameters{
                        StorageAccountType: to.Ptr(armcompute.StorageAccountTypesStandardLRS),
                    },
                },
            },
            HardwareProfile: &armcompute.HardwareProfile{
                VMSize: to.Ptr(armcompute.VirtualMachineSizeTypesStandardB1S),
            },
            OSProfile: &armcompute.OSProfile{
                ComputerName:  to.Ptr(vmName),
                AdminUsername: to.Ptr(adminUser),
                LinuxConfiguration: &armcompute.LinuxConfiguration{
                    DisablePasswordAuthentication: to.Ptr(true),
                    SSH: &armcompute.SSHConfiguration{
                        PublicKeys: []*armcompute.SSHPublicKey{
                            {
                                Path:    to.Ptr(fmt.Sprintf("/home/%s/.ssh/authorized_keys", adminUser)),
                                KeyData: to.Ptr(string(sshBytes)),
                            },
                        },
                    },
                },
            },
            NetworkProfile: &armcompute.NetworkProfile{
                NetworkInterfaces: []*armcompute.NetworkInterfaceReference{
                    {ID: to.Ptr(networkInterfaceID)},
                },
            },
        },
    }

    poller, err := vmClient.BeginCreateOrUpdate(ctx, resourceGroupName, vnetName, parameters, nil)
    if err != nil {
        return nil, fmt.Errorf("begin create vm: %w", err)
    }
    res, err := poller.PollUntilDone(ctx, nil)
    if err != nil {
        return nil, fmt.Errorf("poll vm: %w", err)
    }
    return &res.VirtualMachine, nil
}

func createPublicIP(ctx context.Context, subID string, cred *azidentity.DefaultAzureCredential) *armnetwork.PublicIPAddress {
    publicIPAddressesClient, err := armnetwork.NewPublicIPAddressesClient(subID, cred, nil)
    if err != nil {
        log.Fatal(err)
    }
    parameters := armnetwork.PublicIPAddress{
        Location: to.Ptr(location),
        SKU: &armnetwork.PublicIPAddressSKU{
            Name: to.Ptr(armnetwork.PublicIPAddressSKUNameStandard), // switch to Standard
            Tier: to.Ptr(armnetwork.PublicIPAddressSKUTierRegional),
        },
        Properties: &armnetwork.PublicIPAddressPropertiesFormat{
            PublicIPAllocationMethod: to.Ptr(armnetwork.IPAllocationMethodStatic), // Standard usually Static
        },
    }

    pollerResponse, err := publicIPAddressesClient.BeginCreateOrUpdate(ctx, resourceGroupName, publicIPName, parameters, nil)
    if err != nil {
        log.Fatal(err)
    }
    resp, err := pollerResponse.PollUntilDone(ctx, nil)
    if err != nil {
        log.Fatal(err)
    }
    return &resp.PublicIPAddress
}

func createSubnet(ctx context.Context, subID string, cred *azidentity.DefaultAzureCredential) *armnetwork.Subnet {
    subnetClient, err := armnetwork.NewSubnetsClient(subID, cred, nil)
    if err != nil {
        log.Fatal(err)
    }
    parameters := armnetwork.Subnet{
        Properties: &armnetwork.SubnetPropertiesFormat{
            AddressPrefix: to.Ptr("10.0.1.0/24"),
        },
    }
    pollerResponse, err := subnetClient.BeginCreateOrUpdate(ctx, resourceGroupName, vnetName, subnetName, parameters,nil)
    if err != nil {
        log.Fatal(err)
    }
    resp, err := pollerResponse.PollUntilDone(ctx, nil)
    if err != nil {
        log.Fatal(err)
    }
    return &resp.Subnet
}

func createVnet(ctx context.Context, subID string, cred *azidentity.DefaultAzureCredential) (*armnetwork.VirtualNetwork) {
    vnetClient, err := armnetwork.NewVirtualNetworksClient(subID, cred, nil)
    if err != nil {
        log.Fatalf("vnet client error: %v", err)
    }

    poller, err := vnetClient.BeginCreateOrUpdate(
        ctx,
        resourceGroupName,
        vnetName,
        armnetwork.VirtualNetwork{
            Location: to.Ptr(location),
            Properties: &armnetwork.VirtualNetworkPropertiesFormat{
                AddressSpace: &armnetwork.AddressSpace{
                    AddressPrefixes: []*string{to.Ptr("10.0.0.0/16")},
                },
            },
        },
        nil,
    )
    if err != nil {
        log.Fatalf("begin vnet create error: %v", err)
    }

    resp, err := poller.PollUntilDone(ctx, nil)
    if err != nil {
        log.Fatalf("poll vnet create error: %v", err)
    }
    return &resp.VirtualNetwork
}

func createNetworkSecurityGroup(ctx context.Context, subID string, cred *azidentity.DefaultAzureCredential) (*armnetwork.SecurityGroup) {
	securityGroupsClient , err := armnetwork.NewSecurityGroupsClient(subID, cred, nil)
	if err != nil {
		log.Fatal(err)
	}
	parameters := armnetwork.SecurityGroup{
		Location: to.Ptr(location),
		Properties: &armnetwork.SecurityGroupPropertiesFormat{
			SecurityRules: []*armnetwork.SecurityRule{
				// Windows connection to virtual machine needs to open port 3389,RDP
				// inbound
				{
					Name: to.Ptr("sample_inbound_22"), //
					Properties: &armnetwork.SecurityRulePropertiesFormat{
						SourceAddressPrefix:      to.Ptr("0.0.0.0/0"),
						SourcePortRange:          to.Ptr("*"),
						DestinationAddressPrefix: to.Ptr("0.0.0.0/0"),
						DestinationPortRange:     to.Ptr("22"),
						Protocol:                 to.Ptr(armnetwork.SecurityRuleProtocolTCP),
						Access:                   to.Ptr(armnetwork.SecurityRuleAccessAllow),
						Priority:                 to.Ptr[int32](100),
						Description:              to.Ptr("sample network security group inbound port 22"),
						Direction:                to.Ptr(armnetwork.SecurityRuleDirectionInbound),
					},
				},
				// outbound
				{
					Name: to.Ptr("sample_outbound_22"), //
					Properties: &armnetwork.SecurityRulePropertiesFormat{
						SourceAddressPrefix:      to.Ptr("0.0.0.0/0"),
						SourcePortRange:          to.Ptr("*"),
						DestinationAddressPrefix: to.Ptr("0.0.0.0/0"),
						DestinationPortRange:     to.Ptr("22"),
						Protocol:                 to.Ptr(armnetwork.SecurityRuleProtocolTCP),
						Access:                   to.Ptr(armnetwork.SecurityRuleAccessAllow),
						Priority:                 to.Ptr[int32](100),
						Description:              to.Ptr("sample network security group outbound port 22"),
						Direction:                to.Ptr(armnetwork.SecurityRuleDirectionOutbound),
					},
				},
			},
		},
	}

	pollerResponse, err := securityGroupsClient.BeginCreateOrUpdate(ctx, resourceGroupName, nsgName, parameters, nil)
	if err != nil {
		log.Fatal(err)
	}

	resp, err := pollerResponse.PollUntilDone(ctx, nil)
	if err != nil {
		log.Fatal(err)
	}
	return &resp.SecurityGroup
}


func main() {

    ctx := context.Background()
    cred, subID := getToken()
  
    createResourceGroup(ctx,subID,cred,resourceGroupName,location)
    vnet := createVnet(ctx,subID,cred)
    fmt.Println("VNet created:", *vnet.ID)
    subnet := createSubnet(ctx,subID,cred)
    fmt.Println("Subnet created:", *subnet.ID)
    publicIP := createPublicIP(ctx, subID, cred)
    fmt.Println("Public IP created:", *publicIP.ID)
    nsgName := createNetworkSecurityGroup(ctx, subID, cred)
    fmt.Println("Network Security Group created:", *nsgName.ID)
    nicName := createNetworkInterface(ctx, *subnet.ID, *publicIP.ID, *nsgName.ID, subID, cred) 
    fmt.Println("Network Interface created:", *nicName.ID)
    vm, err := createVirtualMachine(ctx, subID, cred, *nicName.ID)
    if err != nil {
        log.Fatalf("failed to create virtual machine: %v", err)
    }
    fmt.Println("New virtual machine created:", *vm.ID)

}