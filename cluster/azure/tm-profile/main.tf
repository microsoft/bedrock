data "azurerm_resource_group" "tmrg" {
  name     = var.resource_group_name
}

# Creates Azure Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "profile" {
  name                   = var.traffic_manager_profile_name
  resource_group_name    = data.azurerm_resource_group.tmrg.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = var.traffic_manager_dns_name
    ttl           = 30
  }

  monitor_config {
    protocol = var.traffic_manager_monitor_protocol
    port     = var.traffic_manager_monitor_port
    path     = "/"
  }

  tags = var.tags
}
