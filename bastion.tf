resource "azurerm_public_ip" "bastion" {
  name                = local.bastion_pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = local.bastion_name
  location            = azurerm_resource_group.main.location
  resource_group_name = local.rg_name
  sku                 = "Developer"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
