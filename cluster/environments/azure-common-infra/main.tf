terraform {
  backend "azurerm" {}
}

resource "azurerm_resource_group" "global_rg" {
  name     = "${var.global_resource_group_name}"
  location = "${var.global_resource_group_location}"
}
