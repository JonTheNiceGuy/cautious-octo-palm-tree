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
  default = "None"
}

variable "vm_user" {
  description = "Virtual Machine User Name"
  default = "azure-user"
}

variable "Az1" {
  description = "First Availability Zone to use"
  default = "1"
}

variable "Az2" {
  description = "Second Availability Zone to use"
  default = "2"
}
