locals {
  MonitoringCount  = 2
  MonitoringLayout = ["${var.Az1}", "${var.Az2}"]
}

resource "azurerm_virtual_machine" "Monitoring" {
  name                  = "Monitoring${count.index}"
  zones                 = ["${element(local.MonitoringLayout, count.index)}"]
  location              = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name   = "${azurerm_resource_group.ResourceGroup.name}"
  network_interface_ids = ["${element(azurerm_network_interface.MonitoringNIC.*.id, count.index)}"]
  vm_size               = "Standard_B1ls"
  count                 = "${local.MonitoringCount}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "Monitoring${count.index}-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "Monitoring${count.index}"
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
    MonitoringServer = "True",
    Env              = "Demo",
    Provisioning     = "${var.ProvisioningMethod}",
    Orchestration    = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_interface" "MonitoringNIC" {
  name                      = "Monitoring${count.index}NIC"
  location                  = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name       = "${azurerm_resource_group.ResourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.MonitoringNSG.id}"
  count                     = "${local.MonitoringCount}"

  ip_configuration {
    name                          = "Monitoring-nic-ip"
    subnet_id                     = "${azurerm_subnet.PrivateSubnet.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_security_group" "MonitoringNSG" {
  name                = "MonitoringNSG"
  location            = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}
