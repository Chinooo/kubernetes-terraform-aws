variable "access_key" {}
variable "secret_key" {}
variable "ssh_key_name" {}

variable "region" {
  default = "us-west-2"
}

variable "cluster_name" {
    default = "testing"
}

variable "ami" {
    default = "ami-2709bd47"
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
