provider "aws" {
  region = "eu-central-1"
}

resource "aws_cloudformation_stack" "demo" {
  name = "demo"

  parameters = {
    KeyName = "Windows_2014-12-07.OpenSSH",
    OrchestrationMethod = "Terraform"
  }

  template_body = "${file("../CloudFormation/Build.cform.yaml")}"
}