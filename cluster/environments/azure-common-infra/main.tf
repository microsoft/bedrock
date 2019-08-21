terraform {
  backend "azurerm" {}
}

module "provider" {
  source = "github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/provider"
}

data "azurerm_resource_group" "global_rg" {
  name     = "${var.global_resource_group_name}"
}
