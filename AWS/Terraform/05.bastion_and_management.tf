resource "aws_security_group" "BastionSG" {
  name = "BastionSG"
  description = "Bastion security group"
  vpc_id = "${aws_vpc.DemoNetwork.id}"

  tags = {
    Name          = "BastionSG",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 8888
    to_port = 8888
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Bastion" {
  availability_zone = "${local.RegionAz1}"
  ami = "${var.AmiName}"
  instance_type = "t2.nano"
  key_name = "${var.KeyName}"
  subnet_id = "${aws_subnet.PublicAZ1Subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.BastionSG.id}"]
  associate_public_ip_address = true

  user_data = <<-EOT
#!/bin/bash -x
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y tinyproxy
/bin/sed -i"" "s/Allow 127.0.0.1/Allow 10.0.0.0\\/8/" /etc/tinyproxy/tinyproxy.conf
/bin/systemctl enable --now tinyproxy
EOT

  tags = {
    Name          = "Bastion",
    BastionServer = "True",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "aws_security_group" "CommonManagementSG" {
  name = "CommonManagementSG"
  description = "Common Management security group"
  vpc_id = "${aws_vpc.DemoNetwork.id}"

  tags = {
    Name          = "CommonManagementSG",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_groups = ["${aws_security_group.BastionSG.id}"]
  }
  ingress {
    protocol = "icmp"
    from_port = -1
    to_port = -1
    security_groups = ["${aws_security_group.BastionSG.id}"]
  }
  ingress {
    protocol = "icmp"
    from_port = -1
    to_port = -1
    security_groups = ["${aws_security_group.MonitoringSG.id}"]
  }
}