resource "aws_security_group" "MonitoringSG" {
  name        = "MonitoringSG"
  description = "Monitoring security group"
  vpc_id      = "${aws_vpc.DemoNetwork.id}"

  tags = {
    Name          = "MonitoringSG",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Monitoring1" {
  availability_zone = "${local.RegionAz1}"
  ami               = "${var.AmiName}"
  instance_type     = "t2.nano"
  key_name          = "${var.KeyName}"
  subnet_id         = "${aws_subnet.PrivateAZ1Subnet.id}"
  vpc_security_group_ids = [
    "${aws_security_group.MonitoringSG.id}",
    "${aws_security_group.CommonManagementSG.id}"
  ]
  associate_public_ip_address = false

  tags = {
    Name             = "Monitoring1",
    MonitoringServer = "True",
    Env              = "Demo",
    Provisioning     = "${var.ProvisioningMethod}",
    Orchestration    = "${var.OrchestrationMethod}"
  }
}

resource "aws_instance" "Monitoring2" {
  availability_zone = "${local.RegionAz2}"
  ami               = "${var.AmiName}"
  instance_type     = "t2.nano"
  key_name          = "${var.KeyName}"
  subnet_id         = "${aws_subnet.PrivateAZ2Subnet.id}"
  vpc_security_group_ids = [
    "${aws_security_group.MonitoringSG.id}",
    "${aws_security_group.CommonManagementSG.id}"
  ]
  associate_public_ip_address = false

  tags = {
    Name             = "Monitoring2",
    MonitoringServer = "True",
    Env              = "Demo",
    Provisioning     = "${var.ProvisioningMethod}",
    Orchestration    = "${var.OrchestrationMethod}"
  }
}
