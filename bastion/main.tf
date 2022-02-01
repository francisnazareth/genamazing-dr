resource "azurerm_public_ip" "bastion-pip" {
  name                = "pip-dr-bastion"
  location            = var.rg-location
  resource_group_name = var.rg-name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_bastion_host" "bastion-svc" {
  name                = "dr-bastion-service"
  location            = var.rg-location
  resource_group_name = var.rg-name

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.bastion-snet-id
    public_ip_address_id = azurerm_public_ip.bastion-pip.id
  }
}
