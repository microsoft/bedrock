resource "azurerm_resource_group" "tmrg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

# Creates Azure Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "profile" {
  name                   = "${var.traffic_manager_profile_name}"
  resource_group_name    = "${azurerm_resource_group.tmrg.name}"
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "${var.traffic_manager_dns_name}"
    ttl           = 30
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }

  tags = "${var.tags}"
}
