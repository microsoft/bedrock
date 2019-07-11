resource "azurerm_resource_group" "tmrg" {
  count    = "${var.traffic_manager_resource_group_preallocated ? 0 : 1}"  
  name     = "${var.traffic_manager_resource_group_name}"
  location = "${var.traffic_manager_resource_group_location}"
}

data "azurerm_resource_group" "tmrg" {
  name     = "${var.traffic_manager_resource_group_preallocated ? var.traffic_manager_resource_group_name : join("", azurerm_resource_group.tmrg.*.name)}"
}

module "trafficmanager" {
  #source = "github.com/Microsoft/bedrock/cluster/azure/tm-profile"
  source = "../../azure/tm-profile"

  resource_group_name              = "${data.azurerm_resource_group.tmrg.name}"
  resource_group_location          = "${data.azurerm_resource_group.tmrg.location}"
  traffic_manager_profile_name     = "${var.traffic_manager_profile_name}"
  traffic_manager_dns_name         = "${var.traffic_manager_dns_name}"
  traffic_manager_monitor_protocol = "${var.traffic_manager_monitor_protocol}"
  traffic_manager_monitor_port     = "${var.traffic_manager_monitor_port}"

  tags = {
    environment = "azure-multiple-clusters"
  }
}
