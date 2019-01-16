resource "azurerm_virtual_network" "cluster" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${var.cluster_location}"
  resource_group_name = "${var.resource_group_name}"
}