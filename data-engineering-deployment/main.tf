###CURRENT PROVIDER MUST BE PASTED AT THE TOP OF FILE. 
###NAVIGATE TO https://registry.terraform.io/browse/providers, CLICK ON THE RELEVANT PROVIDER OR SEARCH, AND CLICK ON 'USE PROVIDER'
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.74.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  skip_provider_registration = true

  features {

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }

    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }

  }
}


data "azurerm_client_config" "current" {}



# Define variables
variable "resource_group_name" {
    #*******REPLACE VALUE*******
  description = "Name of the Azure resource group"
  default     = ""
  #default     = "1-7574bdcd-playground-sandbox"
}

variable "location" {
    #*******REPLACE VALUE*******
  description = "Azure region where the resources will be deployed"
  default     = ""
  #default     = "South Central US"
}

variable "data_factory_name" {
    #*******REPLACE VALUE*******
  description = "Name of the Azure Data Factory"
  default     = ""
  #default     = "0927202219adf"
}

variable "data_lake_account_name" {
    #*******REPLACE VALUE*******
  description = "Name of the Azure Data Lake Storage account"
  default     = ""
  #default     = "0927202219adl"
}

variable "key_vault_name" {
    #*******REPLACE VALUE*******
  description = "Name of the Azure Key Vault"
  default     = ""
  #default     = "0927202219akv"
}

variable "synapse_name" {
    #*******REPLACE VALUE*******
  description = "Name of the Azure Synapse Analytics instance"
  default     = ""
  #default     = "0927202219asa"
}

# Create a resource group
resource "azurerm_resource_group" "arg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Azure Data Factory
resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = azurerm_resource_group.arg.name
}

# Create Azure Data Lake Storage Account
resource "azurerm_storage_account" "asa" {
  name                     = var.data_lake_account_name
  resource_group_name      = azurerm_resource_group.arg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  #hierarchical_namespace {
  #  enabled = true
  #}
}

# Create Azure Data Lake Storage Filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "adlfs" {
  name               = var.data_lake_account_name
  storage_account_id = azurerm_storage_account.asa.id
}

# Create Azure Key Vault
resource "azurerm_key_vault" "akv" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.arg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true
  enabled_for_template_deployment = true
  sku_name = "standard"

    #access_policy {
    #tenant_id = data.azurerm_client_config.current.tenant_id
    #object_id = data.azurerm_client_config.current.object_id

    #key_permissions = [
    #  "Get",
    #]

    #secret_permissions = [
    #  "Get",
    #]

    #storage_permissions = [
    #  "Get",
    #]
  #}

}

# Create Azure Synapse Analytics
resource "azurerm_synapse_workspace" "asw" {
  name                                 = var.synapse_name
  resource_group_name                  = azurerm_resource_group.arg.name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.adlfs.id
  #*******REPLACE VALUE*******
  sql_administrator_login              = ""
  sql_administrator_login_password     = ""
  #sql_administrator_login              = "sqladminuser"
  #sql_administrator_login_password     = "H@Sh1CoR3!"

  aad_admin {
    login     = "AzureAD Admin"
    #*******REPLACE VALUE*******
    #FIND THE OBJECT ID USING THE AZURE PORTAL. NAVIGATE TO ENTRA ID, CLICK ON USERS, FIND USERNAME, AND COPY THE OBJECT ID IN THE OVERVIEW
    object_id = ""
    #object_id = "d01535cb-7546-4c20-9163-b0550b59f2d1"
    #*******REPLACE VALUE*******
    #FIND THE TENANT ID USING THE AZURE PORTAL. COPY THE OBJECT ID IN THE OVERVIEW
    tenant_id = ""
    #tenant_id = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  }

  identity {
    type = "SystemAssigned"
  }

  #tags = {
  #  Env = "production"
  #}
}

# Output the necessary information for each resource (customize as needed)
output "data_factory_id" {
  value = azurerm_data_factory.adf.id
}

output "data_lake_storage_id" {
  value = azurerm_storage_account.asa.id
}

output "key_vault_id" {
  value = azurerm_key_vault.akv.id
}

output "synapse_id" {
  value = azurerm_synapse_workspace.asw.id
}
