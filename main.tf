locals {
  enable_logs = var.enable_activity_logs || var.enable_resource_logs

  otel_config = templatefile("${path.module}/templates/otel-config.yaml.tmpl", {
    subscription_id            = var.subscription_id
    collection_interval        = var.collection_interval
    tsuga_intake_url           = var.tsuga_intake_url
    resource_targets           = var.resource_targets
    enable_metrics             = var.enable_metrics
    enable_logs                = local.enable_logs
    eventhub_connection_string = local.enable_logs ? azurerm_eventhub_namespace_authorization_rule.otel_listen[0].primary_connection_string : ""
    eventhub_name              = local.enable_logs ? azurerm_eventhub.logs[0].name : ""
    eventhub_consumer_group    = local.enable_logs ? azurerm_eventhub_consumer_group.otel_collector[0].name : ""
  })
}

check "collection_types_validation" {
  assert {
    condition     = var.enable_metrics || local.enable_logs
    error_message = "At least one of enable_metrics, enable_activity_logs, or enable_resource_logs must be true"
  }
}

check "eventhub_partition_count_validation" {
  assert {
    condition     = !local.enable_logs || var.eventhub_partition_count >= var.max_replicas
    error_message = "eventhub_partition_count (${var.eventhub_partition_count}) is less than max_replicas (${var.max_replicas}). Only one replica per partition can actively consume, so excess replicas will be idle for log ingestion."
  }
}
