terraform {
  backend "azurerm" {}
}

module "provider" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/azure/provider"
}

resource "azurerm_resource_group" "global_rg" {
  name     = "${var.global_resource_group_name}"
  location = "${var.global_resource_group_location}"
}
