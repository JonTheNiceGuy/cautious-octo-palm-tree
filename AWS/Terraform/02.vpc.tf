resource "aws_vpc" "DemoNetwork" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "DemoNetwork",
    Env  = "Demo"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = "${aws_vpc.DemoNetwork.id}"
  tags = {
    Name = "DemoNetwork",
    Env  = "Demo"
  }
}

