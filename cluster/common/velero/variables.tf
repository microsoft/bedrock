variable "output_directory" {
  type    = "string"
  default = "./output"
}

variable "kubeconfig_filename" {
  description = "Name of the kube config file saved to disk."
  type        = "string"
  default     = "bedrock_kube_config"
}

variable "kubeconfig_complete" {
  description = "Allows flux to wait for the kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
  type        = "string"
}

variable "velero_provider" {
  description = "Set the provider (Azure, AWS, etc.)"
  type        = "string"
  default     = "azure"
}

variable "velero_bucket" {
  description = "Set the backup storage location bucket"
  type        = "string"
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
