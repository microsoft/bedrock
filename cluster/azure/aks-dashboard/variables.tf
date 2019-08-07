
variable "dashboard_cluster_role" {
  type = "string"
  default = "cluster_reader" # allowed values: cluster_admin, cluster_reader
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