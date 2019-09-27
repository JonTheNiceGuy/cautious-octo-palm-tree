locals {
  DatabaseLayout = ["${var.Az1}", "${var.Az2}"]
}

resource "azurerm_virtual_machine" "Database1" {
  name                  = "Database1"
  zones                 = ["${element(local.DatabaseLayout, 1)}"]
  location              = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name   = "${azurerm_resource_group.ResourceGroup.name}"
  network_interface_ids = ["${azurerm_network_interface.Database1NIC.id}"]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Database1-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Database1"
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

resource "azurerm_virtual_machine" "Database2" {
  name                  = "Database2"
  zones                 = ["${element(local.DatabaseLayout, 2)}"]
  location              = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name   = "${azurerm_resource_group.ResourceGroup.name}"
  network_interface_ids = ["${azurerm_network_interface.Database2NIC.id}"]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Database2-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Database2"
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

resource "azurerm_network_interface" "Database1NIC" {
  name                      = "Database1NIC"
  location                  = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name       = "${azurerm_resource_group.ResourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.DatabaseNSG.id}"

  ip_configuration {
    name                          = "Database1-nic-ip"
    subnet_id                     = "${azurerm_subnet.PrivateSubnet.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_interface" "Database2NIC" {
  name                      = "Database2NIC"
  location                  = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name       = "${azurerm_resource_group.ResourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.DatabaseNSG.id}"

  ip_configuration {
    name                          = "Database2-nic-ip"
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

  security_rule {
    name                       = "CommonManagement-I-100"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${azurerm_network_interface.BastionNIC.private_ip_address}/32"
    destination_address_prefix = "*"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}
