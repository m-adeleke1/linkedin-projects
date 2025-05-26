variable "resource_group_name" {
  type    = string
  default = "mcp-rg"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_name" {
  type    = string
  default = "mcp-vm"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
  description = "Password for the VM admin user"
}

