terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "vm_sg" {
  name_prefix = "cee-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "aws" {
  key_name   = "aws"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.aws.key_name

  vpc_security_group_ids = [aws_security_group.vm_sg.id]

  user_data = templatefile("${path.module}/setup.sh", {
    runc_version = var.runc_version
  })
}

resource "null_resource" "copy_scripts" {
  count = length(var.script_paths)

  depends_on = [aws_instance.vm]

  provisioner "file" {
    source      = var.script_paths[count.index]
    destination = "/tmp/${basename(var.script_paths[count.index])}"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = aws_instance.vm.public_ip
    }
  }
}

output "instance_ip" {
  value = aws_instance.vm.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.ssh_private_key_path} ubuntu@${aws_instance.vm.public_ip}"
}
