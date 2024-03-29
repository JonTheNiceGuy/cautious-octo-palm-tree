resource "aws_subnet" "PublicAZ1Subnet" {
  vpc_id     = "${aws_vpc.DemoNetwork.id}"
  cidr_block = "10.10.11.0/24"
  availability_zone = "${local.RegionAz1}"

  tags = {
    Name          = "PublicAZ1Subnet",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "aws_subnet" "PublicAZ2Subnet" {
  vpc_id     = "${aws_vpc.DemoNetwork.id}"
  cidr_block = "10.10.12.0/24"
  availability_zone = "${local.RegionAz2}"
  
  tags = {
    Name          = "PublicAZ2Subnet",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "aws_route_table" "PublicRoutingTable" {
  vpc_id = "${aws_vpc.DemoNetwork.id}"
  tags = {
    Name          = "PublicRoutingTable",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "aws_route" "PublicRouteEntry" {
  route_table_id = "${aws_route_table.PublicRoutingTable.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.InternetGateway.id}"
}

resource "aws_route_table_association" "PublicAZ1SubnetRoute" {
  subnet_id = "${aws_subnet.PublicAZ1Subnet.id}"
  route_table_id = "${aws_route_table.PublicRoutingTable.id}"
}

resource "aws_route_table_association" "PublicAZ2SubnetRoute" {
  subnet_id = "${aws_subnet.PublicAZ2Subnet.id}"
  route_table_id = "${aws_route_table.PublicRoutingTable.id}"
}