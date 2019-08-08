output "cosmos_db_id" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.id}"
}

output "cosmos_db_endpoint" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.endpoint}"
}

output "cosmos_db_endpoints_read" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.read_endpoints}"
}

output "cosmos_db_endpoints_write" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.write_endpoints}"
}

output "cosmos_db_primary_master_key" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.primary_master_key}"
}

output "cosmos_db_secondary_master_key" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.secondary_master_key}"
}

output "cosmos_db_primary_readonly_master_key" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.primary_readonly_master_key}"
}

output "cosmos_db_secondary_readonly_master_key" {
  value = "${azurerm_cosmosdb_account.cosmosdb_account.secondary_readonly_master_key}"
}
