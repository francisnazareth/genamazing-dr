resource "azurerm_linux_virtual_machine" "vm-jumpbox-1" {
  name                = "linjumpserver1"
  resource_group_name = var.rg-name
  location            = var.rg-location
  size                = "Standard_D2s_v4"
  admin_username      = var.linux-admin-userid
  admin_password      = var.linux-admin-password
  disable_password_authentication  = "false"

  network_interface_ids = [
    var.nic-linjumpserver1-id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  tags = {
    Environment  = var.env,
    CreatedBy    = var.createdby,
    CreationDate = var.creationdate
  }
}

resource "azurerm_virtual_machine_extension" "da" {
  name                       = "DAExtension"
  virtual_machine_id         =  azurerm_linux_virtual_machine.vm-jumpbox-1.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId" : "${var.la-workspace-id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${var.la-workspace-key}"
    }
  PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "azurecli-kubectl-helm" {
  name                 = "custom-extn-sample"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-jumpbox-1.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings= <<SETTINGS
   {
      "fileUris": ["https://raw.githubusercontent.com/francisnazareth/azure-nodejs/main/kubernetes-setup.sh"
                  ]
   }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
           "commandToExecute": "sh kubernetes-setup.sh"
    }
  PROTECTED_SETTINGS
}
