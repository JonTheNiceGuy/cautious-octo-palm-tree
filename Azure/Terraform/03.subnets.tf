resource "azurerm_subnet" "PublicSubnet" {
  name                 = "PublicSubnet"
  resource_group_name  = "${azurerm_resource_group.ResourceGroup.name}"
  virtual_network_name = "${azurerm_virtual_network.DemoNetwork.name}"
  address_prefix       = "10.10.11.0/24"
}

resource "azurerm_subnet" "PrivateSubnet" {
  name                 = "PrivateSubnet"
  resource_group_name  = "${azurerm_resource_group.ResourceGroup.name}"
  virtual_network_name = "${azurerm_virtual_network.DemoNetwork.name}"
  address_prefix       = "10.10.21.0/24"
}

resource "azurerm_route_table" "PrivateRouteTable" {
  name                = "PrivateRouteTable"
  location            = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"

  route {
    name           = "Deny_Internet_Access"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "None"
  }

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}