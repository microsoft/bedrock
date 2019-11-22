variable "subscription_id" {
  type = "string"
  description = "azure subscription id where aks/kv-reader is created"
}

variable "output_directory" {
  type    = "string"
  default = "./output"
}

variable "kubeconfigadmin_filename" {
  description = "Name of the admin kube config file saved to disk."
  type        = "string"
  default     = "admin_kube_config"
}

variable "kubeconfigadmin_done" {
  description = "Allows flux to wait for the admin kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
  type        = "string"
  default     = "true"
}

variable "env_name" {
  type        = "string"
  description = "target aks cluster env, allowed values: dev, int, test, ppe, prod"
}

variable "pod_identity_version" {
  type    = "string"
  default = "1.5.3"
}

variable "pod_identity_namespace" {
  type    = "string"
  default = "security"
}

variable "kvreader_created" {
  type = "string"
}
