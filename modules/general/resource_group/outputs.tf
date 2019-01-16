output "name" {
  value = "${azurerm_resource_group.cluster.name}"
}

output "location" {
  value = "${azurerm_resource_group.cluster.location}"
}
