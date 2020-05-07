terraform {
  backend "azurerm" {}
}

module "provider" {
  source = "../../azure/provider"
}

data "azurerm_resource_group" "global_rg" {
  name     = var.global_resource_group_name
}
