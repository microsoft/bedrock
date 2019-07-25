output "id" {
  description = "Id of the keyvault policy"
  value       = "${null_resource.role_assignment.id}"
}