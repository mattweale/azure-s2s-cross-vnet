#######################################################################
## Create VPN Gateway for Region B [Remote]
#######################################################################
resource "azurerm_public_ip" "remote_gw_pip" {
  name                = "${var.prefix}remote-gw-pip"
  location            = var.remote_location
  resource_group_name = azurerm_resource_group.remote_rg.name
  allocation_method   = "Dynamic"
}

# Create remote gateway
resource "azurerm_virtual_network_gateway" "remote_network_gateway" {
  name                = "${var.prefix}remote-vpn-gateway"
  location            = var.remote_location
  resource_group_name = azurerm_resource_group.remote_rg.name

  depends_on          = [azurerm_public_ip.remote_gw_pip]

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "remote-vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.remote_gw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.remote_gw_subnet.id
  }

  bgp_settings {
    asn = 65011
  }
}

#######################################################################
## Create connection
#######################################################################
resource "azurerm_virtual_network_gateway_connection" "remote_to_local" {
  name                = "${var.prefix}remote-to-local"
  location            = var.remote_location
  resource_group_name = azurerm_resource_group.remote_rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.remote_network_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.local_network_gateway.id
  enable_bgp                      = true

  #shared_key = data.azurerm_key_vault_secret.s2s_vpn_psk.value
  shared_key = random_password.vpn_psk.result
}