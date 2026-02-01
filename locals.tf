locals {
  rg_name                = var.resource_group_name
  vnet_main_name         = "vnet-main"
  vnet_hub_name          = "vnet-hub"
  vnet_tertiary_name     = "vnet-tertiary"
  subnet_hub_name        = "snet-hub"
  subnet_firewall_name   = "AzureFirewallSubnet"
  subnet_bastion_name    = "AzureBastionSubnet"
  subnet_main_name       = "snet-main"
  subnet_ca_name         = "snet-ca"
  subnet_tertiary_name   = "snet-tertiary"
  firewall_pip_name      = "pip-azfw-01"
  firewall_name          = "azfw-01"
  route_table_name       = "rt-default"
  bastion_pip_name       = "pip-bastion-01"
  bastion_name           = "bastion-01"
  vm_tertiary_name       = "vm-win11-01"
  vm_tertiary_nic_name   = "nic-vm-win11-01"
  tertiary_computer_name = "AZW11VM01"
  windows_server_image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
  windows_11_image = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }
  dc_vms = {
    "dc-01" = {
      vm_name       = "vm-dc-01"
      nic_name      = "nic-vm-dc-01"
      computer_name = "DC01"
      zone          = "1"
    }
    "dc-02" = {
      vm_name       = "vm-dc-02"
      nic_name      = "nic-vm-dc-02"
      computer_name = "DC02"
      zone          = "2"
    }
  }
  ca_vms = {
    "rca" = {
      vm_name       = "rca"
      nic_name      = "nic-rca-01"
      computer_name = "RCA"
      zone          = null
    }
    "ica" = {
      vm_name       = "ica"
      nic_name      = "nic-ica-01"
      computer_name = "ICA"
      zone          = null
    }
  }
}
