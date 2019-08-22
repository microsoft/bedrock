terraform {
  backend "azurerm" {}
}

module "provider" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/provider"
}

data "azurerm_resource_group" "global_rg" {
  name     = "${var.global_resource_group_name}"
}
