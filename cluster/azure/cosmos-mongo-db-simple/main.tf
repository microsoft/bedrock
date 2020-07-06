#Simple CosmosDB/MongoDB deployment. No multiregion failover support.

data "azurerm_resource_group" "cosmosdb_rg" {
  name = var.global_rg
}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = var.cosmos_db_name
  location            = data.azurerm_resource_group.cosmosdb_rg.location
  resource_group_name = data.azurerm_resource_group.cosmosdb_rg.name
  offer_type          = var.cosmos_db_offer_type
  kind                = "MongoDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    prefix            = "${var.cosmos_db_name}-customid"
    location          = data.azurerm_resource_group.cosmosdb_rg.location
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = var.mongo_db_name
  resource_group_name = azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
}
