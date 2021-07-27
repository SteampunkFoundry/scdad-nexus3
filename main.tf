terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.32.0"
    }
  }

  required_version = ">= 1.0.2"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_vpc" "scdad_vpc" {
  cidr_block = "10.8.0.0/16"
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.scdad_vpc.id
}

resource "aws_flow_log" "log" {
  iam_role_arn    = var.aws_flow_logs_role_arn
  log_destination = var.aws_flow_logs_log_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.scdad_vpc.id
}

resource "aws_subnet" "apps_subnet" {
  vpc_id     = aws_vpc.scdad_vpc.id
  cidr_block = "10.8.1.0/24"
}

resource "aws_network_acl" "acl_ok" {
  vpc_id     = aws_vpc.scdad_vpc.id
  subnet_ids = [aws_subnet.apps_subnet.id]
}

resource "aws_security_group" "nexus3_sg" {
  name        = "nexus3_sg"
  description = "Nexus 3 traffic"
  vpc_id      = aws_vpc.scdad_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "nexus3_sg"
    Owner = "gene.gotimer@steampunk.com"
  }
}

resource "aws_instance" "nexus3" {
  ami                    = "ami-029c0fbe456d58bd1"
  instance_type          = "t3a.medium"
  monitoring             = true
  ebs_optimized          = true
  vpc_security_group_ids = [aws_security_group.nexus3_sg.id]
  subnet_id              = aws_subnet.apps_subnet.id

  tags = {
    Terraform = "true"
    Owner     = "gene.gotimer@steampunk.com"
    Name      = "nexus3"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }
}
