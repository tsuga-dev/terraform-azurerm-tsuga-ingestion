# Telemetry Collection Integration - Azure to Tsuga

## Prerequisites

- Download `az` CLI.
- Download `terraform` CLI.
- Perform `az login` before performing terraform commands.
- Tsuga API Key.
- Tsuga Intake URL.

## Usage

The `tsuga-otel-module` folder contains our OTel Tsuga terraform module for metrics ingestion from Azure Monitor.

### Configuration Variables

| Variable               | Description                                   | Type         | Default                                        | Required |
| ---------------------- | --------------------------------------------- | ------------ | ---------------------------------------------- | -------- |
| `subscription_id`      | Azure Subscription ID to collect metrics from | string       | -                                              | yes      |
| `resource_group_name`  | Name of the resource group to deploy into     | string       | -                                              | yes      |
| `location`             | Azure region for deployed resources           | string       | -                                              | yes      |
| `tsuga_api_key`        | Tsuga API Key for integration                 | string       | -                                              | yes      |
| `tsuga_intake_url`     | Tsuga OTLP/HTTP ingestion endpoint            | string       | -                                              | yes      |
| `prefix`               | Base name for resources                       | string       | "tsuga"                                        | no       |
| `enable_metrics`       | Enable metrics collection from Azure to Tsuga | bool         | true                                           | no       |
| `collection_interval`  | How often to pull metrics from Azure Monitor  | string       | "60s"                                          | no       |
| `min_replicas`         | Minimum number of container replicas          | number       | 1                                              | no       |
| `max_replicas`         | Maximum number of container replicas          | number       | 3                                              | no       |
| `cpu`                  | CPU allocation for container (in cores)       | number       | 0.5                                            | no       |
| `memory`               | Memory allocation for container               | string       | "1Gi"                                          | no       |
| `otel_collector_image` | OTel Collector container image                | string       | "otel/opentelemetry-collector-contrib:0.145.0" | no       |
| `resource_targets`     | List of resource groups to filter metrics     | list(string) | []                                             | no       |
| `tags`                 | Tags to apply to resources                    | map(string)  | {}                                             | no       |

## Examples

### Metrics Only

```bash
cd stacks/metrics-only
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### Logs

Coming soon!

## Architecture

The module deploys:

- **Azure Container App** - Runs the OpenTelemetry Collector
- **Container App Environment** - Hosting environment for the container
- **User-Assigned Managed Identity** - For authenticating to Azure Monitor
- **Role Assignment** - Grants "Monitoring Reader" role to the managed identity

The collector uses the `azuremonitor` receiver with the batch API for efficient metrics collection (360,000 API calls/hour vs 12,000 with standard API).

## Configuration Changes

When the OTel configuration changes, a new container app revision is automatically created (via `revision_suffix` based on config hash). This ensures the collector picks up the new configuration.

## Security

Note that for convenience, the Tsuga API key is passed in Terraform state. You can mitigate this by:

- Encrypting Terraform's state
- Using Azure Key Vault with a separate secret management process
