resource "azurerm_resource_group" "tmrg" {
  name     = "${var.traffic_manager_resource_group_name}"
  location = "${var.traffic_manager_resource_group_location}"
}

module "trafficmanager" {
  source = "../../azure/tm-profile"

  resource_group_name          = "${azurerm_resource_group.tmrg.name}"
  resource_group_location      = "${azurerm_resource_group.tmrg.location}"
  traffic_manager_profile_name = "${var.traffic_manager_profile_name}"
  traffic_manager_dns_name     = "${var.traffic_manager_dns_name}"

  tags = {
    environment = "azure-multiple-clusters"
  }
}