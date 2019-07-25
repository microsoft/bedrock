variable "role_assignment_role" {
  description = "The role to give the AKS service principal to access the keyvault"
  type        = "string"
}

variable "role_assignee" {
  type = "string"
}

variable "role_scope" {
  type = "string"
}

variable "precursor_done" {
  type = "string"
  default = "1"
}