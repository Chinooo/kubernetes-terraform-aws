provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

#######
# VPC #
#######

resource "aws_vpc" "kubernetes" {
    cidr_block = "172.20.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
        Name = "kubernetes-${var.cluster_name}"
    }
}

resource "aws_subnet" "kubernetes" {
    vpc_id = "${aws_vpc.kubernetes.id}"
    cidr_block = "172.20.250.0/24"
    availability_zone = "us-west-2a"
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
    subnet_id = "${aws_subnet.kubernetes.id}"
    route_table_id = "${aws_route_table.kubernetes.id}"
}

######################
# Network & Security #
######################

resource "aws_security_group" "kubernetes" {
    name = "kubernetes-${var.cluster_name}"
    vpc_id = "${aws_vpc.kubernetes.id}"
    tags {
        Name = "kubernetes-${var.cluster_name}"
    }
}

resource "aws_security_group_rule" "allow_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_kube_api" {
    type = "ingress"
    from_port = "${var.api_secure_port}"
    to_port = "${var.api_secure_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_all_cluster" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    source_security_group_id = "${aws_security_group.kubernetes.id}"
    security_group_id = "${aws_security_group.kubernetes.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.kubernetes.id}"
}

#######
# IAM #
#######

# aws_iam_role
# aws_iam_role_policy
# aws_iam_instance_profile

##########
# MASTER #
##########

resource "aws_instance" "master" {
    ami = "${var.ami}"
    instance_type = "${var.master_instance_type}"
    security_groups = [ "${aws_security_group.kubernetes.id}" ]
    subnet_id = "${aws_subnet.kubernetes.id}"
    associate_public_ip_address = true
    key_name = "${var.ssh_key_name}"

    connection {
        user = "ubuntu"
        agent = true
    }

    tags {
        Name = "${var.cluster_name}-master"
        Cluster = "${var.cluster_name}"
        Role = "master"
    }
}

###########
# MINIONS #
###########

resource "aws_launch_configuration" "minion" {
    image_id = "${var.ami}"
    instance_type = "${var.minion_instance_type}"
    security_groups = [ "${aws_security_group.kubernetes.id}" ]
    associate_public_ip_address = true
    key_name = "${var.ssh_key_name}"
}

resource "aws_autoscaling_group" "minion" {
    name = "${var.cluster_name}-k8s-minion"
    launch_configuration = "${aws_launch_configuration.minion.name}"
    max_size = "${var.num_minion}"
    min_size = "${var.num_minion}"
    desired_capacity = "${var.num_minion}"
    vpc_zone_identifier = [ "${aws_subnet.kubernetes.id}" ]

    tag {
        key = "Name"
        value = "${var.cluster_name}-minion"
        propagate_at_launch = true
    }

    tag {
        key = "Cluster"
        value = "${var.cluster_name}"
        propagate_at_launch = true
    }

    tag {
        key = "Role"
        value = "minion"
        propagate_at_launch = true
    }
}

#######
# EFS #
#######

resource "aws_efs_file_system" "kubernetes" {
  creation_token = "kubernetes.efs"
  tags {
    Name = "kubernetes-${var.cluster_name}"
  }
}

resource "aws_efs_mount_target" "kubernetes" {
  file_system_id = "${aws_efs_file_system.kubernetes.id}"
  subnet_id = "${aws_subnet.kubernetes.id}"
}
