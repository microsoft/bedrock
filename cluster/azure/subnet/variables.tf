variable "resource_group_name" {
  type = string
}

variable vnet_name {
  type = string
}

variable subnet_name {
  type = list(string)
}

variable address_prefix {
  type = list(string)
}

variable service_endpoints {
  description = "A list of the service endpoints for the subnet (e.g. Microsoft.Web)"
  type        = list(any)
  default     = [[], []]
}
