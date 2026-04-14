output "metrics_container_app_fqdn" {
  description = "Metrics Container App FQDN"
  value       = module.tsuga_otel.metrics_container_app_fqdn
}

output "managed_identity_client_id" {
  description = "Managed Identity Client ID"
  value       = module.tsuga_otel.managed_identity_client_id
}
