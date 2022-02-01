output "hub-vnet-name" {
 value = azurerm_virtual_network.hub-vnet.name
}

output "prod-vnet-id" { 
    value = azurerm_virtual_network.prod-vnet.id
}

output "pe-subnet-id" { 
    value = azurerm_subnet.prod-pe-subnet.id
}

output "mysql-subnet-id" { 
    value = azurerm_subnet.prod-mysql-subnet.id
}

output "aks-subnet-id" { 
   value = azurerm_subnet.prod-aks-subnet.id
}

output "bastion-snet-id" {
  value = azurerm_subnet.hub-bastion-subnet.id
}

output "vnetgw-snet-id" {
   value = azurerm_subnet.hub-gateway-subnet.id
}

output "firewall-snet-id" {
   value = azurerm_subnet.hub-firewall-subnet.id
}

output "appgw-snet-id" {
   value = azurerm_subnet.appgw-subnet.id
}

output "management-snet-1-id" {
  value = azurerm_subnet.hub-mgmt-subnet-01.id
}

