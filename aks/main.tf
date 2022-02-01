
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.customer-name}-${var.env}-ne-01"
  location            = var.rg-location
  resource_group_name = var.rg-name
  dns_prefix          = "aks-${var.customer-name}-${var.env}"
  private_cluster_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 3
    max_pods   = 18
    availability_zones = [1, 2, 3]
    vm_size    = var.aks-vm-size
    vnet_subnet_id = var.aks-subnet-id
    type           = "VirtualMachineScaleSets" 
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"  
  }

  addon_profile {

    azure_policy {
      enabled = true
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.la-workspace-id
    }  
  }

  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}
