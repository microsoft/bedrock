output "pod_msi_id" {
  description = "The id of the msi"
  value       = "${join("",azurerm_user_assigned_identity.podid.*.id)}"
}

output "pod_msi_name" {
  description = "The name of the msi"
  value       = "${join("",azurerm_user_assigned_identity.podid.*.name)}"
}