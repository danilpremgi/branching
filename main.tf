terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  prefix                     = var.name_prefix
  rg_name                    = var.resource_group_name
  vnet_main_name             = "${local.prefix}-vnet"
  vnet_hub_name              = "${local.prefix}-vnet-hub"
  vnet_tertiary_name         = "${local.prefix}-vnet-tertiary"
  subnet_hub_name            = "${local.prefix}-snet-hub"
  subnet_main_name           = "${local.prefix}-snet-main"
  subnet_secondary_name      = "${local.prefix}-snet-secondary"
  subnet_tertiary_name       = "${local.prefix}-snet-tertiary"
  nat_pip_name               = "${local.prefix}-pip-nat"
  nat_name                   = "${local.prefix}-natgw"
  jumpbox_pip_name           = "${local.prefix}-pip-jumpbox"
  jumpbox_nsg_name           = "${local.prefix}-nsg-jumpbox"
  jumpbox_nic_name           = "${local.prefix}-nic-jumpbox"
  jumpbox_vm_name            = "${local.prefix}-vm-jumpbox"
  vm_primary_name_prefix     = "${local.prefix}-vm"
  vm_secondary_name_prefix   = "${local.prefix}-vm-secondary"
  vm_tertiary_name           = "${local.prefix}-vm-win11"
  vm_primary_nic_prefix      = "${local.prefix}-nic"
  vm_secondary_nic_prefix    = "${local.prefix}-nic-secondary"
  vm_tertiary_nic_name       = "${local.prefix}-nic-win11"
  jumpbox_computer_name      = "AZJUMP01"
  primary_computer_names     = ["AZVM01", "AZVM02"]
  secondary_computer_names   = ["AZSEC01", "AZSEC02"]
  tertiary_computer_name     = "AZW11VM01"
}

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

resource "azurerm_public_ip" "nat" {
  name                = local.nat_pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                = local.nat_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "hub" {
  subnet_id      = azurerm_subnet.hub.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  subnet_id      = azurerm_subnet.main.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "secondary" {
  subnet_id      = azurerm_subnet.secondary.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "tertiary" {
  subnet_id      = azurerm_subnet.tertiary.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_virtual_network_peering" "hub_to_main" {
  name                      = "${local.prefix}-peer-hub-main"
  resource_group_name       = local.rg_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.main.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "main_to_hub" {
  name                      = "${local.prefix}-peer-main-hub"
  resource_group_name       = local.rg_name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub_to_tertiary" {
  name                      = "${local.prefix}-peer-hub-tertiary"
  resource_group_name       = local.rg_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.tertiary.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "tertiary_to_hub" {
  name                      = "${local.prefix}-peer-tertiary-hub"
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
  name                = local.jumpbox_nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name

  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.jumpbox_allowed_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "jumpbox" {
  name                = local.jumpbox_nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }
}

resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = azurerm_network_interface.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

resource "azurerm_windows_virtual_machine" "jumpbox" {
  name                = local.jumpbox_vm_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  size                = var.jumpbox_vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  computer_name       = local.jumpbox_computer_name
  network_interface_ids = [
    azurerm_network_interface.jumpbox.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "vm" {
  count               = 2
  name                = "${local.vm_primary_nic_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = 2
  name                = "${local.vm_primary_name_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  computer_name       = local.primary_computer_names[count.index]
  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id
  ]
  zone = tostring(count.index + 1)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "secondary_vm" {
  count               = 2
  name                = "${local.vm_secondary_nic_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.secondary.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "secondary_vm" {
  count               = 2
  name                = "${local.vm_secondary_name_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  computer_name       = local.secondary_computer_names[count.index]
  network_interface_ids = [
    azurerm_network_interface.secondary_vm[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "tertiary_vm" {
  name                = local.vm_tertiary_nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tertiary.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "tertiary_vm" {
  name                = local.vm_tertiary_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin.result
  computer_name       = local.tertiary_computer_name
  network_interface_ids = [
    azurerm_network_interface.tertiary_vm.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-pro"
    version   = "latest"
  }
}
