locals {
  enable_logs = var.enable_activity_logs || var.enable_resource_logs

  # Logs and metrics configs are split because they run in separate container apps:
  # the logs app scales horizontally to absorb Event Hub backlog, while the metrics app
  # must stay at exactly one instance to prevent every replica from independently polling
  # Azure Monitor and sending duplicate metric data to Tsuga.
  otel_config_logs = local.enable_logs ? templatefile("${path.module}/templates/otel-config.yaml.tmpl", {
    subscription_id            = var.subscription_id
    collection_interval        = var.collection_interval
    tsuga_intake_url           = var.tsuga_intake_url
    resource_targets           = var.resource_targets
    enable_metrics             = false
    enable_logs                = true
    eventhub_connection_string = azurerm_eventhub_namespace_authorization_rule.otel_listen[0].primary_connection_string
    eventhub_name              = azurerm_eventhub.logs[0].name
    eventhub_consumer_group    = azurerm_eventhub_consumer_group.otel_collector[0].name
  }) : null

  otel_config_metrics = var.enable_metrics ? templatefile("${path.module}/templates/otel-config.yaml.tmpl", {
    subscription_id            = var.subscription_id
    collection_interval        = var.collection_interval
    tsuga_intake_url           = var.tsuga_intake_url
    resource_targets           = var.resource_targets
    enable_metrics             = true
    enable_logs                = false
    eventhub_connection_string = ""
    eventhub_name              = ""
    eventhub_consumer_group    = ""
  }) : null
}

check "collection_types_validation" {
  assert {
    condition     = var.enable_metrics || local.enable_logs
    error_message = "At least one of enable_metrics, enable_activity_logs, or enable_resource_logs must be true"
  }
}

check "eventhub_partition_count_validation" {
  assert {
    condition     = !local.enable_logs || var.eventhub_partition_count >= var.logs_max_replicas
    error_message = "eventhub_partition_count (${var.eventhub_partition_count}) is less than logs_max_replicas (${var.logs_max_replicas}). Only one replica per partition can actively consume, so excess replicas will be idle for log ingestion."
  }
}
