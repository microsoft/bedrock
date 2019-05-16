variable "primary_region_waf_url" {
  default = ""
}

variable "secondary_region_waf_url" {
  default = ""
}

variable "tertiary_region_waf_url" {
  default = ""
}

variable "traffic_manager_url" {
  default = ""
}

variable "api_management_resource_group_name" {
  default = "apimgmtresgrp5"
}

variable "region" {
  default = "eastus"
}

variable "service_option1apim_name" {
  default = "apimgmt-tm"
}

# variable "location" {
#   description = "The location/region where the api management service will be deployed. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
#   type = "string"
# }

