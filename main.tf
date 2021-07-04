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

resource "aws_instance" "app_server" {

  count = 3

  ami           = "ami-0ab4d1e9cf9a1215a"
  instance_type = "t2.micro"

  tags = {
    Name = "Server ${count.index + 1}"
  }
}