output "hub-rg-name" {
   value  = azurerm_resource_group.hub-rg.name
}

output "spoke-rg-name" {
   value  = azurerm_resource_group.spoke-rg.name
}

output "rg-location" {
   value = azurerm_resource_group.hub-rg.location
}
