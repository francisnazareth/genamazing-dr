resource "azurerm_public_ip" "appgw-pip1" {
  name                = "pip-dr-appgw1"
  resource_group_name = var.rg-name
  location            = var.rg-location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  
  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

#since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${var.customer-name}-beap"
  frontend_port_name             = "${var.customer-name}-feport"
  frontend_ip_configuration_name = "${var.customer-name}-feip"
  http_setting_name              = "${var.customer-name}-be-htst"
  listener_name                  = "${var.customer-name}-httplstn"
  request_routing_rule_name      = "${var.customer-name}-rqrt"
  redirect_configuration_name    = "${var.customer-name}-rdrcfg"
}

resource "azurerm_application_gateway" "agw1" {
  name                = "agw-${var.customer-name}-dr-ne-01"
  resource_group_name = var.rg-name
  location            = var.rg-location

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.appgw-snet-id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw-pip1.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
