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

### Configuration Variables

| Variable                     | Description                                                  | Type         | Default                                        | Required |
| ---------------------------- | ------------------------------------------------------------ | ------------ | ---------------------------------------------- | -------- |
| `subscription_id`            | Azure Subscription ID to collect telemetry from              | string       | -                                              | yes      |
| `resource_group_name`        | Name of the resource group to deploy into                    | string       | -                                              | yes      |
| `location`                   | Azure region for deployed resources                          | string       | -                                              | yes      |
| `tsuga_api_key`              | Tsuga API Key for integration                                | string       | -                                              | yes      |
| `tsuga_intake_url`           | Tsuga OTLP/HTTP ingestion endpoint                           | string       | -                                              | yes      |
| `prefix`                     | Base name for resources                                      | string       | "tsuga"                                        | no       |
| `enable_metrics`             | Enable metrics collection from Azure to Tsuga                | bool         | true                                           | no       |
| `collection_interval`        | How often to pull metrics (metrics only)                     | string       | "60s"                                          | no       |
| `min_replicas`               | Minimum number of container replicas                         | number       | 1                                              | no       |
| `max_replicas`               | Maximum number of container replicas                         | number       | 3                                              | no       |
| `cpu`                        | CPU allocation for container (in cores)                      | number       | 0.5                                            | no       |
| `memory`                     | Memory allocation for container                              | string       | "1Gi"                                          | no       |
| `otel_collector_image`       | OTel Collector container image                               | string       | "otel/opentelemetry-collector-contrib:0.145.0" | no       |
| `resource_targets`           | Resource groups to filter metrics (metrics only)             | list(string) | []                                             | no       |
| `tags`                       | Tags to apply to resources                                   | map(string)  | {}                                             | no       |
| `enable_activity_logs`       | Enable Activity Log collection (subscription-wide)           | bool         | false                                          | no       |
| `enable_resource_logs`       | Enable resource diagnostic log collection (same region only) | bool         | false                                          | no       |
| `eventhub_capacity`          | Throughput units for the Event Hub Namespace                 | number       | 1                                              | no       |
| `eventhub_partition_count`   | Number of partitions for the logs Event Hub (see note below) | number       | 4                                              | no       |
| `eventhub_message_retention` | Days to retain messages in the Event Hub                     | number       | 1                                              | no       |

> **Note on `eventhub_partition_count`:** Set this to at least the value of `max_replicas`, since each collector replica consumes from one partition. The partition count **cannot be changed after creation** (Standard SKU) — the Event Hub must be destroyed and recreated. The default of 4 accommodates the default `max_replicas` of 3.

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
