#######################################################################
## Outputs
#######################################################################
output "local_hub_firewall_public_ip_address" {
  value       = azurerm_public_ip.local_fw_pip.ip_address
  description = "The public IP address of the local firewall"
}

output "remote_hub_firewall_public_ip_address" {
  value       = azurerm_public_ip.remote_fw_pip.ip_address
  description = "The public IP address of the remote firewall"
}

output "local_hub_firewall_private_ip_address" {
  value       = azurerm_firewall.local_fw.ip_configuration[0].private_ip_address
  description = "The private IP address of the local firewall"
}

output "local_network_gateway" {
  value       = azurerm_public_ip.local_gw_pip.ip_address
  description = "The public IP address of the local network gateway"
}

output "remote_hub_firewall_private_ip_address" {
  value       = azurerm_firewall.remote_fw.ip_configuration[0].private_ip_address
  description = "The private IP address of the local firewall"
}

output "local_vm_private_ip_address" {
  value       = azurerm_windows_virtual_machine.local_windows_vm.private_ip_address
  description = "The private IP address of the local virtual machine"
}

output "remote_vm_private_ip_address" {
  value       = azurerm_windows_virtual_machine.remote_windows_vm.private_ip_address
  description = "The private IP address of the remote virtual machine"
}

output "remote_network_gateway" {
  value       = azurerm_public_ip.remote_gw_pip.ip_address
  description = "The public IP address of the remote network gateway"
}