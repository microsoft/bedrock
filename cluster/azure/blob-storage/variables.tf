variable "subscription_id" {
  type    = "string"
  default = ""       # reuse existing subscription if empty
}

variable "vault_subscription_id" {
  type    = "string"
  default = ""       # reuse existing subscription if empty
}

variable "resource_group_name" {
  type        = "string"
  description = "The resource group name for this cosmos db"
}

variable "location" {
  description = "The location/region of resource group"
  type        = "string"
}

variable "storage_account" {
  type        = "string"
  description = "storage account name"
}

variable "account_tier" {
  type        = "string"
  description = "optional, access tier of blob storage, possible values are Archive, Cool and Hot"
  default     = "Standard"
}

variable "replication_type" {
  type        = "string"
  description = "replication type"
  default     = "LRS"
}

variable "container_name" {
  type        = "string"
  description = "name of blob container"
}

variable "container_access_type" {
  type        = "string"
  description = "access type"
  default     = "private"
}

variable "blob_name" {
  type        = "string"
  description = "name of blob"
}

variable "blob_type" {
  type        = "string"
  description = "blob type"
  default     = "Block"
}

variable "vault_subscription_id" {
  type        = "string"
  description = "subscription id of key vault"
}

variable "vault_name" {
  type        = "string"
  description = "name of key vault to store storage auth key"
}

variable "storage_account_key_secret_name" {
  type = "string"
  description = "secret name for storage account key"
}
