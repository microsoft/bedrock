
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

variable "aks_resource_group_name" {
  type = "string"
}

variable "kv_reader_identity_name" {
  type = "string"
}

variable "azure_identity_name" {
  type = "string"
}

variable "azure_identity_binding_name" {
  type = "string"
}

variable "k8s_namespace" {
  type = "string"
}

variable "pod_identity_created" {
  type = "string"
}