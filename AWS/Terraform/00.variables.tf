variable "AmiName" {
  description = "Name of the AWS AMI to use (Search AMI Name: amzn2-ami-hvm-2.0.*-x86_64-gp2). Default is provided on 2019-09-10"
  default = "ami-00aa4671cbf840d82"
}

# This /\/\/\ would be better served using 
# https://www.terraform.io/docs/providers/aws/d/ami.html
# But it's like this for feature parity with the CF file

variable "KeyName" {
  description = "Name of your SSH Key to access all the resources."
  default = "Windows_2014-12-07.OpenSSH"
}

variable "Region" {
  description = "Region to run in"
  default = "eu-central-1"
}

variable "Az1" {
  description = "First Availability Zone to use"
  default = "a"
}

variable "Az2" {
  description = "Second Availability Zone to use"
  default = "b"
}

variable "ProvisioningMethod" {
  description = "How was this provisioned"
  default = "Terraform"
}

variable "OrchestrationMethod" {
  description = "What orchestration tool provisioned this"
  default = "None"
}

locals {
  RegionAz1 = "${var.Region}${var.Az1}"
  RegionAz2 = "${var.Region}${var.Az2}"
}