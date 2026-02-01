module "primary_vms" {
  source                 = "./modules/vm"
  for_each               = local.primary_vms
  vm_name                = each.value.vm_name
  computer_name          = each.value.computer_name
  nic_name               = each.value.nic_name
  location               = azurerm_resource_group.main.location
  resource_group_name    = local.rg_name
  subnet_id              = azurerm_subnet.main.id
  vm_size                = var.vm_size
  admin_username         = var.admin_username
  admin_password         = random_password.admin.result
  zone                   = each.value.zone
  source_image_reference = local.windows_server_image
}

module "secondary_vms" {
  source                 = "./modules/vm"
  for_each               = local.secondary_vms
  vm_name                = each.value.vm_name
  computer_name          = each.value.computer_name
  nic_name               = each.value.nic_name
  location               = azurerm_resource_group.main.location
  resource_group_name    = local.rg_name
  subnet_id              = azurerm_subnet.secondary.id
  vm_size                = var.vm_size
  admin_username         = var.admin_username
  admin_password         = random_password.admin.result
  zone                   = each.value.zone
  source_image_reference = local.windows_server_image
}

module "tertiary_vm" {
  source                 = "./modules/vm"
  vm_name                = local.vm_tertiary_name
  computer_name          = local.tertiary_computer_name
  nic_name               = local.vm_tertiary_nic_name
  location               = azurerm_resource_group.main.location
  resource_group_name    = local.rg_name
  subnet_id              = azurerm_subnet.tertiary.id
  vm_size                = var.vm_size
  admin_username         = var.admin_username
  admin_password         = random_password.admin.result
  source_image_reference = local.windows_11_image
}
