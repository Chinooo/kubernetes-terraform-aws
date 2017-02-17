provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "master" {
  ami           = "ami-bdf943dd"
  instance_type = "t2.large"
}

resource "aws_instance" "minion-01" {
  ami           = "ami-bdf943dd"
  instance_type = "t2.large"
}

resource "aws_instance" "minion-02" {
  ami           = "ami-bdf943dd"
  instance_type = "t2.large"
}

#resource "aws_efs_file_system" "aws-efs" {
#  creation_token = "adop.efs"
#  tags {
#    name = "ADOP-EFS"
#  }
#}
