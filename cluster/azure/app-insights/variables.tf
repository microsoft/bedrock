variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "name" {
  type = "string"
  description = "name of app insights"
}