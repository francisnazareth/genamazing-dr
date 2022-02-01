resource "azurerm_public_ip" "pip-firewall" {
  name                = "pip-azure-firewall"
  location            = var.rg-location
  resource_group_name = var.rg-name
  allocation_method   = "Static"
  availability_zone   = "Zone-Redundant"
  sku                 = "Standard"

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_firewall_policy" "fw-policy" {
  name                = "fw-policy-01"
  resource_group_name = var.rg-name
  location            = var.rg-location
  sku                 = "Premium"
  threat_intelligence_mode = "Deny"
  intrusion_detection  {
    mode = "Deny"
  }
}

resource "azurerm_firewall" "azure-ext-fw" {
  name                = "fw-${var.customer-name}-hub-ne-01"
  location            = var.rg-location
  resource_group_name = var.rg-name
  sku_tier            = "Premium"
  zones               = [1,2,3]
  firewall_policy_id = azurerm_firewall_policy.fw-policy.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall-snet-id
    public_ip_address_id = azurerm_public_ip.pip-firewall.id
  }

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "aks-rule-collection" {
  name                = "aks-collection"
  firewall_policy_id = azurerm_firewall_policy.fw-policy.id
  priority            = 100

  network_rule_collection {
    priority = 400
    action = "Allow"
    name = "aks-network-rule-collection"
    rule {
       name = "FWR-AKS-AZURE-GLOBAL-001"
       source_addresses = [var.prod-vnet-address-space]
       destination_addresses = ["AzureCloud"]
       destination_ports = ["1194"]
       protocols = ["UDP"]
    }   
    rule {
       name = "FWR-AKS-AZURE-GLOBAL-002"
       source_addresses = [var.prod-vnet-address-space]
       destination_ports = ["9000"]
       destination_addresses = ["AzureCloud"]
       protocols = ["TCP"]
    }
    rule {
       name = "FWR-AKS-AZURE-GLOBAL-003"
       source_addresses = [var.prod-vnet-address-space]
       destination_ports = ["123"]
       destination_addresses = ["ntp.ubuntu.com"]
       protocols = ["UDP"]
    }
  }
  
  application_rule_collection {
    priority = 500
    action = "Allow"
    name = "aks-application-rule-collection"

    rule {
       name = "FWARG-AKS-REQUIREMENTS-001"

       source_addresses = [var.prod-vnet-address-space]
       destination_fqdn_tags = ["AzureKubernetesService"]

       protocols {
         port = "443"
         type = "Https"
       }

       protocols {
         port = "80"
         type = "Http"
       }
    }
  }   
}
