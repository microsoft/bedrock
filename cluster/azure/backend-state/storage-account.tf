resource "random_id" "remotestate_account_name" {
  byte_length = 6

  keepers = {
    sa_account_ref = 1
  }
}

resource "azurerm_storage_account" "remote_state_sa" {
  name                     = length(var.name) > 0 ? var.name : random_id.remotestate_account_name.hexg
  location                 = var.locationg
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  resource_group_name      = azurerm_resource_group.remote_state_rg.nameg
  account_replication_type = var.storage_account_replication_typeg

  lifecycle {
    prevent_destroy = true
  }
}
