variable "cosmos_db_account" {
  type        = "string"
  description = "name of cosmosdb account"
}

variable "cosmosdb_subscription_id" {
  type    = "string"
  default = ""       # reuse existing subscription if empty
}

variable "cosmos_db_name" {
  type        = "string"
  description = "CosmosDB name"
}

variable "cosmos_db_collection" {
  type        = "string"
  description = "name of collection"
}

variable "cosmos_db_sp_names" {
  type        = "string"
  description = "list of sp names and definition secret separated by ',', i.e. bulkDelete=products-bulk-delete,touchDocuments=products-touch-documents"
}

variable "cosmos_db_sp_versions" {
  type        = "string"
  description = "list of kv versions for sp definitions, will trigger new deployment when it got changed"
}

variable "vault_name" {
  type        = "string"
  description = "key vault to store auth key of cosmosdb connection"
}

variable "recreate_collections" {
  type        = "string"
  description = "when turned on (true), existing collections will be removed and created again"
  default     = "false"
}

variable "cosmosdb_created" {
  type        = "string"
  default     = "false"
  description = "output from cosmosdb module, must be true in order to proceed"
}
