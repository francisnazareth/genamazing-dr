# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.91"
    }
  }

  required_version = ">= 1.0"
}

provider "azurerm" {

  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
   }
}

data "azurerm_client_config" "current" {}

output "current_client_id" {
  value = data.azurerm_client_config.current.client_id
}

output "current_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "current_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "current_object_id" {
  value = data.azurerm_client_config.current.object_id
}

module "rg" {
    source         = "./rg"
    customer-name  = var.customer-name
    hub-location   = var.hub-location
    env                   = var.env
    createdby             = var.createdby
    creationdate          = var.creationdate
}

module "storage" {
    source         = "./storage"
    rg-name        = module.rg.spoke-rg-name
    rg-location    = module.rg.rg-location
    env                   = var.env
    createdby             = var.createdby
    creationdate          = var.creationdate
    customer-name         = var.customer-name
    prod-vnet-id          = module.vnet.prod-vnet-id
    pe-subnet-id         = module.vnet.pe-subnet-id
    depends_on            = [module.vnet]
}

module "vnet" {
    source               = "./vnet"
    rg-name              = module.rg.hub-rg-name
    rg-prod-name              = module.rg.spoke-rg-name
    rg-location          = module.rg.rg-location
    env                   = var.env
    createdby             = var.createdby
    creationdate          = var.creationdate
    hub-vnet-address-space           = var.hub-vnet-address-space
    prod-vnet-address-space          = var.spoke-vnet-address-space
    firewall-subnet-address-space    = var.firewall-subnet-address-space
    appgw-subnet-address-space       = var.appgw-subnet-address-space
    gateway-subnet-address-space     = var.gateway-subnet-address-space
    bastion-subnet-address-space     = var.bastion-subnet-address-space
    aks-subnet-address-space         = var.aks-subnet-address-space
    pe-subnet-address-space          = var.pe-subnet-address-space
    mysql-subnet-address-space       = var.mysql-subnet-address-space
    mgmt-subnet-1-address-space      = var.mgmt-subnet-1-address-space
    customer-name                    = var.customer-name
}

module "route-table" {
    source               = "./route-table"
    rg-name              = module.rg.spoke-rg-name
    rg-location          = module.rg.rg-location
    prod-vnet-address-space = var.spoke-vnet-address-space
    firewall-private-ip  = module.firewall.firewall-private-ip
    env                   = var.env
    createdby             = var.createdby
    creationdate          = var.creationdate
}

module "route-table-association" {
   source                = "./route-table-association" 
   route-table-id        = module.route-table.route-table-id 
   aks-subnet-id         = module.vnet.aks-subnet-id
}

module "aks" {
   source                = "./aks"
   env                   = var.env
   createdby             = var.createdby
   creationdate          = var.creationdate
   customer-name         = var.customer-name
   rg-name               = module.rg.spoke-rg-name
   rg-location           = module.rg.rg-location
   prod-vnet-id          = module.vnet.prod-vnet-id
   aks-subnet-id         = module.vnet.aks-subnet-id
   la-workspace-id       = var.la-workspace-id
   aks-vm-size           = var.aks-vm-size
   depends_on            = [module.route-table-association]
}

module "mysql" {
   source                = "./mysql"
   env                   = var.env
   createdby             = var.createdby
   creationdate          = var.creationdate
   customer-name         = var.customer-name
   rg-name               = module.rg.spoke-rg-name
   rg-location           = module.rg.rg-location
   vnet-id               = module.vnet.prod-vnet-id
   mysql-subnet-id       = module.vnet.mysql-subnet-id
   mysql-userid          = var.mysql-userid
   mysql-password        = var.mysql-password
   mysql-sku             = var.mysql-sku
}

module "nsg"  {
    source         = "./nsg"
    rg-name        = module.rg.hub-rg-name
    rg-location    = module.rg.rg-location
    env                   = var.env
    createdby             = var.createdby
    creationdate          = var.creationdate
}

module "nic" {
    source               = "./nic"
    rg-name              = module.rg.hub-rg-name
    rg-location          = module.rg.rg-location
    mgmt-snet-1-id       = module.vnet.management-snet-1-id
    nsg-id               = module.nsg.nsg-id
   env                   = var.env
   createdby             = var.createdby
   creationdate          = var.creationdate
   depends_on            = [module.nsg]
}

module "bastion" {
    source               = "./bastion"
    rg-name              = module.rg.hub-rg-name
    rg-location          = module.rg.rg-location
    bastion-snet-id      = module.vnet.bastion-snet-id
    depends_on           = [module.vnet]
   env                   = var.env
   createdby             = var.createdby
   creationdate          = var.creationdate
}

module "appgw" {
   source                = "./application-gateway"
   rg-name               = module.rg.spoke-rg-name
   rg-location           = module.rg.rg-location
   customer-name         = var.customer-name
   appgw-snet-id         = module.vnet.appgw-snet-id
   depends_on            = [module.vnet]
   env                   = var.env
   createdby             = var.createdby
   creationdate          = var.creationdate
}

module "firewall" {
   source                = "./firewall"
   rg-name               = module.rg.hub-rg-name
   rg-location           = module.rg.rg-location
   firewall-snet-id      = module.vnet.firewall-snet-id
   la-workspace-id       = var.la-workspace-id
   customer-name         = var.customer-name
   env                   = var.env
   createdby             = var.createdby
   creationdate          = var.creationdate
   prod-vnet-address-space = var.spoke-vnet-address-space
   depends_on            = [module.vnet]
}

module "virtualmachines" {
   source                = "./virtualmachines"
   rg-name               = module.rg.hub-rg-name
   rg-location           = module.rg.rg-location
   la-workspace-id       = var.la-workspace-id
   la-workspace-key      = var.la-workspace-key
   linux-admin-userid  = var.linux-admin-userid
   linux-admin-password  = var.linux-admin-password
   nic-linjumpserver1-id = module.nic.nic-linjumpserver1-id
   depends_on            = [module.vnet]
   env                   = var.env
   createdby             = var.createdby
   creationdate          = var.creationdate
}

#module "vnet-gateway" { 
#   source               = "./vnet-gateway"
#   rg-name               = module.rg.rg-name
#   rg-location          = module.rg.rg-location
#   vnetgw-snet-id        = module.vnet.vnetgw-snet-id
#   depends_on            = [module.vnet]
#}
