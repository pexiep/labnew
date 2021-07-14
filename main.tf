provider "aws" {
	  profile    = "default"
      region     = "${var.region}"
      access_key = "${var.access_key}"
      secret_key = "${var.secret_key}"
}


# VPC resources: This will create 1 VPC with 2 Subnets, 1 Internet Gateway, 2 Route Tables. 

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  
  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
  
    tags = {
    Name = "iGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#Create Security Group

resource "aws_security_group" "allow_web" {
     name        = "http-https-allow"
     description = "Allow incoming HTTP and HTTPS and Connections"
     vpc_id      = "${aws_vpc.default.id}"
     ingress {
         from_port = 80
         to_port = 80
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
    }
     ingress {
         from_port = 443
         to_port = 443
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
    }
	ingress {
         from_port = 22
         to_port = 22
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_vpc.default.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "one" {
  count = length(var.public_subnet_cidr_blocks)
  vpc = true
}

#Create EC2

data "aws_ami" "amazon-linux-2" {
 most_recent = true


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_instance" "test" {
	depends_on = ["aws_internet_gateway.test"]
	count = var.instances_per_subnet * length(module.vpc.public_subnets)
	
	
	ami                         = "${data.aws_ami.amazon-linux-2.id}"
	associate_public_ip_address = true
	iam_instance_profile        = "${aws_iam_instance_profile.test.id}"
	instance_type               = "t2.micro"
	vpc_security_group_ids      = ["${aws_security_group.allow_web.id}"]
	subnet_id                   = "${aws_vpc.default.id[count.index % length(module.vpc.public_subnets)]}"
	key_name = var.key_name

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
    }
	
	user_data = <<-EOF
		#!/bin/bash
		sudo su
		yum -y install httpd
		echo "<p> My Instance! </p>" >> /var/www/html/index.html
		sudo systemctl enable httpd
		sudo systemctl start httpd
		EOF
	tags = {
      Name = "web-server"
    }
}
