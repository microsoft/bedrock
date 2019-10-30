variable "cosmosdb_subscription_id" {
  type    = "string"
  default = ""       # reuse existing subscription if empty
}

variable "vault_subscription_id" {
  type    = "string"
  default = ""       # reuse existing subscription if empty
}

variable "master_vault_subscription_id" {
  type    = "string"
  default = ""       # reuse existing subscription if empty
}

variable "resource_group_name" {
  type        = "string"
  description = "The resource group name for this cosmos db"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "alt_location" {
  type        = "string"
  description = "The Azure Region which should be used for the alternate location when failed over."
}

variable "cosmos_db_account" {
  type        = "string"
  description = "name of cosmosdb account"
}

variable "recreate_cosmosdb_account" {
  type    = "string"
  default = "false"
}

variable "consistency_level" {
  type        = "string"
  description = "cosmosdb consistency level: BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix"
  default     = "Session"
}

variable "enable_filewall" {
  type        = "string"
  description = "Specify if firewall rules should be applied"
  default     = "false"
}

variable "allowed_ip_ranges" {
  type        = "string"
  description = "allowed ip range in addition to azure services and azure portal, i.e. 12.54.145.0/24,13.75.0.0/16"
}

variable "cosmos_db_offer_type" {
  type    = "string"
  default = "Standard"
}

variable "cosmos_db_name" {
  type        = "string"
  description = "CosmosDB name"
}

variable "cosmos_db_collections" {
  type        = "string"
  description = "collections are separated by ';', each entry takes the format: collection_name,partiton_key,throughput"
}

variable "vault_name" {
  type        = "string"
  description = "key vault to store auth key of cosmosdb connection"
}

variable "master_vault_name" {
  type        = "string"
  description = "master key vault to store auth key of cosmosdb connection"
}

variable "recreate_collections" {
  type        = "string"
  description = "when turned on (true), existing collections will be removed and created again"
  default     = "false"
}