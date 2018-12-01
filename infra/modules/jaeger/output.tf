output "agent_endpoint" {
  value = "${var.name}-agent.${var.namespace}.svc.cluster.local"
}
