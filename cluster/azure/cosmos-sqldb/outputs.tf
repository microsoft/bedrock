output "cosmosdb_created" {
  value = "${join("",null_resource.store_auth_key.*.id)}"
}