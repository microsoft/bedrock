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

resource "azurerm_role_assignment" "podid" {
  count                = "${var.enable_pod_identity ? 1 : 0}"
  principal_id         = "${var.service_principal_object_id}"
  role_definition_name = "Managed Identity Operator"
  scope                = "${azurerm_user_assigned_identity.podid.id}"
}
