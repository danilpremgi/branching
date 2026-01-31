locals {
  rg_name                    = var.resource_group_name
  vnet_main_name             = "vnet-main"
  vnet_hub_name              = "vnet-hub"
  vnet_tertiary_name         = "vnet-tertiary"
  subnet_hub_name            = "snet-hub"
  subnet_main_name           = "snet-main"
  subnet_secondary_name      = "snet-secondary"
  subnet_tertiary_name       = "snet-tertiary"
  nat_hub_pip_name           = "pip-nat-hub"
  nat_hub_name               = "natgw-hub"
  jumpbox_pip_name           = "pip-jumpbox"
  jumpbox_nic_name           = "nic-jumpbox-01"
  jumpbox_vm_name            = "vm-jumpbox-01"
  vm_tertiary_name           = "vm-win11-01"
  vm_tertiary_nic_name       = "nic-win11-01"
  jumpbox_computer_name      = "AZJUMP01"
  tertiary_computer_name     = "AZW11VM01"
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
  primary_vms = {
    "01" = {
      vm_name       = "vm-01"
      nic_name      = "nic-01"
      computer_name = "AZVM01"
      zone          = "1"
    }
    "02" = {
      vm_name       = "vm-02"
      nic_name      = "nic-02"
      computer_name = "AZVM02"
      zone          = "2"
    }
  }
  secondary_vms = {
    "01" = {
      vm_name       = "vm-secondary-01"
      nic_name      = "nic-secondary-01"
      computer_name = "AZSEC01"
      zone          = null
    }
    "02" = {
      vm_name       = "vm-secondary-02"
      nic_name      = "nic-secondary-02"
      computer_name = "AZSEC02"
      zone          = null
    }
  }
}
