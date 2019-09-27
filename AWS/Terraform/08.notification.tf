resource "aws_security_group" "NotificationSG" {
  name        = "NotificationSG"
  description = "Notification security group"
  vpc_id      = "${aws_vpc.DemoNetwork.id}"

  tags = {
    Name          = "NotificationSG",
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

resource "aws_instance" "NotificationServer" {
  availability_zone = "${local.RegionAz2}"
  ami               = "${var.AmiName}"
  instance_type     = "t2.nano"
  key_name          = "${var.KeyName}"
  subnet_id         = "${aws_subnet.PublicAZ2Subnet.id}"
  vpc_security_group_ids = [
    "${aws_security_group.NotificationSG.id}",
    "${aws_security_group.CommonManagementSG.id}"
  ]
  associate_public_ip_address = false

  user_data = <<-EOT
#!/bin/bash -x
export http_proxy=http://${aws_instance.Bastion.private_ip}:8888
export https_proxy=$http_proxy
until /usr/bin/amazon-linux-extras install -y ansible2 ; do /bin/sleep 10 ; done
echo --- > /tmp/playbook.yml
echo "- hosts: localhost" >> /tmp/playbook.yml
echo "  gather_facts: false" >> /tmp/playbook.yml
echo "  tasks:" >> /tmp/playbook.yml
echo "  - copy:" >> /tmp/playbook.yml
echo "      content: Confirmed" >> /tmp/playbook.yml
echo "      dest: /var/log/ansible_run.out" >> /tmp/playbook.yml
sleep 5
ansible-playbook /tmp/playbook.yml
sleep 5
EOT

  tags = {
    Name               = "NotificationServer",
    NotificationServer = "True",
    Env                = "Demo",
    Provisioning       = "${var.ProvisioningMethod}",
    Orchestration      = "${var.OrchestrationMethod}"
  }
}
