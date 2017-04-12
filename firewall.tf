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
