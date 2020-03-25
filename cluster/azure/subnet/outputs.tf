output "subnet_ids" {
  description = "The id of the subnet"
  value       = azurerm_subnet.subnet.*.id
}
