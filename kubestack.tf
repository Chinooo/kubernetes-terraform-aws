provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

###########
# Network #
###########

resource "aws_vpc" "kubernetes" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "kubernetes-${var.cluster_name}"
  }
}

resource "aws_subnet" "kubernetes" {
  vpc_id            = "${aws_vpc.kubernetes.id}"
  cidr_block        = "172.20.250.0/24"
  availability_zone = "${var.subnet_zone}"

  tags {
    Name = "kubernetes-${var.cluster_name}"
  }
}

resource "aws_internet_gateway" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"

  tags {
    Name = "kubernetes-${var.cluster_name}"
  }
}

resource "aws_route_table" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kubernetes.id}"
  }

  tags {
    Name = "kubernetes-${var.cluster_name}"
  }
}

resource "aws_route_table_association" "kubernetes" {
  subnet_id      = "${aws_subnet.kubernetes.id}"
  route_table_id = "${aws_route_table.kubernetes.id}"
}

############
# Firewall #
############

resource "aws_security_group" "kubernetes" {
  name   = "kubernetes-${var.cluster_name}"
  vpc_id = "${aws_vpc.kubernetes.id}"

  tags {
    Name = "kubernetes-${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_kube_api" {
  type              = "ingress"
  from_port         = "${var.api_secure_port}"
  to_port           = "${var.api_secure_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_special_http" {
  type              = "ingress"
  from_port         = 30001
  to_port           = 30001
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_special_https" {
  type              = "ingress"
  from_port         = 30002
  to_port           = 30002
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_all_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.kubernetes.id}"
  security_group_id        = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes.id}"
}

##########
# MASTER #
##########

resource "aws_instance" "master" {
  ami                         = "${var.ami}"
  instance_type               = "${var.master_instance_type}"
  security_groups             = ["${aws_security_group.kubernetes.id}"]
  subnet_id                   = "${aws_subnet.kubernetes.id}"
  associate_public_ip_address = true
  key_name                    = "${var.ssh_key_name}"
  private_ip                  = "172.20.250.82"

  root_block_device {
    volume_size = 40
  }

  connection {
    user        = "ubuntu"
    agent       = true
    private_key = "${file("${var.ssh_key_name}.pem")}"
  }

  tags {
    Name    = "${var.cluster_name}-master"
    Cluster = "${var.cluster_name}"
    Role    = "master"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/DigitalOnUs/automated_scripts.git",
      "cd automated_scripts ",
      "sudo sh startclustr.sh",
    ]
  }
}

###########
# MINIONS #
###########

resource "aws_instance" "minion" {
  ami                         = "${var.ami}"
  instance_type               = "${var.minion_instance_type}"
  security_groups             = ["${aws_security_group.kubernetes.id}"]
  subnet_id                   = "${aws_subnet.kubernetes.id}"
  associate_public_ip_address = true
  key_name                    = "${var.ssh_key_name}"

  root_block_device {
    volume_size = 40
  }

  connection {
    user        = "ubuntu"
    agent       = true
    private_key = "${file("${var.ssh_key_name}.pem")}"
  }

  tags {
    Name    = "${var.cluster_name}-minion"
    Cluster = "${var.cluster_name}"
    Role    = "minion"
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/DigitalOnUs/automated_scripts.git",
      "cd automated_scripts ",
      "sudo sh starter-minion.sh",
    ]
  }
}

resource "null_resource" "minion" {
  connection {
    host        = "${aws_instance.minion.public_ip}"
    user        = "ubuntu"
    agent       = true
    private_key = "${file("${var.ssh_key_name}.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubeadm join --token y2bcde.zv1gcyg9wn2ov12o 172.20.250.82:6443",
    ]
  }
}

#######
# EFS #
#######

resource "aws_efs_mount_target" "kubernetes" {
  file_system_id  = "fs-da935a73"
  subnet_id       = "${aws_subnet.kubernetes.id}"
  security_groups = ["${aws_security_group.kubernetes.id}"]
}
