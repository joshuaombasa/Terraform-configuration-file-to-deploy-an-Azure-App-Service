# Provider configuration
provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  default = "appservice-rg"
}

variable "location" {
  default = "East US"
}

# Resource Group
resource "azurerm_resource_group" "appservice_rg" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan
resource "azurerm_app_service_plan" "appservice_plan" {
  name                = "appservice-plan"
  location            = azurerm_resource_group.appservice_rg.location
  resource_group_name = azurerm_resource_group.appservice_rg.name
  kind                = "Linux"
  reserved            = true  # Required for Linux
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# App Service
resource "azurerm_linux_web_app" "appservice" {
  name                = "example-appservice"
  location            = azurerm_resource_group.appservice_rg.location
  resource_group_name = azurerm_resource_group.appservice_rg.name
  service_plan_id     = azurerm_app_service_plan.appservice_plan.id

  site_config {
    linux_fx_version = "NODE|18-lts"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
  }
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "example-appinsights"
  location            = azurerm_resource_group.appservice_rg.location
  resource_group_name = azurerm_resource_group.appservice_rg.name
  application_type    = "web"
}

# Custom Domain (Optional)
resource "azurerm_app_service_custom_hostname_binding" "custom_domain" {
  hostname            = "www.example.com"
  app_service_name    = azurerm_linux_web_app.appservice.name
  resource_group_name = azurerm_resource_group.appservice_rg.name
}
