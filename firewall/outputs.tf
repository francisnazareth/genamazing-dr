output "firewall-private-ip" {
 value = azurerm_firewall.azure-ext-fw.ip_configuration[0].private_ip_address
}

