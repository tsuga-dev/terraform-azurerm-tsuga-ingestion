variable "subscription_id" {
  description = "Azure Subscription ID to collect metrics from"
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
  description = "Metrics collection interval"
  type        = string
  default     = "60s"
}

variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
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

variable "otel_collector_image" {
  description = "OTel Collector container image"
  type        = string
  default     = "otel/opentelemetry-collector-contrib:0.145.0"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "resource_targets" {
  description = "List of Azure resource groups (names) to collect metrics from. If empty, collects subscription-level metrics."
  type        = list(string)
  default     = []
}
