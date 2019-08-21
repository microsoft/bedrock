module "vnet" {
  source = "github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/vnet"

  vnet_name = "${var.vnet_name}"

  address_space   = "${var.address_space}"
  subnet_prefixes = ["${var.subnet_prefix}"]

  resource_group_name     = "${data.azurerm_resource_group.global_rg.name}"
  subnet_names            = ["${var.subnet_name}"]
}

//Used for integration test to automate providing vnet_subnet_ids to separate environments for aks clusters
output "vnet_subnet_id" {
  description = "The ids of subnets created inside the vNet"
  value       = "${module.vnet.vnet_subnet_ids[0]}"
}
