resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  count                          = var.enable_activity_logs ? 1 : 0
  name                           = "${var.prefix}-activity-log-to-eventhub"
  target_resource_id             = "/subscriptions/${var.subscription_id}"
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.diag_send[0].id
  eventhub_name                  = azurerm_eventhub.logs[0].name

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "ResourceHealth"
  }
}

resource "azurerm_subscription_policy_assignment" "logs_to_eventhub" {
  count                = var.enable_resource_logs ? 1 : 0
  name                 = "${var.prefix}-logs-to-eventhub"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/85175a36-2f12-419a-96b4-18d5b0096531"
  display_name         = "Enable allLogs category group resource logging to Event Hub"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    eventHubAuthorizationRuleId = {
      value = azurerm_eventhub_namespace_authorization_rule.diag_send[0].id
    }
    eventHubName = {
      value = azurerm_eventhub.logs[0].name
    }
    resourceLocation = {
      value = var.location
    }
    effect = {
      value = "DeployIfNotExists"
    }
  })
}

# Allows the policy to create diagnostic settings on resources
resource "azurerm_role_assignment" "policy_monitoring_contributor" {
  count                = var.enable_resource_logs ? 1 : 0
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_subscription_policy_assignment.logs_to_eventhub[0].identity[0].principal_id
}

# Allows the policy to read Event Hub auth rule keys when configuring diagnostic settings
resource "azurerm_role_assignment" "policy_eventhub_listkeys" {
  count                = var.enable_resource_logs ? 1 : 0
  scope                = azurerm_eventhub_namespace.logs[0].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_subscription_policy_assignment.logs_to_eventhub[0].identity[0].principal_id
}
