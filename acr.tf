### Azure Container Registry ###

resource "azurerm_container_registry" "main" {
  name                     = "etudesnextacr"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  sku                      = "Standard"
  admin_enabled            = true #簡易デモ,ACRで管理者ユーザーを有効化する
}
