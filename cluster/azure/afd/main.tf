data "azurerm_resource_group" "cluster" {
  name = var.resource_group_name
}

resource "azurerm_frontdoor" "afd" {
  name                                         = var.front_door_name
  resource_group_name                          = data.azurerm_resource_group.cluster.name
  enforce_backend_pools_certificate_name_check = false

  dynamic "routing_rule" {
    for_each = [for rr in var.routing_rules : {
      name                = rr.routing_rule_name
      patterns_to_match   = rr.patterns_to_match
      forwarding_protocol = rr.forwarding_protocol
      backend_pool_name   = rr.backend_pool_name
    }]

    content {
      name               = routing_rule.value.name
      accepted_protocols = ["Http", "Https"]
      patterns_to_match  = routing_rule.value.patterns_to_match
      frontend_endpoints = ["${var.frontend_endpoint}"]
      forwarding_configuration {
        forwarding_protocol = routing_rule.value.forwarding_protocol
        backend_pool_name   = routing_rule.value.backend_pool_name
      }
    }
  }

  backend_pool_load_balancing {
    name                            = var.load_balancing_name
    sample_size                     = var.sample_size
    successful_samples_required     = var.successful_samples_required
    additional_latency_milliseconds = var.additional_latency_milliseconds
  }

  backend_pool_health_probe {
    name                = var.health_probe_name
    path                = var.path
    interval_in_seconds = var.interval_in_seconds
  }

  dynamic "backend_pool" {
    for_each = [for bp in var.backendpools : {
      backend_pool_name = bp.backend_pool_name
      backends          = bp.backends
    }]

    content {
      name                = backend_pool.value.backend_pool_name
      load_balancing_name = var.load_balancing_name
      health_probe_name   = var.health_probe_name

      dynamic "backend" {
        for_each = [for b in backend_pool.value.backends : {
          address  = b.address
          priority = b.priority
          weight   = b.weight
        }]
        content {
          host_header = backend.value.address
          address     = backend.value.address
          http_port   = 80
          https_port  = 443
          priority    = backend.value.priority
          weight      = backend.value.weight
          enabled     = true
        }
      }
    }
  }

  frontend_endpoint {
    name                              = var.frontend_endpoint
    host_name                         = "${var.front_door_name}.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}

