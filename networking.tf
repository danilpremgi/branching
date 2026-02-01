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

resource "azurerm_subnet" "bastion" {
  name                 = local.subnet_bastion_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.2.3.0/27"]
}

resource "azurerm_subnet" "main" {
  name                 = local.subnet_main_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "ca" {
  name                 = local.subnet_ca_name
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

resource "azurerm_subnet_route_table_association" "ca" {
  subnet_id      = azurerm_subnet.ca.id
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
