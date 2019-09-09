output "id" {
  description = "Id of the keyvault policy"
  value       = "${azurerm_role_assignment.role.id}"
}