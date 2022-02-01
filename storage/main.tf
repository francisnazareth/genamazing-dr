resource "random_id" "storage" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    storage_seed = "1234"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "genamazing-storage" {
  name                     = "stga${var.env}ne09"
  resource_group_name      = var.rg-name
  location                 = var.rg-location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_storage_share" "share1" {
  name                 = "ga-${var.env}-private"
  storage_account_name = azurerm_storage_account.genamazing-storage.name
  quota                = 100
}


resource "azurerm_storage_share" "share2" {
  name                 = "ga-${var.env}-public"
  storage_account_name = azurerm_storage_account.genamazing-storage.name
  quota                = 100
}


resource "azurerm_private_dns_zone" "storage-private-dns-zone" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.rg-name

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage-private-vnet-link" {
  name                  = "storage-private-vnet-link"
  resource_group_name   = var.rg-name
  private_dns_zone_name = azurerm_private_dns_zone.storage-private-dns-zone.name
  virtual_network_id    = var.prod-vnet-id
}

resource "azurerm_private_endpoint" "storage-pe" {
  name                = "pe-storage-${var.customer-name}-${var.env}-we-01"
  location            = var.rg-location
  resource_group_name = var.rg-name
  subnet_id           = var.pe-subnet-id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage-private-dns-zone.id]
  }

  private_service_connection {
    name                           = "storage-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.genamazing-storage.id
    subresource_names              = [ "file" ]
    is_manual_connection           = false
  }

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}
