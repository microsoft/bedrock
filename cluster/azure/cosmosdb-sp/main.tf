resource "null_resource" "deploy_stored_procedures" {
  count = "${var.cosmos_db_sp_names != "" && var.cosmos_db_collection != "" && var.cosmosdb_created == "true" ? 1 : 0}"

  provisioner "local-exec" {
    command = "pwsh ${path.module}/ensure_cosmosdb_sp.ps1 -AccountName ${var.cosmos_db_account} -SubscriptionId ${var.cosmosdb_subscription_id} -DbName ${var.cosmos_db_name} -CollectionName \"${var.cosmos_db_collection}\" -SpNames \"${var.cosmos_db_sp_names}\" -VaultName ${var.vault_name}"
  }

  triggers = {
    cosmos_db_account        = "${var.cosmos_db_account}"
    cosmosdb_subscription_id = "${var.cosmosdb_subscription_id}"
    cosmos_db_name           = "${var.cosmos_db_name}"
    cosmos_db_collection     = "${var.cosmos_db_collection}"
    cosmos_db_sp_names       = "${var.cosmos_db_sp_names}"
    cosmos_db_sp_versions    = "${var.cosmos_db_sp_versions}"
    recreate_collections     = "${var.recreate_collections}"
    cosmosdb_created         = "${var.cosmosdb_created}"
  }
}
