resource "azurerm_network_security_group" "nsg_hub_01" {
  name                = "nsg-drhub-01"
  location            = var.rg-location
  resource_group_name = var.rg-name

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}
