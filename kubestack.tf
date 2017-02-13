provider "aws" {
access_key = "${var.access_key}"
secret_key = "${var.secret_key}"
region     = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "ami-7c803d1c"
  instance_type = "t2.micro"
}
