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
  subscription_id = "[YOUR_AZURE_SUBSCRIPTION_ID]"  # e.g. 80ea84e8-afce-4851-928a-9e2219724c69
  tenant_id       = "[YOUR_AZURE_TENANT_ID]"
  client_id       = "[YOUR_AZURE_CLIENT_ID]"
  client_secret   = "[YOUR_AZURE_CLIENT_SECRET]"
}

# Use the existing resource group provided by the sandbox
data "azurerm_resource_group" "existing_rg" {
  name = "1-1d88574f-playground-sandbox"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "mcp-servers-plan"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_linux_web_app" "weather_app" {
  name                = "mcp-weather-app-[random_id]"  # Replace [random_id] with a unique suffix
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  service_plan_id     = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
    startup_command  = "uvicorn main:app --host 0.0.0.0 --reload"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "PYTHON_ENABLE_WORKER_EXTENSIONS"     = "true"
  }
}

resource "azurerm_linux_web_app" "calculator_app" {
  name                = "mcp-calculator-app-[random_id]"  # Replace [random_id] with a unique suffix
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  service_plan_id     = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
    startup_command  = "uvicorn main:app --host 0.0.0.0 --reload"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "PYTHON_ENABLE_WORKER_EXTENSIONS"     = "true"
  }
}

# GitHub deployment for Weather Server
resource "azurerm_app_service_source_control" "weather_source" {
  app_id                 = azurerm_linux_web_app.weather_app.id
  repo_url               = "https://github.com/[YOUR_GITHUB_USERNAME]/LinkedIn"
  branch                 = "main"
  use_manual_integration = true
}

# GitHub deployment for Calculator Server
resource "azurerm_app_service_source_control" "calculator_source" {
  app_id                 = azurerm_linux_web_app.calculator_app.id
  repo_url               = "https://github.com/[YOUR_GITHUB_USERNAME]/LinkedIn"
  branch                 = "main"
  use_manual_integration = true
}
