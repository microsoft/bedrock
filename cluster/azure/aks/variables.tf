variable "resource_group_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "service_principal_id" {
  type    = string
  default = ""
}

variable "service_principal_secret" {
  type    = string
  default = ""
}

variable "msi_enabled" {
  type    = bool
  default = false
}

variable "cluster_name" {
  type    = string
  default = "bedrockaks"
}

variable "agent_vm_count" {
  type    = string
  default = "2"
}

variable "agent_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "admin_user" {
  type    = string
  default = "k8sadmin"
}

variable "output_directory" {
  type    = string
  default = "./output"
}

variable "enable_virtual_node_addon" {
  type    = string
  default = "false"
}

variable "enable_kube_dashboard" {
  type    = bool
  default = true
}

variable "kubeconfig_to_disk" {
  description = "This disables or enables the kube config file from being written to disk."
  type        = string
  default     = "true"
}

variable "kubeconfig_filename" {
  description = "Name of the kube config file saved to disk."
  type        = string
  default     = "bedrock_kube_config"
}

variable "service_cidr" {
  default     = "10.0.0.0/16"
  description = "Used to assign internal services in the AKS cluster an IP address. This IP address range should be an address space that isn't in use elsewhere in your network environment. This includes any on-premises network ranges if you connect, or plan to connect, your Azure virtual networks using Express Route or a Site-to-Site VPN connections."
  type        = string
}

variable "dns_ip" {
  default     = "10.0.0.10"
  description = "should be the .10 address of your service IP address range"
  type        = string
}

variable "docker_cidr" {
  type        = string
  default     = "172.17.0.1/16"
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Default of 172.17.0.1/16."
}

variable "network_plugin" {
  default     = "azure"
  type        = string
  description = "Network plugin used by AKS. Either azure or kubenet."
}
variable "network_policy" {
  default     = "azure"
  type        = string
  description = "Network policy to be used with Azure CNI. Either azure or calico."
}

variable "oms_agent_enabled" {
  default     = "false"
  description = "Enable Azure Monitoring for AKS"
  type        = string
}

variable "tags" {
  description = "The tags to associate with AKS"
  type        = map

  default = {}
}

variable "kube_api_server_authorized_ip_ranges" {
  description = "IPs allowed to contact the API server."
  type        = list(string)
  default     = []
}
