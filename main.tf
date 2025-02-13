### プロバイダーの設定 ###

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
  }
}

provider "azurerm" {
  subscription_id = var.provider_credentials.subscription_id
  tenant_id       = var.provider_credentials.tenant_id
  client_id       = var.provider_credentials.sp_client_id
  client_secret   = var.provider_credentials.sp_client_secret
  features {}
}

# ランダムな文字列を生成
resource "random_string" "unique" {
  length  = 6
  upper   = false
  special = false
  lower   = true
}

# リソースグループ
locals {
  resource_group_name       = "etudesnext"
  # ストレージアカウント名にランダムな接尾追加
  storage_account_diag_name = "etudesnext${random_string.unique.result}"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
}

# ログ保管ストレージ
resource "azurerm_storage_account" "diag" {
  name                     = local.storage_account_diag_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}