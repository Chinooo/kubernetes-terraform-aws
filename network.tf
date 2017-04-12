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
