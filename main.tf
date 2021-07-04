terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "quick_lab" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Quick Lab"
  }
}

resource "aws_subnet" "quick_lab" {
  vpc_id     = aws_vpc.quick_lab.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "K8S Cluster"
  }
}

resource "aws_instance" "quick_lab" {

  count = 3

  ami           = "ami-0ab4d1e9cf9a1215a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.quick_lab.id

  tags = {
    Name = "Server ${count.index + 1}"
  }
}