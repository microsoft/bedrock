# provider "azurerm" {
#     version = "~>1.18"
# }

# # Create virtual network
# data "azurerm_virtual_network" "tfvneteast" {
#   name                = "${var.vnet_east}"
#   resource_group_name          = "${var.resource_group_name_east}"
# }

# resource "azurerm_subnet" "tfwafneteast" {
#   name                 = "wafneteast"
#   # virtual_network_name = "${data.azurerm_virtual_network.tfvneteast.name}"
#   virtual_network_name = "${data.azurerm_virtual_network.tfvneteast.name}"
#   resource_group_name          = "${var.resource_group_name_east}"
#   address_prefix       = "10.0.30.0/24"
# }



# data "azurerm_virtual_network" "tfvnetwest" {
#  name                = "${var.vnet_west}"
# resource_group_name          = "${var.resource_group_name_west}"
# }

# resource "azurerm_subnet" "tfwafnetwest" {
#   name                 = "wafnetwest"
#   virtual_network_name = "${data.azurerm_virtual_network.tfvnetwest.name}"
#   resource_group_name  = "${var.resource_group_name_west}"
#   address_prefix       = "10.0.30.0/24"
# }


# data "azurerm_virtual_network" "tfvnetcentral" {
# name                = "${var.vnet_central}"
# resource_group_name          = "${var.resource_group_name_central}"
# }

# resource "azurerm_subnet" "tfwafnetcentral" {
#   name                 = "wafnetcentral"
#   virtual_network_name = "${data.azurerm_virtual_network.tfvnetcentral.name}"
#   resource_group_name          = "${var.resource_group_name_central}"
#   address_prefix       = "10.0.30.0/24"
# }


############## Traffic manager #############

