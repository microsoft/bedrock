#Simple CosmosDB/MongoDB deployment. No multiregion failover support.

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
  # uncomment the next line when upgrated to v0.12
  # ip_range_filter           = "${var.enable_filewall} ? \"0.0.0.0,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26,${var.allowed_ip_ranges}\" : null"

  consistency_policy {
    consistency_level       = "${var.consistency_level}"
    max_interval_in_seconds = 10
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
    command = "${path.module}/ensure_cosmosdb_collections.sh -a ${var.cosmos_db_account} -r ${var.resource_group_name} -d ${var.cosmos_db_name} -c ${var.cosmos_db_collections}"
  }

  triggers {
    cosmos_db_account  = "${var.cosmos_db_account}"
    cosmos_db_name = "${var.cosmos_db_name}"
    cosmos_db_collections = "${var.cosmos_db_collections}"
  }

  depends_on = ["azurerm_cosmosdb_sql_database.sqldb"]
}
