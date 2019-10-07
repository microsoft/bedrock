resource "null_resource" "cosmosdb_account" {
  count = "${var.cosmos_db_account != "" && var.resource_group_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_cosmosdb_account.sh -a ${var.cosmos_db_account} -r ${var.resource_group_name} -c ${var.consistency_level} -l ${var.location}"
  }

  triggers = {
    cosmos_db_account   = "${var.cosmos_db_account}"
    resource_group_name = "${var.resource_group_name}"
    consistency_level   = "${var.consistency_level}"
    recreate = "${var.recreate_cosmosdb_account}"
  }
}

resource "null_resource" "cosmosdb_db" {
  count = "${var.cosmos_db_account != "" && var.resource_group_name != "" && var.cosmos_db_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_cosmosdb_db.sh -a ${var.cosmos_db_account} -r ${var.resource_group_name} -d ${var.cosmos_db_name}"
  }

  triggers = {
    cosmos_db_account   = "${var.cosmos_db_account}"
    resource_group_name = "${var.resource_group_name}"
    cosmos_db_name      = "${var.cosmos_db_name}"
  }

  depends_on = ["null_resource.cosmosdb_account"]
}

resource "null_resource" "create_cosmosdb_sql_collections" {
  count = "${var.cosmos_db_collections != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_cosmosdb_collections.sh -a ${var.cosmos_db_account} -r ${var.resource_group_name} -d ${var.cosmos_db_name} -c \"${var.cosmos_db_collections}\""
  }

  triggers = {
    cosmos_db_account     = "${var.cosmos_db_account}"
    cosmos_db_name        = "${var.cosmos_db_name}"
    cosmos_db_collections = "${var.cosmos_db_collections}"
  }

  depends_on = ["null_resource.cosmosdb_db"]
}

resource "null_resource" "store_auth_key" {
  count = "${var.cosmos_db_collections != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/store_authkey.sh -a ${var.cosmos_db_account} -r ${var.resource_group_name} -v \"${var.vault_name}\""
  }

  triggers = {
    cosmos_db_account   = "${var.cosmos_db_account}"
    resource_group_name = "${var.resource_group_name}"
    vault_name          = "${var.vault_name}"
  }

  depends_on = ["null_resource.cosmosdb_account"]
}

resource "null_resource" "backup_auth_key" {
  count = "${var.cosmos_db_collections != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/store_authkey.sh -a ${var.cosmos_db_account} -r ${var.resource_group_name} -v \"${var.master_vault_name}\""
  }

  triggers = {
    cosmos_db_account   = "${var.cosmos_db_account}"
    resource_group_name = "${var.resource_group_name}"
    master_vault_name   = "${var.master_vault_name}"
  }

  depends_on = ["null_resource.cosmosdb_account"]
}
