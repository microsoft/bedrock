resource "null_resource" "deploy_stored_procedures" {
  count = "${var.cosmos_db_sp_names != "" && var.cosmos_db_collection != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "pwsh ${path.module}/ensure_cosmosdb_sp.ps1 -AccountName ${var.cosmos_db_account} -DbName ${var.cosmos_db_name} -CollectionName \"${var.cosmos_db_collection}\" -SpNames \"${var.cosmos_db_sp_names}\" -VaultName ${var.vault_name}"
  }

  triggers = {
    cosmos_db_account     = "${var.cosmos_db_account}"
    cosmos_db_name        = "${var.cosmos_db_name}"
    cosmos_db_collection  = "${var.cosmos_db_collection}"
    cosmos_db_sp_names    = "${var.cosmos_db_sp_names}"
    cosmos_db_sp_versions = "${var.cosmos_db_sp_versions}"
  }
}
