resource "azurerm_container_app_environment" "otel" {
  name                = "${var.prefix}-otel-env"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Logs and metrics are split into separate container apps because they have opposite scaling needs:
# the logs container scales horizontally to absorb Event Hub backlog, while the metrics container
# must stay at exactly one instance to prevent every replica from independently polling
# Azure Monitor and sending duplicate metric data to Tsuga.

resource "azurerm_container_app" "otel_logs" {
  count                        = local.enable_logs ? 1 : 0
  name                         = "${var.prefix}-otel-logs"
  container_app_environment_id = azurerm_container_app_environment.otel.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.otel_collector.id]
  }

  template {
    min_replicas    = var.logs_min_replicas
    max_replicas    = var.logs_max_replicas
    revision_suffix = substr(sha256(coalesce(local.otel_config_logs, "")), 0, 8)

    container {
      name   = "otel-collector"
      image  = var.otel_collector_image
      cpu    = var.cpu
      memory = var.memory
      # Note: the secret's name becomes the filename in the volume.
      args = ["--config=/etc/otel/otel-config"]

      env {
        name        = "TSUGA_API_KEY"
        secret_name = "tsuga-api-key"
      }

      # Azure authentication via managed identity
      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.otel_collector.client_id
      }

      volume_mounts {
        name = "otel-config-volume"
        path = "/etc/otel"
      }

      liveness_probe {
        transport = "HTTP"
        path      = "/"
        port      = 13133

        initial_delay           = 30
        interval_seconds        = 30
        timeout                 = 5
        failure_count_threshold = 3
      }

      startup_probe {
        transport = "HTTP"
        path      = "/"
        port      = 13133

        initial_delay           = 10
        interval_seconds        = 5
        timeout                 = 3
        failure_count_threshold = 30
      }
    }

    # Custom scale rules are required if the app can have more than 1 replica.
    custom_scale_rule {
      name             = "cpu"
      custom_rule_type = "cpu"
      metadata = {
        type  = "Utilization"
        value = "80"
      }
    }

    custom_scale_rule {
      name             = "memory"
      custom_rule_type = "memory"
      metadata = {
        type  = "Utilization"
        value = "80"
      }
    }

    volume {
      name         = "otel-config-volume"
      storage_type = "Secret"
    }
  }

  secret {
    name  = "tsuga-api-key"
    value = var.tsuga_api_key
  }

  secret {
    name  = "otel-config"
    value = coalesce(local.otel_config_logs, "")
  }
}

resource "azurerm_container_app" "otel_metrics" {
  count                        = var.enable_metrics ? 1 : 0
  name                         = "${var.prefix}-otel-metrics"
  container_app_environment_id = azurerm_container_app_environment.otel.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.otel_collector.id]
  }

  template {
    # Exactly one instance to prevent duplicate metric collection.
    min_replicas    = 1
    max_replicas    = 1
    revision_suffix = substr(sha256(coalesce(local.otel_config_metrics, "")), 0, 8)

    container {
      name   = "otel-collector"
      image  = var.otel_collector_image
      cpu    = var.cpu
      memory = var.memory
      # Note: the secret's name becomes the filename in the volume.
      args = ["--config=/etc/otel/otel-config"]

      env {
        name        = "TSUGA_API_KEY"
        secret_name = "tsuga-api-key"
      }

      # Azure authentication via managed identity
      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.otel_collector.client_id
      }

      volume_mounts {
        name = "otel-config-volume"
        path = "/etc/otel"
      }

      liveness_probe {
        transport = "HTTP"
        path      = "/"
        port      = 13133

        initial_delay           = 30
        interval_seconds        = 30
        timeout                 = 5
        failure_count_threshold = 3
      }

      startup_probe {
        transport = "HTTP"
        path      = "/"
        port      = 13133

        initial_delay           = 10
        interval_seconds        = 5
        timeout                 = 3
        failure_count_threshold = 30
      }
    }

    volume {
      name         = "otel-config-volume"
      storage_type = "Secret"
    }
  }

  secret {
    name  = "tsuga-api-key"
    value = var.tsuga_api_key
  }

  secret {
    name  = "otel-config"
    value = coalesce(local.otel_config_metrics, "")
  }
}
