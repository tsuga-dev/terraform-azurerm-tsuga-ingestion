resource "azurerm_eventhub_namespace" "logs" {
  count               = local.enable_logs ? 1 : 0
  name                = "${var.prefix}-logs-ehns"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  capacity            = var.eventhub_capacity
  tags                = var.tags
}

resource "azurerm_eventhub" "logs" {
  count             = local.enable_logs ? 1 : 0
  name              = "${var.prefix}-logs"
  namespace_id      = azurerm_eventhub_namespace.logs[0].id
  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention
}

resource "azurerm_eventhub_consumer_group" "otel_collector" {
  count               = local.enable_logs ? 1 : 0
  name                = "otel-collector"
  namespace_name      = azurerm_eventhub_namespace.logs[0].name
  eventhub_name       = azurerm_eventhub.logs[0].name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_namespace_authorization_rule" "diag_send" {
  count               = local.enable_logs ? 1 : 0
  name                = "${var.prefix}-diag-send"
  namespace_name      = azurerm_eventhub_namespace.logs[0].name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "otel_listen" {
  count               = local.enable_logs ? 1 : 0
  name                = "${var.prefix}-otel-listen"
  namespace_name      = azurerm_eventhub_namespace.logs[0].name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}
