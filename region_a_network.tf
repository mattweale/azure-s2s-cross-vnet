#######################################################################
## Create networking resources for Region A [Local]
#######################################################################
#######################################################################
## Create Hub vNET with Firewall Subnet and Gateway Subnet
#######################################################################
resource "azurerm_virtual_network" "local_hub_vnet" {
  name                = "${var.prefix}.local-hub-vnet"
  resource_group_name = azurerm_resource_group.local_rg.name
  location            = var.local_location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "local_fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.local_rg.name
  virtual_network_name = azurerm_virtual_network.local_hub_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "local_gw_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.local_rg.name
  virtual_network_name = azurerm_virtual_network.local_hub_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#######################################################################
## Create Spoke vNET with two subnets
#######################################################################
resource "azurerm_virtual_network" "local_spoke_vnet" {
  name                = "${var.prefix}.local-spoke-vnet"
  resource_group_name = azurerm_resource_group.local_rg.name
  location            = var.local_location
  address_space       = ["10.1.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "local_subnet1" {
  name                                           = "${var.prefix}local-subnet-one"
  resource_group_name                            = azurerm_resource_group.local_rg.name
  virtual_network_name                           = azurerm_virtual_network.local_spoke_vnet.name
  address_prefixes                               = ["10.1.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "local_subnet2" {
  name                                           = "${var.prefix}local-subnet-two"
  resource_group_name                            = azurerm_resource_group.local_rg.name
  virtual_network_name                           = azurerm_virtual_network.local_spoke_vnet.name
  address_prefixes                               = ["10.1.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

#######################################################################
## Create vNET Peer between Local Hub and Spoke
#######################################################################
resource "azurerm_virtual_network_peering" "local_hub-to-spoke-peer" {
  name                         = "${var.prefix}.local_hub-to-spoke-peer"
  resource_group_name          = azurerm_resource_group.local_rg.name
  virtual_network_name         = azurerm_virtual_network.local_hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.local_spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "local_spoke-to-hub-peer" {
  name                         = "${var.prefix}.local_spoke-to-hub-peer"
  resource_group_name          = azurerm_resource_group.local_rg.name
  virtual_network_name         = azurerm_virtual_network.local_spoke_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.local_hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_gateway.local_network_gateway]
}

#######################################################################
## Create and assign NSG for Spoke Subnets
#######################################################################
resource "azurerm_network_security_group" "local_nsg_spoke" {
  name                = "${var.prefix}.local-spoke-nsg"
  location            = var.local_location
  resource_group_name = azurerm_resource_group.local_rg.name

  security_rule {
    name                       = "rdp-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "3389"
    destination_port_range     = "3389"
    source_address_prefix      = azurerm_firewall.local_fw.ip_configuration[0].private_ip_address
    destination_address_prefix = azurerm_network_interface.local_vmnic.private_ip_address
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "local_assoc_nsg_subnet1" {
  subnet_id                 = azurerm_subnet.local_subnet1.id
  network_security_group_id = azurerm_network_security_group.local_nsgspoke.id
}

resource "azurerm_subnet_network_security_group_association" "local_assoc_nsg_subnet2" {
  subnet_id                 = azurerm_subnet.local_subnet2.id
  network_security_group_id = azurerm_network_security_group.local_nsgspoke.id
}

#######################################################################
## Create route table for Spoke and associate with Subnets
#######################################################################
resource "azurerm_route_table" "local_default_route_table" {
  name                          = "${var.prefix}.local-spoke-default-route-table"
  location                      = var.local_location
  resource_group_name           = azurerm_resource_group.local_rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.local_fw.ip_configuration[0].private_ip_address
  }
  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "assoc_route_local_subnet1" {
  subnet_id      = azurerm_subnet.local_subnet1.id
  route_table_id = azurerm_route_table.local_default_route_table.id
}

resource "azurerm_subnet_route_table_association" "assoc_route_local_subnet2" {
  subnet_id      = azurerm_subnet.local_subnet2.id
  route_table_id = azurerm_route_table.local_default_route_table.id
}