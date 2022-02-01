resource "azurerm_resource_group" "hub-rg" {
  name     = "rg-${var.customer-name}-drhub-ne-01"
  location = var.hub-location
  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_resource_group" "spoke-rg" {
  name     = "rg-${var.customer-name}-${var.env}-ne-01"
  location = var.hub-location
  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

