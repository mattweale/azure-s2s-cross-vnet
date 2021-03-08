# **Azure Firewall and Application Gateway in Parallel in Hub <> Spoke**

# Contents
[Overview](#overview)

[Deployment](#deployment)

# Overview

This Terraform module deploys a Hub and Spoke vNET pair in two Azure Regions ["Local" and "Remote"]. A VM is deployed in each spoke, with outbound internet connectivity enabled by a UDR via the local firewall. A [Site-to-Site] VPN Gateway is deployed in each Hub with an IPSec Tunnel connecting each Hub. Spoke to Spoke routing is enable via BGP

Public RDP connectivity to each VM is enabled via a DNAT Rule [port 8080] on the public endpoint of the Firewall. Don't forget to include your RDP Client IP Address is variables.tf.

Once deployed it should look like this:

![image](images/azure-hub-spoke-app-gateway.png)

# Deployment

Steps:
- Log in to Azure Cloud Shell at https://shell.azure.com/ and select Bash
- Ensure Azure CLI and extensions are up to date:
  
  `az upgrade --yes`
  
- If necessary select your target subscription:
  
  `az account set --subscription <Name or ID of subscription>`
  
- Clone the  GitHub repository:
  
  `git clone https://github.com/mattweale/azure-s2s-cross-vnet`
  
  - Change directory:
  
  `cd ./azure-s2s-cross-vnet`
  - Initialize terraform and download the azurerm resource provider:

  `terraform init`

- Now start the deployment (when prompted, confirm with **yes** to start the deployment):
 
  `terraform apply`

Each VM can be connected to over RDP [8080]. To demonstrate inter vNET Connectivity over IPSec, you can RDP from each VM, to the other, using the Private IP Address.

Deployment takes approximately 20 minutes. 
## Explore and verify

After the Terraform deployment concludes successfully, the following has been deployed into your subscription:
- A resource group named **tf-s2s-cross-vnet-lab-remote-rg** containing:
  - One Hub vNET containing a Firewall.
  - One Spoke vNET containing Virtual Machine with Windows 10 Entperprise Edition.
  - Hub and Spoke Peering with BGP enabled and Gateway Transit.

- A resource group named **tf-s2s-cross-vnet-lab-remote-rg** containing:
  - One Hub vNET containing a Firewall and an Application Gateway [with WAF].
  - One Spoke vNET containing Virtual Machine with Windows 10 Entperprise Edition.
  - Hub and Spoke Peering with BGP enabled and Gateway Transit.

Verify these resources are present in the portal.

Credentials are identical for both VMs:
- User name: AdminUser
- Password: Pa55w0rd123!

## Delete all resources

Delete the tf-app-gw-lab-rg resource groups. This may take up to 20 minutes to complete. Check back to verify that all resources have indeed been deleted.

In Cloud Shell, delete the azure-hub-spoke-app-gateway directory:

`rm -rf azure-s2s-cross-vnet`