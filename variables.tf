variable "access_key" {}
variable "secret_key" {}
variable "ssh_key_name" {}

variable "region" {
  default = "us-west-2"
}

variable "cluster_name" {
    default = "testing"
}

variable "containers_cidr" {
    default = "10.244.0.0/16"
}

variable "portal_net" {
    default = "10.0.0.0/16"
}

variable "num_master" {
    default = 1
}

variable "num_minion" {
    default = 1
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

variable "kubernetes_version" {
    default = "1.5.0"
}

variable "pod_network" {
    default = "10.2.0.0/16"
}

variable "service_ip_range" {
    default = "10.3.0.0/24"
}

variable "k8s_service_ip" {
    default = "10.3.0.1"
}

variable "dns_service_ip" {
    default = "10.3.0.10"
}

variable "api_secure_port" {
    default = "443"
}

variable "master_dns_name" {
    default = ""
}
