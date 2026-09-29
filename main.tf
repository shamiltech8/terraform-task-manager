terraform {
  required_version = ">= 1.16.0"

backend "s3" {
  bucket       = "shamil-terraform-state-2026-148908330969"
  key          = "cloud-native-task-manager/terraform.tfstate"
  region       = "ap-south-1"
  encrypt      = true
  use_lockfile = true
}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "task_manager" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]

  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile

  associate_public_ip_address = true

  tags = {
    Name = "cloud-native-task-manger"
  }
}

resource "aws_security_group" "task_manager" {
  name        = "task-manager-sg"
  description = "security group for cloud-native task manager"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"

    cidr_blocks = [
      "152.59.223.250/32",
      "152.59.222.99/32",
      "157.51.249.128/32",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "task_manager" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

