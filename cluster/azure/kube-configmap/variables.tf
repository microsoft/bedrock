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

variable "k8s_namespaces" {
  type        = "string"
  description = "comma-separated k8s namespaces where secret will be created"
}

variable "k8s_secret_name" {
  type        = "string"
  description = "secret name"
}

variable "key_vault_name" {
  type        = "string"
  description = "name of key vault"
}

variable "key_vault_secret_name" {
  type        = "string"
  description = "name of kv secret, value must be base64 encoded yaml secret to be used by k8s"
}
