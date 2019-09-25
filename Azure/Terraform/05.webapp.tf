locals {
  WebAppLayout = ["${var.Az1}", "${var.Az2}"]
}

resource "azurerm_virtual_machine" "WebApp1" {
  name                  = "WebApp1"
  zones                 = ["${element(local.WebAppLayout, 1)}"]
  location              = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name   = "${azurerm_resource_group.ResourceGroup.name}"
  network_interface_ids = ["${azurerm_network_interface.WebApp1NIC.id}"]
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
    name              = "WebApp1-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "WebApp1"
    admin_username = "${var.vm_user}"
    custom_data    = "${file("user-data.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${file("id_rsa.pub")}"
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
    }
  }

  tags = {
    WebServer     = "True",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_virtual_machine" "WebApp2" {
  name                  = "WebApp2"
  zones                 = ["${element(local.WebAppLayout, 2)}"]
  location              = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name   = "${azurerm_resource_group.ResourceGroup.name}"
  network_interface_ids = ["${azurerm_network_interface.WebApp2NIC.id}"]
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
    name              = "WebApp2-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "WebApp2"
    admin_username = "${var.vm_user}"
    custom_data    = "${file("user-data.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${file("id_rsa.pub")}"
      path     = "/home/${var.vm_user}/.ssh/authorized_keys"
    }
  }

  tags = {
    WebServer     = "True",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_interface" "WebApp1NIC" {
  name                      = "WebApp1NIC"
  location                  = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name       = "${azurerm_resource_group.ResourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.WebAppNSG.id}"

  ip_configuration {
    name                                    = "WebApp1-nic-ip"
    subnet_id                               = "${azurerm_subnet.PublicSubnet.id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.WebAppLB_BackEndPool.id}"]
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_interface" "WebApp2NIC" {
  name                      = "WebApp2NIC"
  location                  = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name       = "${azurerm_resource_group.ResourceGroup.name}"
  network_security_group_id = "${azurerm_network_security_group.WebAppNSG.id}"

  ip_configuration {
    name                                    = "WebApp2-nic-ip"
    subnet_id                               = "${azurerm_subnet.PublicSubnet.id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.WebAppLB_BackEndPool.id}"]
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_public_ip" "WebAppLBIP" {
  name                = "WebAppLBIP"
  location            = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_network_security_group" "WebAppNSG" {
  name                = "WebAppNSG"
  location            = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"

  security_rule {
    name                       = "CommonManagement-I-100"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${azurerm_network_interface.BastionNIC.private_ip_address}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WebApp-I-101"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_lb" "WebAppLB" {
  name                = "WebAppLB"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"
  location            = "${azurerm_resource_group.ResourceGroup.location}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "WebAppLBFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.WebAppLBIP.id}"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "azurerm_lb_backend_address_pool" "WebAppLB_BackEndPool" {
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"
  loadbalancer_id     = "${azurerm_lb.WebAppLB.id}"
  name                = "WebAppLBBackEndPool"
}

resource "azurerm_lb_probe" "WebAppLB_HTTP_Probe" {
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"
  loadbalancer_id     = "${azurerm_lb.WebAppLB.id}"
  name                = "WebAppLB_HTTP_Probe"
  protocol            = "http"
  request_path        = "/"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "WebAppLB_HTTP" {
  resource_group_name            = "${azurerm_resource_group.ResourceGroup.name}"
  loadbalancer_id                = "${azurerm_lb.WebAppLB.id}"
  name                           = "WebAppLB_HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "WebAppLBFrontEnd"
  probe_id                       = "${azurerm_lb_probe.WebAppLB_HTTP_Probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.WebAppLB_BackEndPool.id}"
  disable_outbound_snat          = false
  load_distribution              = "Default"
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
}
