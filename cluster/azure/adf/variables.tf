variable "subscription_id" {
  type        = "string"
  description = "subscription where ADF will be deployed"
}

variable "resource_group_name" {
  type        = "string"
  description = "resource group name where ADF is deployed"
}

variable "key_vault_resource_group_name" {
  type        = "string"
  description = "resource group name where ley vault is deployed"
}

variable "vault_name" {
  type        = "string"
  description = "name of key vault, where secret will be stored for connections"
}

variable "datafactoryName" {
  type        = "string"
  description = "name of ADF"
}

variable "cosmos_db_account" {
  type        = "string"
  description = "name of cosmosdb account"
}

variable "cosmos_db_auth_key" {
  type        = "string"
  description = "Name of the secret for cosmos db"
}

variable "adx_endpoint" {
  type        = "string"
  description = "Endpoint for the Kusto cluster"
}

variable "adx_database" {
  type        = "string"
  description = "Name of the database in the Kusto cluster"
}

variable "adx_table" {
  type        = "string"
  description = "Name of the table in the Kusto cluster"
}

variable "adx_clientId" {
  type        = "string"
  description = "AAD app which has access to Kusto cluster"
}

variable "adx_clientSecretName" {
  type        = "string"
  description = "Name of the secret for the AAD app which has access in the Kusto cluster"
}
