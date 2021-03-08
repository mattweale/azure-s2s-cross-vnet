variable "arm_tenant_id" {
  description = "Tenant ID"
  type        = string
}
variable "arm_subscription_id" {
  description = "Subscrption ID"
  type        = string
}
variable "arm_client_id" {
  description = "Service Principal client id"
  type        = string
}
variable "local_location" {
  description = "Local Region"
  type        = string
  default     = "UK South"
}
variable "remote_location" {
  description = "Remote Region"
  type        = string
  default     = "North Europe"
}
variable "prefix" {
  description = "Default Naming Prefix"
  type        = string
  default     = "tf-s2s-cross-vnet-lab-"
}
variable "tags" {
  type        = map(any)
  description = "Tags to be attached to azure resources"
}
variable "username" {
  description = "Username for Virtual Machines"
  type        = string
  default     = "adminuser"
}
variable "password" {
  description = "Virtual Machine password, must meet Azure complexity requirements"
  type        = string
  default     = "Pa55w0rd123!"
}
variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_D4s_v3"
}
variable "source_ip" {
  description = "Source ip address for RDP inbound"
  #default     = "Your IP"
}