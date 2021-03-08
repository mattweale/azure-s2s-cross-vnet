#######################################################################
## Create Virtual Machine into each [Local and Remote] Spoke vNET
#######################################################################
# Local First
#######################################################################
resource "azurerm_network_interface" "local_vmnic" {
  name                = "${var.prefix}local-win-dev-vm-nic"
  location            = var.local_location
  resource_group_name = azurerm_resource_group.local_rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.local_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "local_windows_vm" {
  name                = "local-dev-vm"
  resource_group_name = azurerm_resource_group.local_rg.name
  location            = var.local_location
  size                = var.vmsize
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.local_vmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-ent-g2"
    version   = "latest"
  }
}

#######################################################################
# Now Remote
#######################################################################
resource "azurerm_network_interface" "remote_vmnic" {
  name                = "${var.prefix}remote-win-dev-vm-nic"
  location            = var.remote_location
  resource_group_name = azurerm_resource_group.remote_rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.remote_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "remote_windows_vm" {
  name                = "remote-dev-vm"
  resource_group_name = azurerm_resource_group.remote_rg.name
  location            = var.remote_location
  size                = var.vmsize
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.remote_vmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-ent-g2"
    version   = "latest"
  }
}