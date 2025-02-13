### Azure Application Gateway ###

resource "azurerm_public_ip" "gateway" {
  name                = "gateway-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "main" {
  name                = "etudes_next_app_gateway"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku {
    name     = "Standard_v2" #WAF追加時は"WAF_v2"へ変更
    tier     = "Standard_v2" #WAF追加時は"WAF_v2"へ変更
    capacity = 1  # Gateway本体のインスタンス数
  }

  # #TODO
  # # WAF(Firewall Policy) - Blacklist
  # firewall_policy_id = azurerm_web_application_firewall_policy.gateway_policy.id

  # オートスケールの設定
  autoscale_configuration {
    # TODO
    min_capacity = 1
    max_capacity = 10
  }

  gateway_ip_configuration {
    name      = "app-gateway-ip-config"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  frontend_ip_configuration {
    name                 = "app-gateway-frontend-ip"
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  # フロントエンドポート (HTTP/HTTPS)
  frontend_port {
    name = "frontend-port-http"
    port = 80
  }

  frontend_port {
    name = "frontend-port-https"
    port = 443
  }

  #TODO
  #Key Vault?
  # SSL証明書 (マネージド想定)
#   ssl_certificate {
#   name                = "gateway-managed-cert"
#   key_vault_secret_id = data.azurerm_key_vault_certificate.mycert.secret_id
# }

  # バックエンドアドレスプール TODO(Container Apps 側のIP or FQDN)
  backend_address_pool {
    name = "backend-pool"

    # TODO
    ip_addresses = [
      # Container Apps の内部IPを仮定して記載
      "10.0.5.10"
    ]
  #   fqdns = [
  #     # FQDN
  #   "backend-app.internal.cloudapp.azure.com"
  # ]
  }

  # バックエンド HTTP設定
  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20

    # X-Forwarded-For 等クライアント情報の転送を有効化（デフォルトで有効）
    pick_host_name_from_backend_address = false
    probe_name                          = "backend-health-probe"
  }

  # 死活監視
  probe {
    name     = "backend-health-probe"
    protocol = "Http"
    path     = "/health"  # TODO Container App に合わせたパス
    interval            = 30
    timeout             = 20
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  # HTTP リスナー (80)
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "app-gateway-frontend-ip"
    frontend_port_name             = "frontend-port-http"
    protocol                       = "Http"
  }

  # HTTPS リスナー (443)
  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "app-gateway-frontend-ip"
    frontend_port_name             = "frontend-port-https"
    protocol                       = "Https"
    ssl_certificate_name           = "gateway-managed-cert"
  }

  # ルーティングルール (HTTP)
  request_routing_rule {
    name                       = "routing-rule-http"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
  }

  # ルーティングルール (HTTPS)
  request_routing_rule {
    name                       = "routing-rule-https"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 2
  }

  # カスタムエラーページ
  custom_error_configuration {
    status_code           = "HttpStatus502"
    #TODO
    custom_error_page_url = "https://<storage-static-page>/sorry.html"
  }
}
