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
  #checkov:skip=CKV2_AWS_1: This is for public access
  cidr_block = "10.8.0.0/16"

  tags = {
    Name = "scdad"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.scdad_vpc.id
}

resource "aws_internet_gateway" "scdad_gateway" {
  vpc_id = aws_vpc.scdad_vpc.id
}

resource "aws_flow_log" "log" {
  iam_role_arn    = var.aws_flow_logs_role_arn
  log_destination = var.aws_flow_logs_log_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.scdad_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.scdad_vpc.id
  cidr_block = "10.8.0.0/24"

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.scdad_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.scdad_gateway.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "nexus3_sg" {
  name        = "nexus3_sg"
  description = "Nexus 3 traffic"
  vpc_id      = aws_vpc.scdad_vpc.id

  #checkov:skip=CKV_AWS_24: This is for public access
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "t3a.medium"
  monitoring             = true
  ebs_optimized          = true
  vpc_security_group_ids = [aws_security_group.nexus3_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = "ansible_key"

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

resource "aws_eip" "nexus3_eip" {
  instance = aws_instance.nexus3.id
  vpc      = true
}
