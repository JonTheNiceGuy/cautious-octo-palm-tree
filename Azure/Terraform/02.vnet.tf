resource "azurerm_virtual_network" "DemoNetwork" {
  name                = "DemoNetwork"
  address_space       = ["10.10.0.0/16"]
  location            = "${azurerm_resource_group.ResourceGroup.location}"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}