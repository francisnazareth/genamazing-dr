variable "customer-name" {
}

variable "hub-location" {
}

variable "location-prefix" {
}

variable "env" { 
}

variable "createdby" {
}

variable "creationdate" { 
}

variable "hub-vnet-address-space" { 
}

variable "spoke-vnet-address-space" { 
}
variable "la-workspace-id" {
}

variable "la-workspace-key" {}

#Address range for the Firewall subnet (0-31)
variable "firewall-subnet-address-space" {
}

#Address range for the bastion subnet (32 - 63)
variable "bastion-subnet-address-space" {
}

#Address range for the VNET gateway subnet (80 - 95)
variable "gateway-subnet-address-space" {
}

#Address range for the management subnet (96 - 111)
variable "mgmt-subnet-1-address-space" {
}

#Address range for the AKS subnet 
variable "aks-subnet-address-space" {
}

variable "pe-subnet-address-space" {
}

variable "mysql-subnet-address-space" {
}

variable "appgw-subnet-address-space" {
}

variable "linux-admin-userid" { 
  default = "adminuser"
}

variable "linux-admin-password" {
  default = "P@$$w0rd1234!"
}

variable "la-log-retention-in-days" {
  type   =  number
  default =  30
}

variable "aks-vm-size" { 
}

variable "mysql-userid" {
} 

variable "mysql-password" {
}

variable "mysql-sku" {
}

