output "cosmosdb_created" {
  value = "${join("",null_resource.cosmosdb_account.*.id)}"
}