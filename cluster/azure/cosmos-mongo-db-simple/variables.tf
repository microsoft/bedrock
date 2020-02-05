variable "global_rg" {
  description = "The resource group name for this cosmos db"
  type        = string
}

variable "cosmos_db_name" {
  description = "CosmosDB name"
  type        = string
}

variable "cosmos_db_offer_type" {
  type    = string
  default = "Standard"
}

variable "mongo_db_name" {
  description = "MongoDB name"
  type        = string
}
