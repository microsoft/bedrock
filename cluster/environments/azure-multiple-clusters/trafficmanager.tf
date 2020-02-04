data "azurerm_resource_group" "tmrg" {
  name     = var.traffic_manager_resource_group_name
}

module "trafficmanager" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/tm-profile"
  source = "../../azure/tm-profile"

  resource_group_name              = data.azurerm_resource_group.tmrg.name
  traffic_manager_profile_name     = var.traffic_manager_profile_name
  traffic_manager_dns_name         = var.traffic_manager_dns_name
  traffic_manager_monitor_protocol = var.traffic_manager_monitor_protocol
  traffic_manager_monitor_port     = var.traffic_manager_monitor_port

  tags = {
    environment = "azure-multiple-clusters"
  }
}
