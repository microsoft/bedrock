resource "null_resource" "cosmosdb_account" {
  count = "${var.cosmos_db_account != "" && var.resource_group_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_cosmosdb_account.sh -a ${var.cosmos_db_account} -s \"${var.cosmosdb_subscription_id}\" -r ${var.resource_group_name} -c ${var.consistency_level} -l ${var.location}"
  }

  triggers = {
    cosmos_db_account        = "${var.cosmos_db_account}"
    cosmosdb_subscription_id = "${var.cosmosdb_subscription_id}"
    resource_group_name      = "${var.resource_group_name}"
    consistency_level        = "${var.consistency_level}"
  }
}

resource "null_resource" "create_cosmosdb_sql_collections" {
  count = "${var.cosmos_db_settings != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "pwsh ${path.module}/ensure_db_collections.ps1 -AccountName ${var.cosmos_db_account} -SubscriptionId \"${var.cosmosdb_subscription_id}\" -ResourceGroupName ${var.resource_group_name} -DbCollectionSettings \"${var.cosmos_db_settings}\""
  }

  triggers = {
    cosmos_db_account        = "${var.cosmos_db_account}"
    cosmosdb_subscription_id = "${var.cosmosdb_subscription_id}"
    cosmos_db_settings       = "${var.cosmos_db_settings}"
  }

  depends_on = ["null_resource.cosmosdb_account"]
}

resource "null_resource" "store_auth_key" {
  count = "${var.cosmos_db_account != "" && var.resource_group_name != "" && var.vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/store_authkey.sh -a ${var.cosmos_db_account} -s \"${var.cosmosdb_subscription_id}\" -r ${var.resource_group_name} -v \"${var.vault_name}\" -t \"${var.vault_subscription_id}\""
  }

  triggers = {
    cosmos_db_account        = "${var.cosmos_db_account}"
    cosmosdb_subscription_id = "${var.cosmosdb_subscription_id}"
    resource_group_name      = "${var.resource_group_name}"
    vault_name               = "${var.vault_name}"
    vault_subscription_id    = "${var.vault_subscription_id}"
  }

  depends_on = ["null_resource.cosmosdb_account"]
}

resource "null_resource" "backup_auth_key" {
  count = "${var.cosmos_db_account != "" && var.resource_group_name != "" && var.master_vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/store_authkey.sh -a ${var.cosmos_db_account} -s \"${var.cosmosdb_subscription_id}\" -r ${var.resource_group_name} -v \"${var.master_vault_name}\" -t \"${var.master_vault_subscription_id}\""
  }

  triggers = {
    cosmos_db_account            = "${var.cosmos_db_account}"
    cosmosdb_subscription_id     = "${var.cosmosdb_subscription_id}"
    resource_group_name          = "${var.resource_group_name}"
    master_vault_name            = "${var.master_vault_name}"
    master_vault_subscription_id = "${var.master_vault_subscription_id}"
  }

  depends_on = ["null_resource.cosmosdb_account"]
}
