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

resource "aws_security_group" "gitlab_sg" {
  name        = "gitlab_sg"
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
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "PostgreSQL"
    from_port        = 5432
    to_port          = 5432
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
    Name  = "gitlab_sg"
    Owner = "gene.gotimer@steampunk.com"
  }
}

resource "aws_instance" "gitlab" {
  count                  = 2
  ami                    = "ami-00e87074e52e6c9f9"
  instance_type          = "m5a.large"
  monitoring             = true
  ebs_optimized          = true
  vpc_security_group_ids = [aws_security_group.gitlab_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = "ansible_key"

  tags = {
    Terraform = "true"
    Owner     = "gene.gotimer@steampunk.com"
    Name      = "gitlab${count.index}"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }
}

resource "aws_eip" "gitlab_eip0" {
  instance = aws_instance.gitlab[0].id
  vpc      = true
}

resource "aws_eip" "gitlab_eip1" {
  instance = aws_instance.gitlab[1].id
  vpc      = true
}
