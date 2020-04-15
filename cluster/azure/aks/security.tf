locals {
  identity_name = "${var.cluster_name}-akspodidentity"
}

resource "azurerm_user_assigned_identity" "aks_user_identity" {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.cluster.location
  name                = local.identity_name
}

 resource "azurerm_role_assignment" "aks_kubelet_operator" {
  count                = var.msi_enabled ? 1 : 0
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_user_identity.principal_id
  scope                = data.external.msi_object_id.result.kubelet_id
}

resource "azurerm_role_assignment" "aks_kubelet_reader" {
  count                = var.msi_enabled ? 1 : 0
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aks_user_identity.principal_id
  scope                = data.external.msi_object_id.result.kubelet_id
}