resource "azurerm_virtual_network" "hub-vnet" {
  name                = "vnet-drhub-ne-01"
  location            = var.rg-location
  resource_group_name = var.rg-name
  address_space       = [var.hub-vnet-address-space]

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_virtual_network" "prod-vnet" {
  name                = "vnet-${var.env}-ne-01"
  location            = var.rg-location
  resource_group_name = var.rg-prod-name
  address_space       = [var.prod-vnet-address-space]

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "hub-to-${var.env}"
  resource_group_name = var.rg-name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.prod-vnet.id
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "${var.env}-to-hub"
  resource_group_name = var.rg-prod-name
  virtual_network_name      = azurerm_virtual_network.prod-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id
}

resource "azurerm_subnet" "hub-bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = [var.bastion-subnet-address-space]
}

resource "azurerm_subnet" "hub-firewall-subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = [var.firewall-subnet-address-space]
}

resource "azurerm_subnet" "hub-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = [var.gateway-subnet-address-space]
}

resource "azurerm_subnet" "hub-mgmt-subnet-01" {
  name                 = "snet-mgmt-${var.customer-name}-hub-01"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = [var.mgmt-subnet-1-address-space]
}

resource "azurerm_subnet" "prod-aks-subnet" {
  name                 = "snet-aks-${var.customer-name}-prod-we-01"
  resource_group_name  = var.rg-prod-name
  virtual_network_name = azurerm_virtual_network.prod-vnet.name
  address_prefixes     = [var.aks-subnet-address-space]

  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

resource "azurerm_subnet" "appgw-subnet" {
  name                 = "snet-aag-${var.customer-name}-${var.env}-01"
  resource_group_name  = var.rg-prod-name
  virtual_network_name = azurerm_virtual_network.prod-vnet.name
  address_prefixes     = [var.appgw-subnet-address-space]
}

resource "azurerm_subnet" "prod-pe-subnet" {
  name                 = "snet-pe-${var.customer-name}-prod-we-01"
  resource_group_name  = var.rg-prod-name
  virtual_network_name = azurerm_virtual_network.prod-vnet.name
  address_prefixes     = [var.pe-subnet-address-space]

  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

resource "azurerm_subnet" "prod-mysql-subnet" {

  name                 = "snet-mysql-${var.customer-name}-prod-we-01"
  resource_group_name  = var.rg-prod-name
  virtual_network_name = azurerm_virtual_network.prod-vnet.name
  address_prefixes     = [var.mysql-subnet-address-space]

  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

