variable "k8s_namespace" {
  type = "string"
  default = "default"
  description = "k8s namespace"
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

variable "output_directory" {
  type    = "string"
  default = "./output"
}