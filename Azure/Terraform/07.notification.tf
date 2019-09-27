resource "azurerm_virtual_machine" "NotificationServer" {
  name                  = "NotificationServer"
  zones                 = ["${var.Az2}"]
  location              = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name   = "${azurerm_resource_group.ResourceGroup.name}"
  network_interface_ids = ["${azurerm_network_interface.NotificationServerNIC.id}"]
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
    name              = "NotificationServer-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "NotificationServer"
    admin_username = "${var.vm_user}"
    custom_data    = <<-EOT
#! /bin/bash -x
/usr/bin/apt update
/usr/bin/apt install -y ansible
echo --- > /tmp/playbook.yml
echo "- hosts: localhost" >> /tmp/playbook.yml
echo "  gather_facts: false" >> /tmp/playbook.yml
echo "  tasks:" >> /tmp/playbook.yml
echo "  - copy:" >> /tmp/playbook.yml
echo "      content: Confirmed" >> /tmp/playbook.yml
echo "      dest: /var/log/ansible_run.out" >> /tmp/playbook.yml
sleep 5
ansible-playbook /tmp/playbook.yml
sleep 5
EOT
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${file("id_rsa.pub")}"
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
    }
  }

  tags = {
    NotificationServerServer = "True",
    Env                      = "Demo",
    Provisioning             = "${var.ProvisioningMethod}",
    Orchestration            = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_interface" "NotificationServerNIC" {
  name                      = "NotificationServerNIC"
  location                  = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name       = "${azurerm_resource_group.ResourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.NotificationServerNSG.id}"

  ip_configuration {
    name                          = "NotificationServer-nic-ip"
    subnet_id                     = "${azurerm_subnet.PublicSubnet.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_security_group" "NotificationServerNSG" {
  name                = "NotificationServerNSG"
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
