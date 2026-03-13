resource "azurerm_user_assigned_identity" "otel_collector" {
  name                = "${var.prefix}-otel-collector"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# When no resource_targets are specified, fall back to subscription-wide scope
resource "azurerm_role_assignment" "monitoring_reader_subscription" {
  count                = length(var.resource_targets) == 0 ? 1 : 0
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_user_assigned_identity.otel_collector.principal_id
}

# When resource_targets are specified, scope to those resource groups only
resource "azurerm_role_assignment" "monitoring_reader_resource_group" {
  for_each             = toset(var.resource_targets)
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value}"
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_user_assigned_identity.otel_collector.principal_id
}
resource "azurerm_role_assignment" "eventhub_data_receiver" {
  count                = local.enable_logs ? 1 : 0
  scope                = azurerm_eventhub_namespace.logs[0].id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_user_assigned_identity.otel_collector.principal_id
}
