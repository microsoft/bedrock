#terraform {
#  backend "azurerm" {}
#}

provider "azurerm" {
  version = "~> 2.8"
  features {}
}

module "provider" {
  source = "../../azure/provider"
}

data "azurerm_resource_group" "global_rg" {
  name     = var.global_resource_group_name
}
