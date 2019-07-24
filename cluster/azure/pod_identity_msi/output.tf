output "pod_msi_id" {
  description = "The id of the msi"
  value       = "${join("",azurerm_user_assigned_identity.podid.*.id)}"
}

output "pod_msi_name" {
  description = "The name of the msi"
  value       = "${join("",azurerm_user_assigned_identity.podid.*.name)}"
}

output "pod_msi_client_id" {
  description = "The client Id of the MSI"
  value       = "${join("",azurerm_user_assigned_identity.podid.*.client_id)}"
}

output "pod_msi_principal_id" {
  description = "The principal Id of the MSI"
  value       = "${join("",azurerm_user_assigned_identity.podid.*.principal_id)}"
}