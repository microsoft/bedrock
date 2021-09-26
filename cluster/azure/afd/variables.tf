variable "resource_group_name" {
  type = string
}

variable "front_door_name" {
  type = string
}

variable "frontend_endpoint" {
  type = string
}

variable "load_balancing_name" {
  type = string
}

variable "sample_size" {
  type = number
}

variable "successful_samples_required" {
  type = number
}

variable "additional_latency_milliseconds" {
  type = number
}

variable "health_probe_name" {
  type = string
}

variable "backendpools" {
}

variable "routing_rules" {
}

variable "path" {
  type = string
}

variable "interval_in_seconds" {
  type = number
}

variable "patterns_to_match" {
  type    = list(string)
  default = ["/*"]
}
