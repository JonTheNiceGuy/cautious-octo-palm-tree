variable "Region" {
  description = "Region to run in"
  default = "Central US"
}

variable "ProvisioningMethod" {
  description = "How was this provisioned"
  default = "Terraform"
}

variable "OrchestrationMethod" {
  description = "What orchestration tool provisioned this"
  default = "Terraform"
}

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

resource "azurerm_template_deployment" "demo" {
  name = "demo"
  resource_group_name = "${azurerm_resource_group.ResourceGroup.name}"

  parameters = {
    PublicKey = "${file("id_rsa.pub")}",
    OrchestrationMethod = "Terraform"
  }

  template_body = "${file("../ARM/template.json")}"
  deployment_mode = "Incremental"
}