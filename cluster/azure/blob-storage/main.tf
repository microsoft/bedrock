provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

resource "azurerm_storage_account" "account" {
  name                     = "${var.storage_account}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "${var.account_tier}"
  account_replication_type = "${var.replication_type}"

  triggers = {
    name                     = "${var.storage_account}"
    account_tier             = "${var.account_tier}"
    account_replication_type = "${var.account_replication_type}"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "${var.container_name}"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${var.storage_account}"
  container_access_type = "${var.container_access_type}"

  triggers = {
    name                  = "${var.container_name}"
    storage_account_name  = "${var.storage_account_name}"
    container_access_type = "${var.container_access_type}"
  }

  depends_on = ["azurerm_storage_account.account"]
}

resource "azurerm_storage_blob" "blob" {
  name                   = "${var.blob_name}"
  resource_group_name    = "${var.resource_group_name}"
  storage_account_name   = "${var.storage_account}"
  storage_container_name = "${var.container_name}"
  type                   = "${var.blob_type}"

  triggers = {
    name                   = "${var.blob_name}"
    storage_account_name   = "${var.storage_account_name}"
    storage_container_name = "${var.storage_container_name}"
    type                   = "${var.blob_type}"
  }

  depends_on = ["azurerm_storage_container.container"]
}

resource "null_resource" "store_storage_account_key" {
  count = "${var.storage_account != "" && var.vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = <<-EOT
      ${path.module}/add_storage_account_key_secret.sh \
      -g ${var.resource_group_name} \
      -a ${var.storage_account} \
      -b ${var.subscription_id} \
      -v ${var.vault_name} \
      -n ${var.storage_account_key_secret_name} \
      -c ${var.vault_subscription_id}
    EOT
  }

  triggers = {
    storage_account                 = "${var.storage_account}"
    subscription_id                 = "${var.subscription_id}"
    vault_name                      = "${var.vault_name}"
    storage_account_key_secret_name = "${var.storage_account_key_secret_name}"
    vault_subscription_id           = "${var.vault_subscription_id}"
  }

  depends_on = ["azurerm_storage_account.account"]
}
