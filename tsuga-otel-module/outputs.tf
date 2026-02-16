output "container_app_fqdn" {
  description = "Fully qualified domain name of the Container App"
  value       = azurerm_container_app.otel_collector.latest_revision_fqdn
}

output "container_app_id" {
  description = "Resource ID of the Container App"
  value       = azurerm_container_app.otel_collector.id
}

output "managed_identity_id" {
  description = "Resource ID of the managed identity"
  value       = azurerm_user_assigned_identity.otel_collector.id
}

output "managed_identity_client_id" {
  description = "Client ID of the managed identity"
  value       = azurerm_user_assigned_identity.otel_collector.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.otel_collector.principal_id
}
