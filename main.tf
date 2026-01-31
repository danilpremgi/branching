resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
}

resource "random_password" "admin" {
  length           = 20
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!@#%^*-_=+?"
}

resource "azurerm_virtual_network" "main" {
  name                = local.vnet_main_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
}

resource "azurerm_virtual_network" "hub" {
  name                = local.vnet_hub_name
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
}

resource "azurerm_virtual_network" "tertiary" {
  name                = local.vnet_tertiary_name
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
}

resource "azurerm_subnet" "hub" {
  name                 = local.subnet_hub_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = local.subnet_firewall_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_subnet" "main" {
  name                 = local.subnet_main_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "secondary" {
  name                 = local.subnet_secondary_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "tertiary" {
  name                 = local.subnet_tertiary_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.tertiary.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "firewall" {
  name                = local.firewall_pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = local.firewall_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_route_table" "egress" {
  name                = local.route_table_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
}

resource "azurerm_route" "egress" {
  name                   = "default-egress"
  resource_group_name    = local.rg_name
  route_table_name       = azurerm_route_table.egress.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.main.id
  route_table_id = azurerm_route_table.egress.id
}

resource "azurerm_subnet_route_table_association" "secondary" {
  subnet_id      = azurerm_subnet.secondary.id
  route_table_id = azurerm_route_table.egress.id
}

resource "azurerm_subnet_route_table_association" "tertiary" {
  subnet_id      = azurerm_subnet.tertiary.id
  route_table_id = azurerm_route_table.egress.id
}


resource "azurerm_virtual_network_peering" "hub_to_main" {
  name                      = "peer-hub-main"
  resource_group_name       = local.rg_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.main.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "main_to_hub" {
  name                      = "peer-main-hub"
  resource_group_name       = local.rg_name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub_to_tertiary" {
  name                      = "peer-hub-tertiary"
  resource_group_name       = local.rg_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.tertiary.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "tertiary_to_hub" {
  name                      = "peer-tertiary-hub"
  resource_group_name       = local.rg_name
  virtual_network_name      = azurerm_virtual_network.tertiary.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

resource "azurerm_public_ip" "jumpbox" {
  name                = local.jumpbox_pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "jumpbox" {
  name                = "nsg-jumpbox"
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
}

resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = module.jumpbox_vm.nic_id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

module "jumpbox_vm" {
  source              = "./modules/vm"
  vm_name             = local.jumpbox_vm_name
  computer_name       = local.jumpbox_computer_name
  nic_name            = local.jumpbox_nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.hub.id
  public_ip_id        = azurerm_public_ip.jumpbox.id
  vm_size             = var.jumpbox_vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  source_image_reference = local.windows_server_image
}

resource "azurerm_security_center_jit_network_access_policy" "jumpbox" {
  name                = "jit-jumpbox"
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  kind                = "Basic"

  virtual_machine {
    id = module.jumpbox_vm.vm_id

    port {
      number                     = 3389
      protocol                   = "*"
      allowed_source_address_prefix = "*"
      max_request_access_duration   = "PT3H"
    }
  }
}

module "primary_vms" {
  source              = "./modules/vm"
  for_each            = local.primary_vms
  vm_name             = each.value.vm_name
  computer_name       = each.value.computer_name
  nic_name            = each.value.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.main.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  zone                = each.value.zone
  source_image_reference = local.windows_server_image
}

module "secondary_vms" {
  source              = "./modules/vm"
  for_each            = local.secondary_vms
  vm_name             = each.value.vm_name
  computer_name       = each.value.computer_name
  nic_name            = each.value.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.secondary.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  zone                = each.value.zone
  source_image_reference = local.windows_server_image
}

module "tertiary_vm" {
  source              = "./modules/vm"
  vm_name             = local.vm_tertiary_name
  computer_name       = local.tertiary_computer_name
  nic_name            = local.vm_tertiary_nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.tertiary.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  source_image_reference = local.windows_11_image
}
