module "vnet" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/vnet"
  source = "../../../cluster/azure/vnet"

  resource_group_name     = data.azurerm_resource_group.global_rg.name
  vnet_name = var.vnet_name
  address_space   = var.address_space
}
