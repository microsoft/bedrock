output "vnet_id" {
  description = "The id of the vNet"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The Name of the vNet"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_location" {
  description = "The location of the vNet"
  value       = azurerm_virtual_network.vnet.location
}

output "vnet_address_space" {
  description = "The address space of the vNet"
  value       = azurerm_virtual_network.vnet.address_space
}

output "vnet_subnet_ids" {
  description = "The ids of subnets created inside the vNet"
  value       = azurerm_subnet.subnet.*.id
}

output "aks_vnet_subnet" {
  description = "The id of the subnet created inside the vNet used by aks"
  value       = azurerm_subnet.subnet[0].id
}
