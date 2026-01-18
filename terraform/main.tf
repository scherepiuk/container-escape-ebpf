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
  ami           = "ami-0a854fe96e0b45e4e"
  instance_type = "t3.2xlarge"
  key_name      = aws_key_pair.aws.key_name

  vpc_security_group_ids = [aws_security_group.vm_sg.id]

  user_data = templatefile("${path.module}/setup.sh", {
    runc_version = local.runc_version
  })
}

resource "null_resource" "directories" {
  depends_on = [aws_instance.vm]

  provisioner "remote-exec" {
    inline = ["sudo mkdir -m 777 -p /tmp/pocs /tmp/rules /tmp/utils"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(pathexpand(var.ssh_private_key_path))
      host        = aws_instance.vm.public_ip
    }
  }
}

resource "null_resource" "files" {
  for_each = local.files

  depends_on = [null_resource.directories]

  provisioner "file" {
    source      = each.key
    destination = each.value

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = aws_instance.vm.public_ip
    }
  }
}
