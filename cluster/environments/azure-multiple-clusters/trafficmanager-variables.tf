variable "traffic_manager_resource_group_name" {
  type = "string"
}

variable "traffic_manager_resource_group_location" {
  type = "string"
}

variable "traffic_manager_resource_group_preallocated" {
  description = "boolean value that when set to true, the specified resource group is assumed to exist.  it will not be feleted.  when set to false, the resource group will be 'managed' by Terraform and deleted on a 'terraform destroy'"
  default     = false
}

variable "traffic_manager_profile_name" {
  type = "string"
}

variable "traffic_manager_dns_name" {
  type = "string"
}

variable "traffic_manager_monitor_protocol" {
  type    = "string"
  default = "http"
}

variable "traffic_manager_monitor_port" {
  type    = "string"
  default = "80"
}
