resource "azurerm_resource_group" "cosmosdb" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                      = "${var.cosmos_db_account}"
  location                  = "${azurerm_resource_group.cosmosdb.location}"
  resource_group_name       = "${azurerm_resource_group.cosmosdb.name}"
  offer_type                = "${var.cosmos_db_offer_type}"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = true
  ip_range_filter           = "${var.enable_filewall ? "${var.allowed_ip_ranges}" : ""}"

  consistency_policy {
    consistency_level       = "${var.consistency_level}"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    prefix            = "${var.cosmos_db_account}-customid"
    location          = "${azurerm_resource_group.cosmosdb.location}"
    failover_priority = 0
  }

  geo_location {
    location          = "${var.alt_location}"
    failover_priority = 1
  }
}

resource "azurerm_cosmosdb_sql_database" "sqldb" {
  name                = "${var.cosmos_db_name}"
  resource_group_name = "${azurerm_cosmosdb_account.cosmosdb_account.resource_group_name}"
  account_name        = "${azurerm_cosmosdb_account.cosmosdb_account.name}"
}

resource "null_resource" "create_cosmosdb_sql_collections" {
  count = "${var.cosmos_db_collections != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_cosmosdb_collections.sh -a ${var.cosmos_db_account} -r ${var.resource_group_name} -d ${var.cosmos_db_name} -c \"${var.cosmos_db_collections}\""
  }

  triggers = {
    cosmos_db_account  = "${var.cosmos_db_account}"
    cosmos_db_name = "${var.cosmos_db_name}"
    cosmos_db_collections = "${var.cosmos_db_collections}"
  }

  depends_on = ["azurerm_cosmosdb_sql_database.sqldb"]
}
