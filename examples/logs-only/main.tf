provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group for the OTel collector
resource "azurerm_resource_group" "tsuga" {
  name     = "${var.prefix}-tsuga-ingestion"
  location = var.location
  tags     = var.tags
}

module "tsuga_otel" {
  source = "../.."

  subscription_id     = var.subscription_id
  resource_group_name = azurerm_resource_group.tsuga.name
  location            = var.location
  prefix              = var.prefix

  tsuga_api_key    = var.tsuga_api_key
  tsuga_intake_url = var.tsuga_intake_url

  enable_metrics       = false
  enable_activity_logs = true
  enable_resource_logs = true

  logs_min_replicas = var.logs_min_replicas
  logs_max_replicas = var.logs_max_replicas

  tags = var.tags
}
