resource "azurerm_subnet_route_table_association" "aks-subnet-to-route-table" {
  subnet_id      = var.aks-subnet-id
  route_table_id = var.route-table-id
}
