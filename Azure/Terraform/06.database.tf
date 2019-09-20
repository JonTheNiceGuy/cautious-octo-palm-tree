locals {
  DatabaseCount  = 2
  DatabaseLayout = ["${var.Az1}", "${var.Az2}"]
}

resource "azurerm_virtual_machine" "Database" {
  name                  = "Database${count.index}"
  zones                 = ["${element(local.DatabaseLayout, count.index)}"]
  location              = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name   = "${azurerm_resource_group.ResourceGroup.name}"
  network_interface_ids = ["${element(azurerm_network_interface.DatabaseNIC.*.id, count.index)}"]
  vm_size               = "Standard_B1ls"
  count                 = "${local.DatabaseCount}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Database${count.index}-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Database${count.index}"
    admin_username = "${var.vm_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${file("id_rsa.pub")}"
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
    }
  }

  tags = {
    DatabaseServer = "True",
    Env            = "Demo",
    Provisioning   = "${var.ProvisioningMethod}",
    Orchestration  = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_interface" "DatabaseNIC" {
  name                      = "Database${count.index}NIC"
  location                  = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name       = "${azurerm_resource_group.ResourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.DatabaseNSG.id}"
  count                     = "${local.DatabaseCount}"

  ip_configuration {
    name                          = "Database-nic-ip"
    subnet_id                     = "${azurerm_subnet.PrivateSubnet.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_security_group" "DatabaseNSG" {
  name                = "DatabaseNSG"
  location            = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}
