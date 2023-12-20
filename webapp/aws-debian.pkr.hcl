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

# Use this AWS AMI snapshot and build on top of it
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

# Account ids to share AMI with
variable "ami_users" {
  type    = list(string)
  default = ["359865058304"]
}

# Regions to share AMI with 
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

  # Run install.sh as a root user to set up runner with dependencies
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

  # Create custom user and group, change ownership of /opt, and 
  # install the package for amazon-cloudwatch-agent
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "CHECKPOINT_DISABLE=1"
    ]
    inline = [
      "sudo groupadd ${var.group}",
      "sudo useradd -s /bin/false -g ${var.group} -d /opt/ ${var.user}",
      "sudo chown -R ${var.ssh_username}:${var.ssh_username} /opt/",
      "sudo dpkg -i -E /opt/amazon-cloudwatch-agent.deb"
    ]
  }

  # Get webapp.zip from current directory on the github runner and move to /opt/ folder
  provisioner "file" {
    source      = "webapp.zip"
    destination = "/opt/"
  }

  # Get webapp.service from current directory on the github runner and move to /tmp/ folder 
  provisioner "file" {
    source      = "webapp.service"
    destination = "/tmp/"
  }

  # Unzip file, remove unwanted files and move files and folders where needed
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "CHECKPOINT_DISABLE=1"
    ]
    inline = [
      "cd /opt/",
      "touch webapp.log",
      "unzip webapp.zip",
      "cd webapp",
      "mv users.csv /opt/",
      "rm /opt/webapp.zip",
      "mv amazon-cloudwatch-agent.json /opt/",
      "rm /opt/amazon-cloudwatch-agent.deb",
      "sudo mv /tmp/webapp.service /etc/systemd/system/",
      "sudo systemctl enable webapp",
      "sudo rm -rf /opt/webapp/__pycache__/"
    ]
  }
}