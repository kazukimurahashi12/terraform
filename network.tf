### Azure Virtual Network と Network Security Group ###

# VirtualNetwork
resource "azurerm_virtual_network" "main" {
  name                = "etudesnextvnet"
  address_space       = ["10.0.0.0/16"]  # 大枠のアドレス範囲
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

#----------------------------------------
# 1) Application Gateway 用サブネット (専用)
#----------------------------------------
resource "azurerm_subnet" "subnet_appgw" {
  name                 = "etudesnextsubnetappgw"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]  # AppGW専用サブネット
}

#----------------------------------------
# 2) 受講管理用サブネット
#----------------------------------------
resource "azurerm_subnet" "subnetzyukou" {
  name                 = "etudesnextsubnetzyukou"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

#----------------------------------------
# 3) 申し込み用サブネット
#----------------------------------------
resource "azurerm_subnet" "subnetmousikomi" {
  name                 = "etudesnextsubnetmousikomi"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "etudesnextnsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# もし各サブネットにNSGを関連付けたい場合は、下記リソースをサブネットの数だけ追加
# resource "azurerm_subnet_network_security_group_association" "subnet_appgw_nsg" {
#   subnet_id                 = azurerm_subnet.subnet_appgw.id
#   network_security_group_id = azurerm_network_security_group.main.id
# }

# resource "azurerm_subnet_network_security_group_association" "subnet_zyukou_nsg" {
#   subnet_id                 = azurerm_subnet.subnetzyukou.id
#   network_security_group_id = azurerm_network_security_group.main.id
# }

# resource "azurerm_subnet_network_security_group_association" "subnet_mousikomi_nsg" {
#   subnet_id                 = azurerm_subnet.subnetmousikomi.id
#   network_security_group_id = azurerm_network_security_group.main.id
# }
