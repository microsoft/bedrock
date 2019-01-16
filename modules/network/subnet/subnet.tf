resource "azurerm_subnet" "cluster" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = "${var.resource_group_name}"
  address_prefix       = "${var.subnet_address_space}"
  virtual_network_name = "${var.virtual_network_name}"
}