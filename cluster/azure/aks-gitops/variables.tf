variable "agent_vm_count" {
  type    = "string"
  default = "3"
}

variable "agent_vm_size" {
  type = "string"
}

variable "acr_enabled" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "dns_prefix" {
  type = "string"
}

variable "enable_flux" {
  type    = "string"
  default = "true"
}

variable "flux_recreate" {
  type = "string"
}

variable "gitops_ssh_url" {
  type = "string"
}

variable "gitops_ssh_key" {
  type = "string"
}

variable "gitops_path" {
  type    = "string"
  default = ""
}

variable "gitops_poll_interval" {
  type    = "string"
  default = "5m"
}

variable "gitops_url_branch" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "resource_group_location" {
  type = "string"
}

variable "service_principal_id" {
  type = "string"
}

variable "service_principal_secret" {
  type = "string"
}

variable "ssh_public_key" {
  type = "string"
}

variable "vnet_subnet_id" {
  type = "string"
}

variable "service_cidr" {
  default     = "10.0.0.0/16"
  description = "Used to assign internal services in the AKS cluster an IP address. This IP address range should be an address space that isn't in use elsewhere in your network environment. This includes any on-premises network ranges if you connect, or plan to connect, your Azure virtual networks using Express Route or a Site-to-Site VPN connections."
  type        = "string"
}

variable "dns_ip" {
  default     = "10.0.0.10"
  description = "should be the .10 address of your service IP address range"
  type        = "string"
}

variable "docker_cidr" {
  default     = "172.17.0.1/16"
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Default of 172.17.0.1/16."
}

variable "kubeconfig_filename" {
  description = "Name of the kube config file saved to disk."
  type        = "string"
  default     = "bedrock_kube_config"
}

variable "kubeconfig_recreate" {
  description = "Any change to this variable will recreate the kube config file to local disk."
  type        = "string"
  default     = ""
}
variable "network_policy" {
  default     = "azure"
  description = "Network policy to be used with Azure CNI. Either azure or calico."
}
