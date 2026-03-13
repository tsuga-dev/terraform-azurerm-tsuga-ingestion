output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = module.tsuga_otel.container_app_fqdn
}

output "managed_identity_client_id" {
  description = "Managed Identity Client ID"
  value       = module.tsuga_otel.managed_identity_client_id
}
