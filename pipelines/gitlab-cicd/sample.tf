# This file in intended to show how to leverage the following, which are provisioned
# through the Azure/Gitlab bootstrapping process. 
#   (1) Backend State
#   (2) TF Vars
#
# See README.me for more

provider "azurerm" {
  version = "=2.22"
  features {}
}

terraform {
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

variable "env" {
  type        = string
  description = "The name of the environment to provision. Examples: dev, qa, prod"
}

variable "resource_group" {
  type        = string
  description = "The resource group to deploy into"
}

variable "acr_id" {
  type        = string
  description = "The resource identifier for AKS to attach to"
}

output "echo_env" {
  value = var.env
}

output "echo_resource_group" {
  value = var.resource_group
}

output "echo_acr_id" {
  value = var.acr_id
}
