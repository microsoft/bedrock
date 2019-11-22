variable "subscription_id" {
  type = "string"
  description = "azure subscription id where app insights is created"
}

variable "log_analytics_resource_group_name" {
  type = "string"
}

variable "log_analytics_resource_group_location" {
  type = "string"
}

variable "log_analytics_name" {
  type = "string"
}