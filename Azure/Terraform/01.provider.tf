provider "azurerm" {}

resource "azurerm_resource_group" "ResourceGroup" {
  name     = "DemoResourceGroup"
  location = "${var.Region}"

  tags = {
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}