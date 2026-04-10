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

output "eventhub_namespace_id" {
  description = "Resource ID of the Event Hub Namespace (null if logs disabled)"
  value       = try(azurerm_eventhub_namespace.logs[0].id, null)
}

output "eventhub_name" {
  description = "Name of the logs Event Hub (null if logs disabled)"
  value       = try(azurerm_eventhub.logs[0].name, null)
}

output "policy_assignment_id" {
  description = "ID of the diagnostic logs policy assignment (null if resource logs disabled)"
  value       = try(azurerm_subscription_policy_assignment.logs_to_eventhub[0].id, null)
}
