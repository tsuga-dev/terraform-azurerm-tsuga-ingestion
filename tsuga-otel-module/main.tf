locals {
  otel_config = templatefile("${path.module}/templates/otel-config.yaml.tmpl", {
    subscription_id     = var.subscription_id
    collection_interval = var.collection_interval
    tsuga_intake_url    = var.tsuga_intake_url
    resource_targets    = var.resource_targets
    enable_metrics      = var.enable_metrics
  })
}

check "collection_types_validation" {
  assert {
    condition     = var.enable_metrics
    error_message = "enable_metrics must be true (logs not yet supported)"
  }
}
