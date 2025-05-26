output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value     = var.admin_password
  sensitive = true
}

