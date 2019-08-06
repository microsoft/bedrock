variable "output_directory" {
  type    = "string"
  default = "./output"
}

variable "kubeconfig_filename" {
  description = "Name of the kube config file saved to disk."
  type        = "string"
  default     = "bedrock_kube_config"
}

variable "acr_enabled" {
  type    = "string"
  default = "true"
}

variable "address_space" {
  type = "string"
}

variable "agent_vm_count" {
  type = "string"
}

variable "agent_vm_size" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "dns_prefix" {
  type = "string"
}

variable "flux_recreate" {
  description = "Make any change to this value to trigger the recreation of the flux execution script."
  type        = "string"
  default     = ""
}

variable "gitops_poll_interval" {
  type    = "string"
  default = "5m"
}

variable "gitops_ssh_url" {
  type = "string"
}

variable "gitops_url_branch" {
  type    = "string"
  default = "master"
}

variable "gitops_ssh_key" {
  type = "string"
}

variable "gitops_path" {
  type    = "string"
  default = ""
}

variable "keyvault_name" {
  type = "string"
}

variable "keyvault_resource_group" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "resource_group_location" {
  type = "string"
}

variable "ssh_public_key" {
  type = "string"
}

variable "service_principal_id" {
  type = "string"
}

variable "service_principal_secret" {
  type = "string"
}

variable "subnet_prefixes" {
  type = "string"
}

variable "vnet_subnet_id" {
  type = "string"
}

variable "subscription_id" {
  type = "string"
}

variable "tenant_id" {
  type = "string"
}

variable "velero_provider" {
  description = "Set the provider (Azure, AWS, etc.)"
  type        = "string"
  default     = "azure"
}

variable "velero_bucket" {
  description = "Set the backup storage location bucket"
  type        = "string"
  default     = ""
}

variable "velero_secrets" {
  description = "The location of the secrets file containing AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET & AZURE_RESOURCE_GROUP (azure only)"
  type        = "string"
  default     = "./credentials-velero"
}

variable "velero_backup_location_config" {
  description = "Set the backup storage location config. For Azure, it must have a resourceGroup and storageAccount."
  type        = "string"
  default     = ""
}

variable "velero_volume_snapshot_location_config" {
  description = "Set the volume snapshot location config. For Azure, it must have at least apiTimeout."
  type        = "string"
  default     = ""
}

variable "velero_backup_name" {
  description = "The name of the backup to restore from."
  type        = "string"
}

variable "velero_restore_name" {
  description = "The name of the restore you would like to set."
  type        = "string"
  default     = "disasterrecoveryrestore"
}

variable "velero_install" {
  description = "Install velero, should be set to true in a Cluster Migration Scenario but not Disaster Recovery."
  default     = "true"
}

variable "velero_uninstall" {
  description = "Uninstall velero after restore is complete. You may want to do this if you don't want velero to be part of your cluster."
  default     = "false"
}

variable "velero_delete_pod" {
  description = "Remove the created velero pod but do not uninstall velero. You may want to do this if your backup contains a Velero resource. Setting this to true makes sure you don't have an extra velero pod running."
  default     = "false"
}
