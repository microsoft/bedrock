module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "podid" {
  name = "${var.resource_group_name}"
}

resource "azurerm_user_assigned_identity" "podid" {
  count               = "${var.enable_pod_identity ? 1 : 0}"
  name                = "${var.identity_name}"
  resource_group_name = "${data.azurerm_resource_group.podid.name}"
  location            = "${data.azurerm_resource_group.podid.location}"
}

resource "null_resource" "podid_msi" {
  provisioner "local-exec" {
    command = "az role assignment create --role \"Managed Identity Operator\" --assignee ${var.service_principal_id} --scope ${azurerm_user_assigned_identity.podid.id}"
  }
}