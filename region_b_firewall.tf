#######################################################################
## Create Firewall for Region B [Remote]
#######################################################################
resource "azurerm_public_ip" "remote_fw_pip" {
  name                = "${var.prefix}remote-firewall-pip"
  location            = var.remote_location
  resource_group_name = azurerm_resource_group.remote_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create firewall
resource "azurerm_firewall" "remote_fw" {
  name                = "${var.prefix}remote-firewall"
  location            = var.remote_location
  resource_group_name = azurerm_resource_group.remote_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  threat_intel_mode   = "Deny"


  ip_configuration {
    name                 = "remote-firewall-ip-config"
    subnet_id            = azurerm_subnet.remote_fw_subnet.id
    public_ip_address_id = azurerm_public_ip.remote_fw_pip.id
  }
  tags = var.tags
}

#######################################################################
## Create DNAT [to VM] rule for incoming RDP to Firewall PIP on 8080
#######################################################################
resource "azurerm_firewall_nat_rule_collection" "remote_default_dnat" {
  name                = "${var.prefix}dnat-policy"
  azure_firewall_name = azurerm_firewall.remote_fw.name
  resource_group_name = azurerm_resource_group.remote_rg.name
  priority            = 110
  action              = "Dnat"

  rule {
    name                  = "rdp-in"
    source_addresses      = [var.source_ip]
    destination_ports     = ["8080"]
    destination_addresses = [azurerm_public_ip.remote_fw_pip.ip_address]
    translated_port       = 3389
    translated_address    = azurerm_network_interface.remote_vmnic.private_ip_address
    protocols             = ["TCP"]
  }
}