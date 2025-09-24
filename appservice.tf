# Provider Configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  type    = string
  default = "appservice-rg"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "app_service_plan_name" {
  type    = string
  default = "appservice-plan"
}

variable "app_service_name" {
  type    = string
  default = "example-appservice"
}

variable "app_insights_name" {
  type    = string
  default = "example-appinsights"
}

variable "custom_domain_name" {
  type    = string
  default = "www.example.com"
}

# Resource Group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

# Application Insights
resource "azurerm_application_insights" "this" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
}

# App Service Plan
resource "azurerm_app_service_plan" "this" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "Linux"
  reserved            = true  # Required for Linux

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Linux Web App
resource "azurerm_linux_web_app" "this" {
  name                = var.app_service_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_app_service_plan.this.id

  site_config {
    linux_fx_version = "NODE|18-lts"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE           = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY    = azurerm_application_insights.this.instrumentation_key
  }

  depends_on = [azurerm_application_insights.this]
}

# Optional: Custom Domain
resource "azurerm_app_service_custom_hostname_binding" "this" {
  hostname            = var.custom_domain_name
  app_service_name    = azurerm_linux_web_app.this.name
  resource_group_name = azurerm_resource_group.this.name
}
