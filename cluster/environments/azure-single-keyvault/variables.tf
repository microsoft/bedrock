variable "acr_enabled" {
  type    = string
  default = "true"
}

variable "agent_vm_count" {
  type = string
}

variable "agent_vm_size" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "flux_recreate" {
  description = "Make any change to this value to trigger the recreation of the flux execution script."
  type        = string
  default     = ""
}

variable "gc_enabled" {
  type    = string
  default = "true"
}

variable "gitops_poll_interval" {
  type    = string
  default = "5m"
}

variable "gitops_label" {
  type    = string
  default = "flux-sync"
}

variable "gitops_ssh_url" {
  type = string
}

variable "gitops_url_branch" {
  type    = string
  default = "master"
}

variable "gitops_ssh_key" {
  type = string
}

variable "gitops_path" {
  type    = string
  default = ""
}

variable "keyvault_name" {
  type = string
}

variable "keyvault_resource_group" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.15.7"
}

variable "resource_group_name" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "service_principal_id" {
  type = string
}

variable "service_principal_secret" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_address_prefix" {
  type = string
}

variable "network_plugin" {
  default     = "azure"
  description = "Network plugin used by AKS. Either azure or kubenet."
}
variable "network_policy" {
  default     = "azure"
  description = "Network policy to be used with Azure CNI. Either azure or calico."
}

variable "oms_agent_enabled" {
  type    = string
  default = "false"
}

variable "enable_acr" {
  type    = string
  default = "false"
}

variable "acr_name" {
  type    = string
  default = ""
}
