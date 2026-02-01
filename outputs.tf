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
  value = [for vm in module.dc_vms : vm.vm_name]
}

output "vm_private_ips" {
  value = [for vm in module.dc_vms : vm.private_ip]
}

output "ca_vm_names" {
  value = [for vm in module.ca_vms : vm.vm_name]
}

output "ca_vm_private_ips" {
  value = [for vm in module.ca_vms : vm.private_ip]
}

output "tertiary_virtual_network_name" {
  value = azurerm_virtual_network.tertiary.name
}

output "tertiary_vm_name" {
  value = module.tertiary_vm.vm_name
}

output "tertiary_vm_private_ip" {
  value = module.tertiary_vm.private_ip
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion.ip_address
}

output "admin_password" {
  value     = nonsensitive(random_password.admin.result)
  sensitive = false
}

output "nat_gateway_public_ips" {
  value = {
    firewall = azurerm_public_ip.firewall.ip_address
  }
}

output "firewall_private_ip" {
  value = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}
