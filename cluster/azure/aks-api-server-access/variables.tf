variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kube_api_server_authorized_ip_ranges" {
  type = list(string)
  default = []
}

variable "kube_api_server_temp_authorized_ip" {
  type = string
  default = ""
}

variable "kubeconfig_complete" {
  description = "Allows permissions to wait until kube cluster complete."
  type        = string
}

variable "flux_done" {
  description = "Is flux done running"
  type        = string
}

variable "kubediff_done" {
  description = "Is kubediff done running"
  type        = string
}