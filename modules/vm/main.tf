resource "azurerm_network_interface" "this" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  computer_name       = var.computer_name
  zone                = var.zone
  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}

locals {
  data_disks_by_lun = { for disk in var.data_disks : disk.lun => disk }
}

resource "azurerm_managed_disk" "data" {
  for_each             = local.data_disks_by_lun
  name                 = "${var.vm_name}-data-${format("%02d", each.value.lun)}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each           = azurerm_managed_disk.data
  managed_disk_id    = each.value.id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = each.key
  caching            = local.data_disks_by_lun[each.key].caching
}
