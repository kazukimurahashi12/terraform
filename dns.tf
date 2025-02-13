### Azure Private DNS ###

resource "azurerm_private_dns_zone" "main" {
  name                = "etudesnextdns.com"
  resource_group_name = azurerm_resource_group.main.name
}
