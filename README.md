# Telemetry Collection Integration - Azure to Tsuga

This module creates an OTel collector running on Container App to collect your:

- Activity Logs
- and/or Resource Logs
- and/or Metrics

It also creates an Event Hub if you set it to collect logs.

## Prerequisites

- Download `az` CLI.
- Download `terraform` CLI.
- Perform `az login` before performing terraform commands.
- Tsuga API Key.
- Tsuga Intake URL.

## Usage

Use the module from your own Terraform code and pin it to a published module version:

```hcl
resource "azurerm_resource_group" "tsuga" {
  name     = "${var.prefix}-tsuga-ingestion"
  location = var.location
}

module "tsuga_ingestion" {
  source  = "tsuga-dev/tsuga-ingestion/azurerm"
  version = "<version>"

  subscription_id     = var.subscription_id
  resource_group_name = azurerm_resource_group.tsuga.name
  location            = var.location
  tsuga_api_key       = var.tsuga_api_key
  tsuga_intake_url    = var.tsuga_intake_url

  enable_metrics       = true
  enable_activity_logs = true
  enable_resource_logs = true
}
```

If you already have a resource group, pass its name directly to `resource_group_name` instead of creating `azurerm_resource_group.tsuga`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_collection_interval"></a> [collection\_interval](#input\_collection\_interval) | Metrics collection interval (only used when enable\_metrics is true) | `string` | `"60s"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU allocation for container (in cores) | `number` | `0.5` | no |
| <a name="input_enable_activity_logs"></a> [enable\_activity\_logs](#input\_enable\_activity\_logs) | Enable Activity Log collection via Event Hub (subscription-wide, not region-restricted) | `bool` | `false` | no |
| <a name="input_enable_metrics"></a> [enable\_metrics](#input\_enable\_metrics) | Enable metrics collection via Azure Monitor | `bool` | `true` | no |
| <a name="input_enable_resource_logs"></a> [enable\_resource\_logs](#input\_enable\_resource\_logs) | Enable resource diagnostic log collection via Event Hub and Azure Policy (only targets resources in var.location) | `bool` | `false` | no |
| <a name="input_eventhub_capacity"></a> [eventhub\_capacity](#input\_eventhub\_capacity) | Throughput units for the Event Hub Namespace (Standard SKU: 1-20) | `number` | `1` | no |
| <a name="input_eventhub_message_retention"></a> [eventhub\_message\_retention](#input\_eventhub\_message\_retention) | Number of days to retain messages in the Event Hub | `number` | `1` | no |
| <a name="input_eventhub_partition_count"></a> [eventhub\_partition\_count](#input\_eventhub\_partition\_count) | Number of partitions for the logs Event Hub. Set this to at least `logs_max_replicas`, since each collector replica consumes from one partition. The partition count cannot be changed after creation (Standard SKU) — the Event Hub must be destroyed and recreated. The default of 4 accommodates the default `logs_max_replicas` of 3. | `number` | `4` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for deployed resources | `string` | n/a | yes |
| <a name="input_logs_max_replicas"></a> [logs\_max\_replicas](#input\_logs\_max\_replicas) | Maximum number of replicas for the logs container app | `number` | `3` | no |
| <a name="input_logs_min_replicas"></a> [logs\_min\_replicas](#input\_logs\_min\_replicas) | Minimum number of replicas for the logs container app | `number` | `1` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocation for container (e.g., '1Gi') | `string` | `"1Gi"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names | `string` | `"tsuga"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to deploy into | `string` | n/a | yes |
| <a name="input_resource_targets"></a> [resource\_targets](#input\_resource\_targets) | List of Azure resource groups (names) to collect metrics from. If empty, collects subscription-level metrics. Only used when enable\_metrics is true. | `list(string)` | `[]` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID to collect telemetry from | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tsuga_api_key"></a> [tsuga\_api\_key](#input\_tsuga\_api\_key) | Tsuga API key for authentication | `string` | n/a | yes |
| <a name="input_tsuga_intake_url"></a> [tsuga\_intake\_url](#input\_tsuga\_intake\_url) | Tsuga OTLP/HTTP endpoint URL | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | Name of the logs Event Hub (null if logs disabled) |
| <a name="output_eventhub_namespace_id"></a> [eventhub\_namespace\_id](#output\_eventhub\_namespace\_id) | Resource ID of the Event Hub Namespace (null if logs disabled) |
| <a name="output_logs_container_app_fqdn"></a> [logs\_container\_app\_fqdn](#output\_logs\_container\_app\_fqdn) | Fully qualified domain name of the logs Container App (null if logs disabled) |
| <a name="output_logs_container_app_id"></a> [logs\_container\_app\_id](#output\_logs\_container\_app\_id) | Resource ID of the logs Container App (null if logs disabled) |
| <a name="output_managed_identity_client_id"></a> [managed\_identity\_client\_id](#output\_managed\_identity\_client\_id) | Client ID of the managed identity |
| <a name="output_managed_identity_id"></a> [managed\_identity\_id](#output\_managed\_identity\_id) | Resource ID of the managed identity |
| <a name="output_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#output\_managed\_identity\_principal\_id) | Principal ID of the managed identity |
| <a name="output_metrics_container_app_fqdn"></a> [metrics\_container\_app\_fqdn](#output\_metrics\_container\_app\_fqdn) | Fully qualified domain name of the metrics Container App (null if metrics disabled) |
| <a name="output_metrics_container_app_id"></a> [metrics\_container\_app\_id](#output\_metrics\_container\_app\_id) | Resource ID of the metrics Container App (null if metrics disabled) |
| <a name="output_policy_assignment_id"></a> [policy\_assignment\_id](#output\_policy\_assignment\_id) | ID of the diagnostic logs policy assignment (null if resource logs disabled) |
<!-- END_TF_DOCS -->

## Examples

See the `examples/` folder.

## Architecture

### Metrics

When `enable_metrics = true`, The module deploys:

- **Azure Container App** - Runs the OpenTelemetry Collector
- **Container App Environment** - Hosting environment for the container
- **User-Assigned Managed Identity** - For authenticating to Azure Monitor
- **Role Assignment** - Grants "Monitoring Reader" role to the managed identity

The collector uses the `azuremonitor` receiver with the batch API for efficient metrics collection (360,000 API calls/hour vs 12,000 with standard API).

### Logs

When either `enable_activity_logs` or `enable_resource_logs` is true, the module deploys shared Event Hub infrastructure:

- **Event Hub Namespace & Event Hub** - Receives diagnostic logs from Azure resources
- **Consumer Group** - Dedicated `otel-collector` consumer group for the OTel Collector
- **Authorization Rules** - Separate send-only (for diagnostic settings) and listen-only (for OTel Collector) rules

#### Activity Logs (`enable_activity_logs`)

Routes subscription Activity Log categories (Administrative, Security, ServiceHealth, Alert, Recommendation, Policy, Autoscale, ResourceHealth) to the Event Hub. This is **subscription-wide** and not region-restricted.

#### Resource Diagnostic Logs (`enable_resource_logs`)

Assigns the built-in "Enable allLogs category group resource logging to Event Hub" Azure Policy initiative (`DeployIfNotExists`), which automatically configures diagnostic settings on newly created resources. This **only targets resources in `var.location`** — resources in other regions are not affected due to an Azure limitation requiring the Event Hub to be in the same region as the resource.

**Data flow:**

```
Azure Resources --> Diagnostic Settings (enforced by Policy) --> Event Hub  [same region only]
Subscription Activity Log --> Diagnostic Setting --> Event Hub              [all regions]
Event Hub --> OTel Collector (azureeventhubreceiver) --> Tsuga OTLP endpoint
```

### Multi-Region Deployments

If you have resources across multiple Azure regions, you should deploy the module as follows:

- **Once per subscription** for metrics (`enable_metrics`) and activity logs (`enable_activity_logs`), since both are subscription-wide and not region-restricted.
- **Once per region** for resource diagnostic logs (`enable_resource_logs`), since diagnostic settings require the Event Hub to be in the same region as the resource. Each regional instance needs its own `location`, `prefix` (to avoid name collisions), and resource group.

For example, a subscription with resources in `westeurope` and `eastus` would need three module instances: one with metrics + activity logs, and one resource-logs-only instance per region.

### Remediation for Existing Resources

The Azure Policy only auto-applies diagnostic settings to **newly created** resources. To remediate pre-existing resources, run:

```bash
az policy remediation create \
  --name "remediate-logs-to-eventhub" \
  --policy-assignment "<policy-assignment-id>" \
  --subscription "<subscription-id>"
```

The `policy_assignment_id` is available as a Terraform output.

## Configuration Changes

When the OTel configuration changes, a new container app revision is automatically created (via `revision_suffix` based on config hash). This ensures the collector picks up the new configuration.

## Security

Note that for convenience, the Tsuga API key is passed in Terraform state. You can mitigate this by encrypting the Terraform state.
