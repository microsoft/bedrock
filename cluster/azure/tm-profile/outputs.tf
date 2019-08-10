output "traffic_manager_fqdn" {
  value = "${azurerm_traffic_manager_profile.profile.fqdn}"
}

output "traffic_manager_name" {
  value = "${azurerm_traffic_manager_profile.profile.name}"
}
