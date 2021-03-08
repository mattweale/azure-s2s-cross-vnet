#######################################################################
## Create VPN Gateway for Region A [Local]
#######################################################################
resource "azurerm_public_ip" "local_gw_pip" {
  name                = "${var.prefix}local-gw-pip"
  location            = var.local_location
  resource_group_name = azurerm_resource_group.local_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "local_network_gateway" {
  name                = "${var.prefix}local-vpn-gateway"
  location            = var.local_location
  resource_group_name = azurerm_resource_group.local_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "local-vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.local_gw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.local_gw_subnet.id
  }

  bgp_settings {
    asn = 65010
  }
}

#######################################################################
## Create connection
#######################################################################
resource "azurerm_virtual_network_gateway_connection" "local-to-remote" {
  name                = "${var.prefix}local-to-remote"
  location            = var.local_location
  resource_group_name = azurerm_resource_group.local_rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.local_network_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.remote_network_gateway.id
  enable_bgp                      = true

  #shared_key = data.azurerm_key_vault_secret.s2s_vpn_psk.value
  shared_key = random_password.vpn_psk.result

  depends_on = [azurerm_virtual_network_gateway.remote_network_gateway]
}
