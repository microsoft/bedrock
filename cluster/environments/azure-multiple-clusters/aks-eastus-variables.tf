variable "east_resource_group_name" {
  type = "string"
}

variable "gitops_east_path" {
  type = "string"
}

variable "gitops_east_url_branch" {
  type    = "string"
  default = "master"
}

variable "east_address_space" {
  description = "The address space that is used by the virtual network."
  default     = "172.22.0.0/16"
}

variable "east_subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["172.22.0.0/20"]
}

variable "east_service_cidr" {
  default     = "172.23.0.0/16"
  description = "Used to assign internal services in the AKS cluster an IP address. This IP address range should be an address space that isn't in use elsewhere in your network environment. This includes any on-premises network ranges if you connect, or plan to connect, your Azure virtual networks using Express Route or a Site-to-Site VPN connections."
  type        = "string"
}

variable "east_dns_ip" {
  default     = "172.23.0.10"
  description = "should be the .10 address of your service IP address range"
  type        = "string"
}

variable "east_docker_cidr" {
  default     = "172.18.0.1/16"
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Default of 172.17.0.1/16."
}
