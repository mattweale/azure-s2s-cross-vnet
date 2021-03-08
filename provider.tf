provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "permanent-rg"
    storage_account_name = "mrwterraformstate"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate.s2s.cross.vnet"
  }
}