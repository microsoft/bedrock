# service variables
variable "prefix" {
  default = "azure-multiple-clusters-waf-tm-apimgmt"
}

variable "resource_group_name" {
  type = "string"
}

variable resource_group_location {
  type = "string"
}

variable wafname {
  type = "string"
}

variable subnet_id {
  type = "string"
}

variable public_ip_address_id {
  type = "string"
}

variable "tags" {
  description = "The tags to associate with the public ip address."
  type        = "map"

  default = {
    tag1 = ""
    tag2 = ""
  }
}
