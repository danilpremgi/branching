output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.main.name
}

output "hub_virtual_network_name" {
  value = azurerm_virtual_network.hub.name
}

output "vm_names" {
  value = azurerm_windows_virtual_machine.vm[*].name
}

output "vm_private_ips" {
  value = azurerm_network_interface.vm[*].private_ip_address
}

output "secondary_vm_names" {
  value = azurerm_windows_virtual_machine.secondary_vm[*].name
}

output "secondary_vm_private_ips" {
  value = azurerm_network_interface.secondary_vm[*].private_ip_address
}

output "tertiary_virtual_network_name" {
  value = azurerm_virtual_network.tertiary.name
}

output "tertiary_vm_name" {
  value = azurerm_windows_virtual_machine.tertiary_vm.name
}

output "tertiary_vm_private_ip" {
  value = azurerm_network_interface.tertiary_vm.private_ip_address
}

output "jumpbox_public_ip" {
  value = azurerm_public_ip.jumpbox.ip_address
}

output "admin_password" {
  value     = nonsensitive(random_password.admin.result)
  sensitive = false
}

output "nat_gateway_public_ips" {
  value = {
    hub = azurerm_public_ip.nat_hub.ip_address
  }
}
