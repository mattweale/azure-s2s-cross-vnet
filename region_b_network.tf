
#######################################################################
## Create networking resources for Region B [Remote]
#######################################################################
#######################################################################
## Create Hub vNET with Firewall Subnet and Gateway Subnet
#######################################################################
resource "azurerm_virtual_network" "remote_hub_vnet" {
  name                = "${var.prefix}.remote-hub-vnet"
  resource_group_name = azurerm_resource_group.remote_rg.name
  location            = var.remote_location
  address_space       = ["172.16.0.0/16"]
  tags                = var.tags
}

# Create Firewall Subnet in Remote Hub VNet
resource "azurerm_subnet" "remote_fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.remote_rg.name
  virtual_network_name = azurerm_virtual_network.remote_hub_vnet.name
  address_prefixes     = ["172.16.1.0/24"]
}

# Create Gateway Subnet in Remote Hub VNet
resource "azurerm_subnet" "remote_gw_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.remote_rg.name
  virtual_network_name = azurerm_virtual_network.remote_hub_vnet.name
  address_prefixes     = ["172.16.2.0/24"]
}

#######################################################################
## Create Spoke vNET with two subnets
#######################################################################
resource "azurerm_virtual_network" "remote_spoke_vnet" {
  name                = "${var.prefix}.remote-spoke-vnet"
  resource_group_name = azurerm_resource_group.remote_rg.name
  location            = var.remote_location
  address_space       = ["172.17.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "remote_subnet1" {
  name                                           = "${var.prefix}remote-subnet-one"
  resource_group_name                            = azurerm_resource_group.remote_rg.name
  virtual_network_name                           = azurerm_virtual_network.remote_spoke_vnet.name
  address_prefixes                               = ["172.17.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "remote_subnet2" {
  name                                           = "${var.prefix}remote-subnet-two"
  resource_group_name                            = azurerm_resource_group.remote_rg.name
  virtual_network_name                           = azurerm_virtual_network.remote_spoke_vnet.name
  address_prefixes                               = ["172.17.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

#######################################################################
## Create vNET Peer between Local Hub and Spoke
#######################################################################
resource "azurerm_virtual_network_peering" "remote_hub_to_spoke_peer" {
  name                         = "${var.prefix}.remote-hub-to-spoke-peer"
  resource_group_name          = azurerm_resource_group.remote_rg.name
  virtual_network_name         = azurerm_virtual_network.remote_hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.remote_spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "remote_spoke_to_hub_peer" {
  name                      = "${var.prefix}.${random_string.random.result}-remote-spoke-to-hub-peer"
  resource_group_name       = azurerm_resource_group.remote_rg.name
  virtual_network_name      = azurerm_virtual_network.remote_spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.remote_hub_vnet.id
  use_remote_gateways       = true
  depends_on                = [azurerm_virtual_network_gateway.local_network_gateway]
}

#######################################################################
## Create and assign NSG for Spoke Subnets
#######################################################################
resource "azurerm_network_security_group" "remote_nsg_spoke" {
  name                = "${var.prefix}.remote-spoke-nsg"
  location            = var.remote_location
  resource_group_name = azurerm_resource_group.remote_rg.name

  security_rule {
    name                       = "rdp-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "3389"
    destination_port_range     = "3389"
    source_address_prefix      = azurerm_firewall.remote_fw.ip_configuration[0].private_ip_address
    destination_address_prefix = azurerm_network_interface.remote_vmnic.private_ip_address
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "remote_assoc_nsg_subnet1" {
  subnet_id                 = azurerm_subnet.remote_subnet1.id
  network_security_group_id = azurerm_network_security_group.remote_nsgspoke.id
}

resource "azurerm_subnet_network_security_group_association" "remote_assoc_nsg_subnet2" {
  subnet_id                 = azurerm_subnet.remote_subnet2.id
  network_security_group_id = azurerm_network_security_group.remote_nsgspoke.id
}

#######################################################################
## Create route table for Spoke and associate with Subnets
#######################################################################
resource "azurerm_route_table" "remote_default_route_table" {
  name                          = "${var.prefix}.remote-spoke-default-route-table"
  location                      = var.remote_location
  resource_group_name           = azurerm_resource_group.remote_rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.remote_fw.ip_configuration[0].private_ip_address
  }
  tags = var.tags
}

# Associate Route Table with Remote Spoke Subnet 1
resource "azurerm_subnet_route_table_association" "assoc_route_remote_subnet1" {
  subnet_id      = azurerm_subnet.remote_subnet1.id
  route_table_id = azurerm_route_table.remote_default_route_table.id
}

# Associate Route Table with Remote Spoke Subnet 2
resource "azurerm_subnet_route_table_association" "assoc_route_remote_subnet2" {
  subnet_id      = azurerm_subnet.remote_subnet2.id
  route_table_id = azurerm_route_table.remote_default_route_table.id
}