# Create virtual network
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  count                = length(var.subnet_name)
  name                 = var.subnet_name[count.index]
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name

  address_prefix    = var.address_prefix[count.index]
  service_endpoints = var.service_endpoints[count.index]
}
