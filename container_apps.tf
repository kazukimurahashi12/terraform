### Azure Container Apps ###

resource "azurerm_container_app_environment" "main" {
  name                = "etudes-next-container-app-env"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # VNet連携する場合 (Application Gateway から内部アクセス)
  # vnet_configuration {
  #   infrastructure_subnet_id = azurerm_subnet.subnet_containerapps.id
  #   # ...
  # }
}

resource "azurerm_container_app" "php" {
  name                         = "etudes-php-app"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode = "Single"

  template {
    container {
      name   = "php"
      # ACR にプッシュしたイメージを指定
      image  = "${azurerm_container_registry.main.login_server}/my-php-app:latest"
      cpu    = 0.5
      memory = "1.0Gi"
    }
  }
}

resource "azurerm_container_app" "go_api" {
  name                         = "etudes-go-api"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode = "Single"

  template {
    container {
      name   = "go-api"
      # ACR イメージ
      image  = "${azurerm_container_registry.main.login_server}/my-go-api:latest"
      cpu    = 0.5
      memory = "1.0Gi"
   
    }
  }
}

resource "azurerm_container_app" "memcached" {
  name                         = "etudes-memcached"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode = "Single"

  template {
    container {
      name   = "memcached"
      image  = "${azurerm_container_registry.main.login_server}/my-memcached:latest"
      cpu    = 0.25
      memory = "0.25Gi"
    }

  }
}

resource "azurerm_container_app" "redis" {
  name                         = "etudes-redis"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode = "Single"

  template {
    container {
      name   = "redis"
      #<ACRのログインサーバー>/<レポジトリ名>:<タグ>
      image  = "${azurerm_container_registry.main.login_server}/my-redis:latest"
      cpu    = 0.25
      memory = "0.25Gi"
    }

  }
}
