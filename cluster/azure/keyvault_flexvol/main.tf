provider "null" {
    version = "~>2.0.0"
}

data "azuread_service_principal" "flexvol" {
  application_id = "${var.service_principal_id}"
}

resource "azurerm_role_assignment" "flexvol" {
  count  = "${var.enable_flexvol ? 1 : 0}"

  principal_id         = "${data.azuread_service_principal.flexvol.id}"
  role_definition_name = "${var.flexvol_role_assignment_role}"
  scope                = "/subscriptions/${var.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.keyvault_name}"
}

resource "azurerm_key_vault_access_policy" "flexvol" {
  count  = "${var.enable_flexvol ? 1 : 0}"

  vault_name          = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"

  tenant_id = "${var.tenant_id}"
  object_id = "${data.azuread_service_principal.flexvol.id}"

  key_permissions = "${var.flexvol_keyvault_key_permissions}"
  secret_permissions = "${var.flexvol_keyvault_secret_permissions}"
  certificate_permissions = "${var.flexvol_keyvault_certificate_permissions}"
}

resource "null_resource" "deploy_flexvol" {
  count  = "${var.enable_flexvol ? 1 : 0}"
  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfig_complete};KUBECONFIG=${var.output_directory}/${var.kubeconfig_filename} ${path.module}/deploy_flexvol.sh -i ${var.service_principal_id} -p ${var.service_principal_secret} -u ${var.flexvol_deployment_url}"
  }

  triggers {
    enable_flexvol  = "${var.enable_flexvol}"
    flexvol_recreate = "${var.flexvol_recreate}"
  }
}
