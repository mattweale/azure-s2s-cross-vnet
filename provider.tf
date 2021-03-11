provider "azurerm" {
  features {}
}

#######################################################################
## Populate to put state on remote backend
#######################################################################
#terraform {
#  backend "azurerm" {
#    resource_group_name  = ""
#    storage_account_name = ""
#    container_name       = ""
#    key                  = ""
#  }
#}