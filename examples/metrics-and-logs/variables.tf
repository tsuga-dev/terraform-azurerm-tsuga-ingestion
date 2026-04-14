variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "tsuga"
}

variable "tsuga_api_key" {
  description = "Tsuga API key"
  type        = string
  sensitive   = true
}

variable "tsuga_intake_url" {
  description = "Tsuga OTLP/HTTP endpoint URL"
  type        = string
}

variable "collection_interval" {
  description = "Metrics collection interval"
  type        = string
  default     = "60s"
}

variable "logs_min_replicas" {
  description = "Minimum replicas for the logs container app"
  type        = number
  default     = 1
}

variable "logs_max_replicas" {
  description = "Maximum replicas for the logs container app"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
