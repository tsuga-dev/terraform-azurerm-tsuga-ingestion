variable "subscription_id" {
  description = "Azure Subscription ID to collect telemetry from"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region for deployed resources"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "tsuga"
}

variable "tsuga_api_key" {
  description = "Tsuga API key for authentication"
  type        = string
  sensitive   = true
}

variable "tsuga_intake_url" {
  description = "Tsuga OTLP/HTTP endpoint URL"
  type        = string
}

variable "enable_metrics" {
  description = "Enable metrics collection via Azure Monitor"
  type        = bool
  default     = true
}

variable "collection_interval" {
  description = "Metrics collection interval (only used when enable_metrics is true)"
  type        = string
  default     = "60s"
}

variable "logs_min_replicas" {
  description = "Minimum number of replicas for the logs container app"
  type        = number
  default     = 1
}

variable "logs_max_replicas" {
  description = "Maximum number of replicas for the logs container app"
  type        = number
  default     = 3
}

variable "cpu" {
  description = "CPU allocation for container (in cores)"
  type        = number
  default     = 0.5
}

variable "memory" {
  description = "Memory allocation for container (e.g., '1Gi')"
  type        = string
  default     = "1Gi"
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "resource_targets" {
  description = "List of Azure resource groups (names) to collect metrics from. If empty, collects subscription-level metrics. Only used when enable_metrics is true."
  type        = list(string)
  default     = []
}

variable "enable_activity_logs" {
  description = "Enable Activity Log collection via Event Hub (subscription-wide, not region-restricted)"
  type        = bool
  default     = false
}

variable "enable_resource_logs" {
  description = "Enable resource diagnostic log collection via Event Hub and Azure Policy (only targets resources in var.location)"
  type        = bool
  default     = false
}

variable "eventhub_capacity" {
  description = "Throughput units for the Event Hub Namespace (Standard SKU: 1-20)"
  type        = number
  default     = 1
}

variable "eventhub_partition_count" {
  description = "Number of partitions for the logs Event Hub"
  type        = number
  default     = 4
}

variable "eventhub_message_retention" {
  description = "Number of days to retain messages in the Event Hub"
  type        = number
  default     = 1
}
