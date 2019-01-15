/*
variable "aad_server_app_id" {
  type = "string"
}

variable "aad_server_app_secret" {
  type = "string"
}

variable "aad_client_app_id" {
  type = "string"
}

variable "aad_tenant_id" {
  type = "string"
}
*/
variable "client_id" {
  type = "string"
  default = "{ENTER-CLIENT-ID}"
}

variable "client_secret" {
  type = "string"
  default = "{ENTER-CLIENT-SECRET}"
}

variable "ssh_public_key" {
  type = "string"
  default = "{ENTER-SSH-PUBLIC-KEY-HERE}"
}
