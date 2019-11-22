############################################################
# log analytics                                            #
############################################################
variable "log_analytics_subscription_id" {
  type = "string"
}

variable "log_analytics_resource_group_name" {
  type = "string"
}

variable "log_analytics_name" {
  type = "string"
}

############################################################
# aks                                                      #
############################################################
variable "subscription_id" {
  type = "string"
  description = "azure subscription id where app insights is created"
}

variable "aks_resource_group_name" {
  type = "string"
}

variable "aks_resource_group_location" {
  type = "string"
}

variable "agent_vm_count" {
  type    = "string"
  default = "3"
}

variable "agent_vm_size" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "kubernetes_version" {
  type    = "string"
  default = "1.13.10"
}

variable "dns_prefix" {
  type = "string"
}

variable "service_principal_id" {
  type = "string"
}

variable "service_principal_secret" {
  type = "string"
}

variable "server_app_id" {
  type        = "string"
  description = "(Required) The Server ID of an Azure Active Directory Application. Changing this forces a new resource to be created."
}

variable "client_app_id" {
  type        = "string"
  description = "(Required) The Client ID of an Azure Active Directory Application. Changing this forces a new resource to be created."
}

variable "server_app_secret" {
  type        = "string"
  description = "(Required) The Server Secret of an Azure Active Directory Application. Changing this forces a new resource to be created."
}

variable "tenant_id" {
  type        = "string"
  description = "(Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used. Changing this forces a new resource to be created."
}

variable "ssh_public_key" {
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

variable "kubeconfigadmin_filename" {
  description = "Name of the admin kube config file saved to disk."
  type        = "string"
  default     = "admin_kube_config"
}

variable "kubeconfig_recreate" {
  description = "Any change to this variable will recreate the kube config file to local disk."
  type        = "string"
  default     = ""
}

variable "output_directory" {
  type    = "string"
  default = "./output"
}

############################################################
# flux                                                     #
############################################################

variable "gc_enabled" {
  type = "string"
}

variable "acr_enabled" {
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

variable "create_helm_operator" {
  type = "string"
  description = "create helm operator"
}

variable "create_helm_operator_crds" {
  type = "string"
  description = "create CRDs associated with helm operator"
}

variable "git_label" {
  type = "string"
  description = "comma-separated list of labels to be applied to git commit (in addition to flux-sync)"
  default = ""
}

############################################################
# addon                                                    #
############################################################
variable "oms_agent_enabled" {
  type    = "string"
  default = "false"
}

variable "enable_http_application_routing" {
  type    = "string"
  default = "true"
}

variable "enable_azure_monitoring" {
  type    = "string"
  default = "true"
}

variable "enable_dev_spaces" {
  type    = "string"
  default = "false"
}

variable "dev_space_name" {
  type = "string"
  default = "dev"
}

variable "dashboard_cluster_role" {
  type    = "string"
  default = "cluster_reader" # allowed values: cluster_admin, cluster_reader
}

############################################################
# rbac                                                     #
############################################################
variable "aks_owners" {
  type = "string"
  description = "comma separated aad user object id who are granted to cluster cluster admins"
  default = ""
}

variable "aks_contributors" {
  type = "string"
  description = "comma separated aad user object id who are contributors to aks"
  default = ""
}

variable "aks_readers" {
  type = "string"
  description = "comma separated aad user object id who are readers to aks"
  default = ""
}

variable "aks_owner_groups" {
  type = "string"
  description = "comma separated aad group object id who are granted to cluster cluster admins"
  default = ""
}

variable "aks_contributor_groups" {
  type = "string"
  description = "comma separated aad group object id who are contributors to aks"
  default = ""
}

variable "aks_reader_groups" {
  type = "string"
  description = "comma separated aad group object id who are readers to aks"
  default = ""
}