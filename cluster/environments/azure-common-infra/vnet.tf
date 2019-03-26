module "vnet" {
  source = "github.com/Microsoft/bedrock/cluster/azure/vnet"

  vnet_name = "${var.vnet_name}"

  address_space   = "${var.address_space}"
  subnet_prefixes = ["${var.subnet_prefix}"]

  resource_group_name     = "${azurerm_resource_group.global_rg.name}"
  resource_group_location = "${azurerm_resource_group.global_rg.location}"
  subnet_names            = ["${var.subnet_name}"]
}
