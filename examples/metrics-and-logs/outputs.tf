output "logs_container_app_fqdn" {
  description = "Logs Container App FQDN"
  value       = module.tsuga_otel.logs_container_app_fqdn
}

output "metrics_container_app_fqdn" {
  description = "Metrics Container App FQDN"
  value       = module.tsuga_otel.metrics_container_app_fqdn
}

output "managed_identity_client_id" {
  description = "Managed Identity Client ID"
  value       = module.tsuga_otel.managed_identity_client_id
}

output "eventhub_namespace_id" {
  description = "Event Hub Namespace Resource ID"
  value       = module.tsuga_otel.eventhub_namespace_id
}

output "policy_assignment_id" {
  description = "Diagnostic Logs Policy Assignment ID"
  value       = module.tsuga_otel.policy_assignment_id
}
