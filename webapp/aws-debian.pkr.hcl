packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}


variable "source_ami" {
  type    = string
  default = "ami-071175b60c818694f" # Debian 12 (HVM)
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


source "amazon-ebs" "csye6225-debian12" {
  region          = ${{ vars.AWS_REGION_PACKER }}
  ami_name        = "csye6225_${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  ami_description = "AMI for CSYE 6225"
  ami_users       = "${var.ami_users}"
  ami_regions = [
    "us-west-1",
  ]

  instance_type = "t2.micro"
  source_ami    = "${var.source_ami}"
  ssh_username  = "${var.ssh_username}"
  subnet_id     = "${var.subnet_id}"
  # vpc_id        = "${var.vpc_id}"

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp2"
  }
}

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
}
