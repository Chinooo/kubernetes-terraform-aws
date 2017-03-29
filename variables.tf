variable "access_key" {}
variable "secret_key" {}
variable "ssh_key_name" {}

variable "region" {
  default = "us-west-2"
}

variable "subnet_zone" {
  default = "us-west-2a"
}

variable "cluster_name" {
  default = "test"
}

// ami-7ac6491a :: ubuntu-xenial-16.04-amd64-hvm-ssd/ebs
variable "ami" {
  default = "ami-7ac6491a"
}

variable "master_instance_type" {
  default = "m4.xlarge"
}

variable "minion_instance_type" {
  default = "m4.xlarge"
}

variable "api_secure_port" {
  default = "443"
}

output "master_ip" {
  value = "${aws_instance.master.public_ip}"
}

output "minion_ip" {
  value = "${aws_instance.minion.public_ip}"
}
