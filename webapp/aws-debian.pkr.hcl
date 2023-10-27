packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

# Defining variable types and default values

variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "source_ami" {
  type    = string
  default = "ami-071175b60c818694f" # Debian 12 (HVM)
}

variable "device_name" {
  type    = string
  default = "/dev/xvda"
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

variable "subnet_id" {
  type    = string
  default = "subnet-0506898af94ad421d"
}

variable "ami_users" {
  type    = list(string)
  default = ["359865058304"]
}

variable "ami_regions" {
  type    = list(string)
  default = ["us-west-1"]

}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "volume_size" {
  type    = number
  default = 8
}

variable "volume_type" {
  type    = string
  default = "gp2"
}

variable "delay_seconds" {
  type    = number
  default = 120
}

variable "max_attempts" {
  type    = number
  default = 50
}

variable "group" {
  type    = string
  default = "csye6225"
}

variable "user" {
  type    = string
  default = "csye6225"
}

# Defining top-level reusable builder configuration block
source "amazon-ebs" "csye6225-debian12" {
  region          = "${var.aws_region}"
  ami_name        = "csye6225_${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  ami_description = "AMI for CSYE 6225"
  ami_users       = "${var.ami_users}"
  ami_regions     = "${var.ami_regions}"
  aws_polling {
    delay_seconds = "${var.delay_seconds}"
    max_attempts  = "${var.max_attempts}"
  }

  instance_type = "${var.instance_type}"
  source_ami    = "${var.source_ami}"
  ssh_username  = "${var.ssh_username}"
  subnet_id     = "${var.subnet_id}"

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "${var.device_name}"
    volume_size           = "${var.volume_size}"
    volume_type           = "${var.volume_type}"
  }
}

# Defining build level source block to set specific source fields
build {
  sources = [
    "source.amazon-ebs.csye6225-debian12",
  ]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "CHECKPOINT_DISABLE=1"
    ]
    script          = "install.sh"
    pause_before    = "30s"
    timeout         = "30s"
    execute_command = "sudo -E -S sh '{{.Path}}'"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "CHECKPOINT_DISABLE=1"
    ]
    inline = [
      "sudo groupadd ${var.group}",
      "sudo useradd -s /bin/false -g ${var.group} -d /opt/ ${var.user}",
      "sudo chown -R ${var.ssh_username}:${var.ssh_username} /opt/"
    ]
  }

  provisioner "file" {
    source      = "webapp.zip"
    destination = "/opt/"
  }

  provisioner "file" {
    source      = "webapp.service"
    destination = "/tmp/"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "CHECKPOINT_DISABLE=1"
    ]
    inline = [
      "cd /opt/",
      "unzip webapp.zip",
      "cd webapp",
      "mv users.csv /opt/",
      "rm /opt/webapp.zip",
      "sudo mv /tmp/webapp.service /etc/systemd/system/",
      "sudo systemctl enable webapp"
    ]
  }
}