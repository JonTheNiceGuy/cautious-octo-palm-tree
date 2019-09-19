resource "aws_security_group" "NotificationSG" {
  name = "NotificationSG"
  description = "Notification security group"
  vpc_id = "${aws_vpc.DemoNetwork.id}"

  tags = {
    Name          = "NotificationSG",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "NotificationServer" {
  availability_zone = "${var.Az2}"
  ami = "${var.AmiName}"
  instance_type = "t2.nano"
  key_name = "${var.KeyName}"
  subnet_id = "${aws_subnet.PublicAZ2Subnet.id}"
  vpc_security_group_ids = [
    "${aws_security_group.NotificationSG.id}",
    "${aws_security_group.CommonManagementSG.id}"
  ]
  associate_public_ip_address = false

  tags = {
    Name          = "NotificationServer",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}