output "subnet_id" {
  description = "The id of the vNet"
  value       = "${azurerm_subnet.subnet.id}"
}