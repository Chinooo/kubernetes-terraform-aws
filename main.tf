provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

//
// MASTER
//

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

//
// MINIONS
//

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

//
// EFS
//

resource "aws_efs_mount_target" "kubernetes" {
  file_system_id  = "fs-da935a73"
  subnet_id       = "${aws_subnet.kubernetes.id}"
  security_groups = ["${aws_security_group.kubernetes.id}"]
}
