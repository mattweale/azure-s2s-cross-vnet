#######################################################################
## Create Firewall for Region A [Local]
#######################################################################
resource "azurerm_public_ip" "local_fw_pip" {
  name                = "${var.prefix}local-firewall-pip"
  location            = var.local_location
  resource_group_name = azurerm_resource_group.local_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "local_fw" {
  name                = "${var.prefix}local-firewall"
  location            = var.local_location
  resource_group_name = azurerm_resource_group.local_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  threat_intel_mode   = "Deny"

  ip_configuration {
    name                 = "local-firewall-ip-config"
    subnet_id            = azurerm_subnet.local_fw_subnet.id
    public_ip_address_id = azurerm_public_ip.local_fw_pip.id
  }
  tags = var.tags
}

#######################################################################
## Create DNAT [to VM] rule for incoming RDP to Firewall PIP on 8080
#######################################################################
resource "azurerm_firewall_nat_rule_collection" "local_default_dnat" {
  name                = "${var.prefix}dnat-policy"
  azure_firewall_name = azurerm_firewall.local_fw.name
  resource_group_name = azurerm_resource_group.local_rg.name
  priority            = 110
  action              = "Dnat"

  rule {
    name                  = "rdp-in"
    source_addresses      = [var.source_ip]
    destination_ports     = ["8080"]
    destination_addresses = [azurerm_public_ip.local_fw_pip.ip_address]
    translated_port       = 3389
    translated_address    = azurerm_network_interface.local_vmnic.private_ip_address
    protocols             = ["TCP"]
  }
}

#######################################################################
## Create outbound rule for VM
#######################################################################
resource "azurerm_firewall_network_rule_collection" "local_spoke_outbound_rule" {
  name                = "${var.prefix}local-spoke-outbound-rule"
  azure_firewall_name = azurerm_firewall.local_fw.name
  resource_group_name = azurerm_resource_group.local_rg.name
  priority            = 110
  action              = "Allow"

  rule {
    name = "Outbound"

    source_addresses = [
      azurerm_windows_virtual_machine.local_windows_vm.private_ip_address,
    ]

    destination_ports = [
      "*",
    ]

    destination_addresses = [
      "*"
    ]

    protocols = [
      "Any"
    ]
  }
}
