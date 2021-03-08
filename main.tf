#######################################################################
## Create Resource Group for Region 1 [Local]
#######################################################################
resource "azurerm_resource_group" "local_rg" {
  name     = "${var.prefix}local-rg"
  location = var.local_location
  tags     = var.tags
}

#######################################################################
## Create Resource Group for Region 2 {Remote]
#######################################################################
resource "azurerm_resource_group" "remote_rg" {
  name     = "${var.prefix}remote-rg"
  location = var.local_location
  tags     = var.tags
}

#######################################################################
## Create Secret for VPN PSK - Optionally store in Key Vault
#######################################################################
resource "random_password" "vpn_psk" {
  length  = 128
  special = true
  #override_special = "_%@"
}