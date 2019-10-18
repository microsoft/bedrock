
resource "null_resource" "deploy_stored_procedures" {
  count = "${var.sp_names != "" && var.collection_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "pwsh ${path.module}/ensure_cosmosdb_sp.ps1 -AccountName ${var.cosmos_db_account} -DbName ${var.cosmos_db_name} -CollectionName \"${var.cosmos_db_collection}\" -SpNames \"${var.sp_names}\" -VaultName ${var.cosmos_db_sp_names}"
  }
}
