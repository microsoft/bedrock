# Role assignment module
# This module uses the Azure CLI to add / remove an Azure Role Assignment 
# rather than the Terraform provider because the Azure Terraform provider 
# requires the use of an "object id" rather than the application or service
# principal id.  Using the azuread_service_principal data source requires 
# specicial privileges which may not be available.
#
# The Azure CLI allows the use of the service principal directly for the 
# `assignee` field.
#
# Once support is expanded in the Terraform module, this module should be 
# rewritten to use the provider directly.
resource "null_resource" "role_assignment" {
  provisioner "local-exec" {
    command = "az role assignment create --role \"${var.role_assignment_role}\" --assignee ${var.role_assignee} --scope ${var.role_scope}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "az role assignment delete --role \"${var.role_assignment_role}\" --assignee ${var.role_assignee} --scope ${var.role_scope}"
  }

  triggers = {
    precursor_done = "${var.precursor_done}"
  }
}