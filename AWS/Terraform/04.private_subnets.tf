resource "aws_subnet" "PrivateAZ1Subnet" {
  vpc_id     = "${aws_vpc.DemoNetwork.id}"
  cidr_block = "10.10.21.0/24"
  availability_zone = "${var.Az1}"

  tags = {
    Name = "PrivateAZ1Subnet",
    Env  = "Demo"
  }
}

resource "aws_subnet" "PrivateAZ2Subnet" {
  vpc_id     = "${aws_vpc.DemoNetwork.id}"
  cidr_block = "10.10.22.0/24"
  availability_zone = "${var.Az2}"
  
  tags = {
    Name = "PrivateAZ2Subnet",
    Env  = "Demo"
  }
}

resource "aws_route_table" "PrivateRoutingTable" {
  vpc_id = "${aws_vpc.DemoNetwork.id}"
  tags = {
    Name = "PrivateRoutingTable",
    Env  = "Demo"
  }
}

resource "aws_route_table_association" "PrivateAZ1SubnetRoute" {
  subnet_id = "${aws_subnet.PrivateAZ1Subnet.id}"
  route_table_id = "${aws_route_table.PrivateRoutingTable.id}"
}

resource "aws_route_table_association" "PrivateAZ2SubnetRoute" {
  subnet_id = "${aws_subnet.PrivateAZ2Subnet.id}"
  route_table_id = "${aws_route_table.PrivateRoutingTable.id}"
}