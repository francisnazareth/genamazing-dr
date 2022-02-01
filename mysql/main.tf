resource "azurerm_private_dns_zone" "genamazing-dns" {
  name                = "genamazing.mysql.database.azure.com"
  resource_group_name = var.rg-name
  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "genamazing-vnet-link" {
  name                  = "genamazingvnetzone.com"
  private_dns_zone_name = azurerm_private_dns_zone.genamazing-dns.name
  virtual_network_id    = var.vnet-id
  resource_group_name   = var.rg-name
}

resource "azurerm_mysql_flexible_server" "genamazing-mysql-svr" {
  name                = "${var.customer-name}-${var.env}-mysql-ne-01"
  location            = var.rg-location
  resource_group_name = var.rg-name
  administrator_login          =  var.mysql-userid
  administrator_password =  var.mysql-password
  backup_retention_days  = 7
  delegated_subnet_id    = var.mysql-subnet-id
  private_dns_zone_id    = azurerm_private_dns_zone.genamazing-dns.id
  sku_name               = var.mysql-sku 

  high_availability {
    mode = "ZoneRedundant"
  }
  
  storage {
    auto_grow_enabled = true
  }
  
  depends_on = [azurerm_private_dns_zone_virtual_network_link.genamazing-vnet-link]
  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}
