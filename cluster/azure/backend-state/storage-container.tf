resource "azurerm_storage_container" "terraform_remote_state_container" {
  name                 = "${local.name}-remote-state-container"
  resource_group_name  = azurerm_resource_group.remote_state_rg.name
  storage_account_name = azurerm_storage_account.remote_state_sa.name

  lifecycle {
    prevent_destroy = true
  }
}
