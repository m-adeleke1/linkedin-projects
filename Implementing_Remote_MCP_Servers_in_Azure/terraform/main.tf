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
  subscription_id = "dcf32054-c1fe-4e23-995a-89c1ebc7ed29"
  tenant_id       = "4cfe372a-37a4-44f8-91b2-5faf34253c62"
  client_id       = "1171a4c6-c3e7-487d-92c6-1d9b9d2e5eaf"
  client_secret   = "IR58Q~jvJC7vOogNC7GOXARJtnexMk9fYjiieccZ"
}

data "azurerm_resource_group" "existing_rg" {
  name = "RG1"
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
  name                = "mcp-weather-app-12345"  # Replace with unique name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  service_plan_id     = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
    app_command_line = "uvicorn main:app --host 0.0.0.0 --reload"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "PYTHON_ENABLE_WORKER_EXTENSIONS"     = "true"
  }
}

resource "azurerm_linux_web_app" "calculator_app" {
  name                = "mcp-calculator-app-67890"  # Replace with unique name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  service_plan_id     = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "PYTHON|3.9"
    app_command_line = "uvicorn main:app --host 0.0.0.0 --reload"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "PYTHON_ENABLE_WORKER_EXTENSIONS"     = "true"
  }
}

resource "azurerm_app_service_source_control" "weather_source" {
  app_id                 = azurerm_linux_web_app.weather_app.id
  repo_url               = "https://github.com/m-adeleke1/LinkedIn"
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_app_service_source_control" "calculator_source" {
  app_id                 = azurerm_linux_web_app.calculator_app.id
  repo_url               = "https://github.com/m-adeleke1/LinkedIn"
  branch                 = "main"
  use_manual_integration = true
}
