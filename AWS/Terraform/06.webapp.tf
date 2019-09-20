resource "aws_security_group" "WebAppLBSG" {
  name = "WebAppLBSG"
  description = "WebApp ELB security group"
  vpc_id = "${aws_vpc.DemoNetwork.id}"

  tags = {
    Name          = "WebAppLBSG",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "WebAppLB" {
  name = "WebAppLB"
  subnets = [
    "${aws_subnet.PublicAZ1Subnet.id}",
    "${aws_subnet.PublicAZ2Subnet.id}"
  ]

  security_groups = [
    "${aws_security_group.WebAppLBSG.id}"
  ]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/"
    interval = 30
  }

  instances = [
    "${aws_instance.WebApp1.id}",
    "${aws_instance.WebApp2.id}"
  ]
  
  idle_timeout = 150

  tags = {
    Name          = "WebAppLB",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "aws_security_group" "WebAppSG" {
  name = "WebAppSG"
  description = "WebApp security group"
  vpc_id = "${aws_vpc.DemoNetwork.id}"

  tags = {
    Name          = "WebAppSG",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_groups = ["${aws_security_group.WebAppLBSG.id}"]
  }

  ingress {
    protocol = "icmp"
    from_port = -1
    to_port = -1
    security_groups = ["${aws_security_group.WebAppLBSG.id}"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_groups = ["${aws_security_group.MonitoringSG.id}"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_groups = ["${aws_security_group.BastionSG.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "WebApp1" {
  availability_zone = "${local.RegionAz1}"
  ami = "${var.AmiName}"
  instance_type = "t2.nano"
  key_name = "${var.KeyName}"
  subnet_id = "${aws_subnet.PublicAZ1Subnet.id}"
  vpc_security_group_ids = [
    "${aws_security_group.WebAppSG.id}",
    "${aws_security_group.CommonManagementSG.id}"
  ]
  associate_public_ip_address = true

  user_data = "${file("user-data.sh")}"

  tags = {
    Name          = "WebApp1",
    WebServer     = "True",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}

resource "aws_instance" "WebApp2" {
  availability_zone = "${local.RegionAz2}"
  ami = "${var.AmiName}"
  instance_type = "t2.nano"
  key_name = "${var.KeyName}"
  subnet_id = "${aws_subnet.PublicAZ2Subnet.id}"
  vpc_security_group_ids = [
    "${aws_security_group.WebAppSG.id}",
    "${aws_security_group.CommonManagementSG.id}"
  ]
  associate_public_ip_address = true

  user_data = "${file("user-data.sh")}"

  tags = {
    Name          = "WebApp2",
    WebServer     = "True",
    Env           = "Demo",
    Provisioning  = "${var.ProvisioningMethod}",
    Orchestration = "${var.OrchestrationMethod}"
  }
}